// validate_japanese_stop_word.cs - PreToolUse(Bash) フック。
// `git commit` / `gh pr create` の実行前に、変更ファイルを stop word CLI で走査する。
// AI 特有の不自然な日本語語彙が残っていれば deny でブロックし、書き直しを指示する。
// CLI や git が実行できない環境ではブロックしない (fail open)。
// SEE: ~/.claude/cli/check_japanese_stop_word.cs
// SEE: ~/.claude/skills/reference/japanese_stop_word/stop_word.csv

using System.Diagnostics;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

internal enum DiffScope
{
    Staged,
    Branch,
}

internal static class Gate
{
    private static readonly Regex GitCommit = new(@"\bgit\s+commit\b");
    private static readonly Regex GhPrCreate = new(@"\bgh\s+pr\s+create\b");

    public static DiffScope? ScopeOf(string command) =>
        command switch
        {
            _ when GitCommit.IsMatch(command) => DiffScope.Staged,
            _ when GhPrCreate.IsMatch(command) => DiffScope.Branch,
            _ => null,
        };
}

internal static class TargetExtensions
{
    private static readonly string[] ProseExtensions = [".md", ".markdown", ".txt"];

    // SEE: ~/.claude/skills/reference/comment_out_skills_target/extensions.csv
    public static IReadOnlySet<string> Load()
    {
        var home = Environment.GetEnvironmentVariable("HOME") ?? "";
        var csv = Path.Combine(
            home,
            ".claude",
            "skills",
            "reference",
            "comment_out_skills_target",
            "extensions.csv"
        );
        var set = new HashSet<string>(ProseExtensions, StringComparer.OrdinalIgnoreCase);
        if (!File.Exists(csv))
            return set;
        foreach (var line in File.ReadLines(csv))
        {
            var ext = line.Trim();
            if (ext.StartsWith('.'))
                set.Add(ext);
        }
        return set;
    }
}

internal readonly record struct CommandResult(int ExitCode, string Stdout, string Stderr);

internal static class Shell
{
    public static CommandResult? Run(
        string fileName,
        IReadOnlyList<string> arguments,
        string workingDirectory
    )
    {
        try
        {
            var info = new ProcessStartInfo
            {
                FileName = fileName,
                WorkingDirectory = workingDirectory,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
            };
            foreach (var argument in arguments)
                info.ArgumentList.Add(argument);
            using var process = Process.Start(info);
            if (process is null)
                return null;
            var stdout = process.StandardOutput.ReadToEndAsync();
            var stderr = process.StandardError.ReadToEndAsync();
            process.WaitForExit();
            return new CommandResult(process.ExitCode, stdout.Result, stderr.Result);
        }
        catch (Exception)
        {
            return null;
        }
    }
}

internal static class ChangedFiles
{
    public static IReadOnlyList<string> Collect(
        DiffScope scope,
        string cwd,
        IReadOnlySet<string> extensions
    )
    {
        var repoRoot = GitStdout(["rev-parse", "--show-toplevel"], cwd);
        if (repoRoot is null)
            return [];
        var names = scope switch
        {
            DiffScope.Staged => GitStdout(
                ["diff", "--cached", "--name-only", "--diff-filter=ACMR"],
                cwd
            ),
            _ => BranchDiff(cwd),
        };
        if (names is null)
            return [];
        return names
            .Split('\n', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Where(name => extensions.Contains(Path.GetExtension(name)))
            .Select(name => Path.Combine(repoRoot, name))
            .Where(File.Exists)
            .ToList();
    }

    private static string? BranchDiff(string cwd)
    {
        var originHead = GitStdout(["symbolic-ref", "--short", "refs/remotes/origin/HEAD"], cwd);
        var baseRef = string.IsNullOrEmpty(originHead) ? "origin/main" : originHead;
        return GitStdout(["diff", "--name-only", "--diff-filter=ACMR", $"{baseRef}...HEAD"], cwd);
    }

    private static string? GitStdout(string[] arguments, string cwd)
    {
        var result = Shell.Run("git", arguments, cwd);
        return result is { ExitCode: 0 } success ? success.Stdout.Trim() : null;
    }
}

internal static class StopWordCli
{
    public const int FoundExitCode = 1;

    public static CommandResult? Run(IReadOnlyList<string> files, string cwd)
    {
        var home = Environment.GetEnvironmentVariable("HOME") ?? "";
        var cliPath = Path.Combine(home, ".claude", "cli", "check_japanese_stop_word.cs");
        if (!File.Exists(cliPath))
            return null;
        var arguments = new List<string> { "run", cliPath, "--" };
        arguments.AddRange(files);
        return Shell.Run("dotnet", arguments, cwd);
    }
}

internal static class DenyReason
{
    private const int MaxShownFindings = 40;

    public static string Build(string cliStderr)
    {
        var findings = cliStderr.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        var sb = new StringBuilder();
        sb.Append("AI 特有の不自然な日本語語彙が変更ファイルに残っています。");
        sb.Append("commit / PR 作成の前に書き直してください。\n\n");
        sb.Append("検出結果 (ファイル:行: 語彙と言い換え先):\n");
        foreach (var finding in findings.Take(MaxShownFindings))
            sb.Append($"- {finding}\n");
        if (findings.Length > MaxShownFindings)
            sb.Append($"- (ほか {findings.Length - MaxShownFindings} 件)\n");
        sb.Append("\n各指摘の言い換え先に沿って該当箇所を書き直してください。");
        sb.Append(
            "機械的な置換で文が不自然になる場合は、文全体を自然な日本語へ書き直してください。"
        );
        sb.Append("すべて修正したうえで、再度同じコマンドを実行してください。\n");
        sb.Append("語彙の一覧: ~/.claude/skills/reference/japanese_stop_word/stop_word.csv");
        return sb.ToString();
    }
}

internal static class Program
{
    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName != "Bash")
            return 0;

        var command = hook.ToolInput?.Command ?? "";
        if (Gate.ScopeOf(command) is not { } scope)
            return 0;

        var cwd = hook.Cwd ?? Directory.GetCurrentDirectory();
        var files = ChangedFiles.Collect(scope, cwd, TargetExtensions.Load());
        if (files.Count == 0)
            return 0;

        var result = StopWordCli.Run(files, cwd);
        if (result is not { ExitCode: StopWordCli.FoundExitCode } found)
            return 0;

        var decision = new Decision(
            new HookSpecificOutput("PreToolUse", "deny", DenyReason.Build(found.Stderr))
        );
        Console.WriteLine(JsonSerializer.Serialize(decision, HookJson.Default.Decision));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput,
    [property: JsonPropertyName("cwd")] string? Cwd
);

record ToolInput([property: JsonPropertyName("command")] string? Command);

record Decision(
    [property: JsonPropertyName("hookSpecificOutput")] HookSpecificOutput HookSpecificOutput
);

record HookSpecificOutput(
    [property: JsonPropertyName("hookEventName")] string HookEventName,
    [property: JsonPropertyName("permissionDecision")] string PermissionDecision,
    [property: JsonPropertyName("permissionDecisionReason")] string PermissionDecisionReason
);

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(Decision))]
partial class HookJson : JsonSerializerContext;
