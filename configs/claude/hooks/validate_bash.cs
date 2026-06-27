// validate_bash.cs - PreToolUse hook for Claude Code (.NET file-based app)
// Rejects prohibited commands with guidance on alternatives.
//
// 実行は AOT ビルドせず `dotnet run validate_bash.cs` で単一ファイルのまま行う。
// これは「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
// 起動コストは実測 ~150ms/回 (bash+jq の約4倍) だが許容している。
//
// 構成: ルール集合 (ProhibitedCommands) を Validator に注入し、Main は配線のみを
// 担う。データ (ルール) と判定ロジック (Validator) を分離する。新しいルールを
// 足すときは ProhibitedCommands.Rules に 1 要素を追加するだけでよい。
//   - Rule.Command(name, reason)  : コマンド名。語境界 (\b) を自動で前後に付けて照合する。
//   - Rule.Pattern(regex, reason) : 正規表現をそのまま照合する。

using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

internal sealed record Rule(Regex Matcher, string Reason)
{
    public static Rule Command(string name, string reason) => new(new Regex($@"\b{name}\b"), reason);

    public static Rule Pattern(string regex, string reason) => new(new Regex(regex), reason);
}

internal static class ProhibitedCommands
{
    public static readonly IReadOnlyList<Rule> Rules = new[]
    {
        Rule.Command("awk", "awk is prohibited. Use the Edit tool or perl for text processing."),
        Rule.Command("sed", "sed is prohibited. Use the Edit tool or perl for text processing."),
        Rule.Command("python", "python is prohibited. Use uv for running python"),
        Rule.Command("uvx", "uvx is prohibited. Use tools via nix"),
        Rule.Command("npx", "npx is prohibited. Use tools via nix"),
        Rule.Command("bunx", "bunx is prohibited. Use tools via nix"),
        Rule.Pattern(@"\bgit\s+add\s+(-A|--all|\.)",
            "git add -A/--all/. is prohibited. Specify file names explicitly to avoid staging unintended files."),
    };
}

internal sealed class Validator(IReadOnlyList<Rule> rules)
{
    // 最初に一致したルールの拒否理由を返す。どのルールにも一致しなければ null (許可)。
    public string? FindViolation(string command)
    {
        foreach (var rule in rules)
        {
            if (rule.Matcher.IsMatch(command)) return rule.Reason;
        }

        return null;
    }
}

internal static class Program
{
    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName != "Bash") return 0;

        var command = hook.ToolInput?.Command ?? "";
        if (command.Length == 0) return 0;

        var validator = new Validator(ProhibitedCommands.Rules);
        var reason = validator.FindViolation(command);
        if (reason is null) return 0;

        // 終了コードでは確実にブロックできない (exit 1 等は非ブロッキング扱い)。
        // PreToolUse は permissionDecision: "deny" の JSON 出力でのみツール実行を拒否する。
        // see: https://code.claude.com/docs/en/hooks
        var decision = new Decision(new HookSpecificOutput("PreToolUse", "deny", reason));
        Console.WriteLine(JsonSerializer.Serialize(decision, HookJson.Default.Decision));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput);

record ToolInput([property: JsonPropertyName("command")] string? Command);

record Decision(
    [property: JsonPropertyName("hookSpecificOutput")] HookSpecificOutput HookSpecificOutput);

record HookSpecificOutput(
    [property: JsonPropertyName("hookEventName")] string HookEventName,
    [property: JsonPropertyName("permissionDecision")] string PermissionDecision,
    [property: JsonPropertyName("permissionDecisionReason")] string PermissionDecisionReason);

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(Decision))]
partial class HookJson : JsonSerializerContext;
