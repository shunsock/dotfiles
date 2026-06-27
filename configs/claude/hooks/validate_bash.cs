// validate_bash.cs - PreToolUse hook for Claude Code (.NET file-based app)
// Rejects prohibited commands with guidance on alternatives.
//
// 実行は AOT ビルドせず `dotnet run validate_bash.cs` で単一ファイルのまま行う。
// これは「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
// 起動コストは実測 ~150ms/回 (bash+jq の約4倍) だが許容している。
//
// ルールはデータとして宣言する。新しいルールを足すときは Rules に 1 要素を
// 追加するだけでよく、ロジックは変更しない。
//   - Command(name, reason)  : コマンド名。語境界 (\b) を自動で前後に付けて照合する。
//   - Pattern(regex, reason) : 正規表現をそのまま照合する。

using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

internal static class ValidateBash
{
    private sealed record Rule(Regex Matcher, string Reason);

    private static Rule Command(string name, string reason) => new(new Regex($@"\b{name}\b"), reason);

    private static Rule Pattern(string regex, string reason) => new(new Regex(regex), reason);

    private static readonly Rule[] Rules =
    {
        Command("awk", "awk is prohibited. Use the Edit tool or perl for text processing."),
        Command("sed", "sed is prohibited. Use the Edit tool or perl for text processing."),
        Command("python", "python is prohibited. Use uv for running python"),
        Command("uvx", "uvx is prohibited. Use tools via nix"),
        Command("npx", "npx is prohibited. Use tools via nix"),
        Command("bunx", "bunx is prohibited. Use tools via nix"),
        Pattern(@"\bgit\s+add\s+(-A|--all|\.)",
            "git add -A/--all/. is prohibited. Specify file names explicitly to avoid staging unintended files."),
    };

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName != "Bash") return 0;

        var command = hook.ToolInput?.Command ?? "";
        if (command.Length == 0) return 0;

        foreach (var rule in Rules)
        {
            if (rule.Matcher.IsMatch(command)) return Reject(rule.Reason);
        }

        return 0;
    }

    private static int Reject(string reason)
    {
        Console.WriteLine(JsonSerializer.Serialize(new Decision("reject", reason), HookJson.Default.Decision));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput);

record ToolInput([property: JsonPropertyName("command")] string? Command);

record Decision(
    [property: JsonPropertyName("decision")] string DecisionKind,
    [property: JsonPropertyName("reason")] string Reason);

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(Decision))]
partial class HookJson : JsonSerializerContext;
