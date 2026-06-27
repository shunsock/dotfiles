// pr_submission_via_skill.cs - PreToolUse hook for Claude Code (.NET file-based app)
// `gh pr create` の直接実行を拒否し、submit__pull_request スキルの利用へ誘導する。
//
// 実行は AOT ビルドせず `dotnet run pr_submission_via_skill.cs` で単一ファイルのまま
// 行う。これは「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
//
// submit__pull_request スキルは自身の `gh pr create` にバイパスマーカー
// `# @pr-submission-via-skill-bypass` を付与する。マーカーがあれば通すことで、
// スキル経由の作成が無限に拒否されるループを避ける。

using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

internal static class Gate
{
    private static readonly Regex GhPrCreate = new(@"\bgh\s+pr\s+create\b");
    private const string BypassMarker = "@pr-submission-via-skill-bypass";

    // gh pr create を捕捉し、かつバイパスマーカーが無いときだけ拒否対象とする。
    public static bool ShouldDeny(string command) =>
        GhPrCreate.IsMatch(command) && !command.Contains(BypassMarker);
}

internal static class Program
{
    private const string Reason =
        "`gh pr create` の直接実行は禁止されています。代わりに submit__pull_request スキルを使用してください。" +
        "このスキルはナラティブ型の PR 説明文（概要・背景・課題・目標・採用手法・変更箇所・妥協と制限・" +
        "検証方法・確認事項・参考文献）を生成し、その後 CI を自動で監視します。\n\n" +
        "いま submit__pull_request スキルを実行し、適切なナラティブ説明文付きでこの PR を作成してください。";

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName != "Bash") return 0;

        var command = hook.ToolInput?.Command ?? "";
        if (command.Length == 0) return 0;

        if (!Gate.ShouldDeny(command)) return 0;

        // 終了コードでは確実にブロックできない (exit 1 等は非ブロッキング扱い)。
        // PreToolUse は permissionDecision: "deny" の JSON 出力でのみツール実行を拒否する。
        // see: https://code.claude.com/docs/en/hooks
        var decision = new Decision(new HookSpecificOutput("PreToolUse", "deny", Reason));
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
