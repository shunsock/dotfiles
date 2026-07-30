// validate_japanese_stop_word.cs - PostToolUse(Write|Edit) フック。
// ドキュメントやソースの編集直後に、編集されたファイルを stop word CLI で走査する。
// AI 特有の不自然な日本語語彙が含まれていれば、additionalContext で検出結果と
// 言い換え先を出力し、書き直しを指示する。
// dotnet や CLI が実行できない環境では何も出力しない (fail open)。
// SEE: ~/.claude/cli/check_japanese_stop_word.cs
// SEE: ~/.claude/skills/reference/japanese_stop_word/stop_word.csv

using System.Diagnostics;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;

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
    public static CommandResult? Run(string fileName, IReadOnlyList<string> arguments)
    {
        try
        {
            var info = new ProcessStartInfo
            {
                FileName = fileName,
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

internal static class StopWordCli
{
    public const int FoundExitCode = 1;

    public static CommandResult? Run(string filePath)
    {
        var home = Environment.GetEnvironmentVariable("HOME") ?? "";
        var cliPath = Path.Combine(home, ".claude", "cli", "check_japanese_stop_word.cs");
        if (!File.Exists(cliPath))
            return null;
        return Shell.Run("dotnet", ["run", cliPath, "--", filePath]);
    }
}

internal static class RewriteInstruction
{
    private const int MaxShownFindings = 30;

    public static string Build(string path, string cliStderr)
    {
        var findings = cliStderr.Split('\n', StringSplitOptions.RemoveEmptyEntries);
        var sb = new StringBuilder();
        sb.Append($"ファイルが Write/Edit されました: {path}\n\n");
        sb.Append(
            "[必須アクション] このファイルに AI 特有の不自然な日本語語彙 (stop word) が含まれている。"
        );
        sb.Append("ただちに言い換えなければならない。省略・ユーザーへの確認は不要である。\n\n");
        sb.Append("検出結果 (ファイル:行: 語彙と言い換え先):\n");
        foreach (var finding in findings.Take(MaxShownFindings))
            sb.Append($"- {finding}\n");
        if (findings.Length > MaxShownFindings)
            sb.Append($"- (ほか {findings.Length - MaxShownFindings} 件)\n");
        sb.Append("\n各指摘の言い換え先に沿って該当箇所を書き直す。");
        sb.Append("機械的な置換で文が不自然になる場合は、文全体を自然な日本語へ書き直す。");
        sb.Append(
            "語彙の一覧は ~/.claude/skills/reference/japanese_stop_word/stop_word.csv にある。\n\n"
        );
        sb.Append("すべての検出を解消するまで、他のタスクへ進んではならない。");
        return sb.ToString();
    }
}

internal static class HookIo
{
    public static async Task<string?> ReadEditedFilePathAsync()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName is not ("Write" or "Edit"))
            return null;
        var path = hook.ToolInput?.FilePath ?? "";
        return path.Length == 0 ? null : path;
    }

    public static void WriteContext(string context)
    {
        var output = new Output(new HookSpecificOutput("PostToolUse", context));
        Console.WriteLine(JsonSerializer.Serialize(output, HookJson.Default.Output));
    }
}

internal static class Program
{
    private static async Task<int> Main()
    {
        var path = await HookIo.ReadEditedFilePathAsync();
        if (path is null)
            return 0;
        if (!TargetExtensions.Load().Contains(Path.GetExtension(path)))
            return 0;
        if (!File.Exists(path))
            return 0;

        var result = StopWordCli.Run(path);
        if (result is not { ExitCode: StopWordCli.FoundExitCode } found)
            return 0;

        HookIo.WriteContext(RewriteInstruction.Build(path, found.Stderr));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput
);

record ToolInput([property: JsonPropertyName("file_path")] string? FilePath);

record Output(
    [property: JsonPropertyName("hookSpecificOutput")] HookSpecificOutput HookSpecificOutput
);

record HookSpecificOutput(
    [property: JsonPropertyName("hookEventName")] string HookEventName,
    [property: JsonPropertyName("additionalContext")] string AdditionalContext
);

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(Output))]
partial class HookJson : JsonSerializerContext;
