// quality_assurance_via_skill.cs - PreToolUse hook for Claude Code (.NET file-based app)
// バックエンドのソースが staged された状態での `git commit` を捕捉し、先に
// quality_assurance__design_test_cases スキルを実行するよう誘導する。
//
// 実行は AOT ビルドせず `dotnet run quality_assurance_via_skill.cs` で単一ファイルの
// まま行う。「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
//
// 発火を「バックエンドソースが staged のとき」に限るのは、ドキュメントや設定だけの
// コミットで毎回 QA を走らせるとノイズになるため。フロントエンド専用拡張子
// (.tsx/.jsx/.vue/.svelte/.css/.html) は対象に含めない。
//
// 無限ループ防止のため、スキルは自身の `git commit` にバイパスマーカー
// `# @quality-assurance-via-skill-bypass` を付与する。マーカーがあれば通す。

using System.Diagnostics;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

internal static class Gate
{
    // commit の直後は空白か行末のみを許し、commit-graph / commit-tree など別コマンドへ
    // の誤マッチを避ける。
    private static readonly Regex GitCommit = new(@"\bgit\s+commit(\s|$)");
    private static readonly Regex BackendSource =
        new(@"\.(py|go|rs|ts|mjs|cjs|rb|java|kt|kts|scala|php|ex|exs|c|h|cpp|cc|hpp|cs|swift|sql)$");
    private const string BypassMarker = "@quality-assurance-via-skill-bypass";

    public static bool IsBypassedCommit(string command) =>
        GitCommit.IsMatch(command) && !command.Contains(BypassMarker);

    // staged な変更ファイル (追加/コピー/変更/リネーム) に 1 つでも対象拡張子があれば true。
    public static bool HasStagedBackendSource(IEnumerable<string> stagedFiles) =>
        stagedFiles.Any(BackendSource.IsMatch);
}

internal static class Git
{
    // staged 変更のファイル名を取得する。git が無い / リポジトリ外などで失敗した場合は
    // 空集合を返し、安全側 (発火させない) に倒す。
    public static IReadOnlyList<string> StagedFiles()
    {
        try
        {
            var psi = new ProcessStartInfo("git", "diff --cached --name-only --diff-filter=ACMR")
            {
                RedirectStandardOutput = true,
                RedirectStandardError = true,
            };
            using var process = Process.Start(psi);
            if (process is null) return [];
            var output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            if (process.ExitCode != 0) return [];

            return output.Split('\n', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        }
        catch
        {
            return [];
        }
    }
}

internal static class Program
{
    private const string Reason =
        "バックエンドのソース変更を含む `git commit` を直接実行することは禁止されています。" +
        "コミット前の品質ゲートとして、先に quality_assurance__design_test_cases スキルを実行してください。\n\n" +
        "このスキルは、5 つのバックエンド QA ペルソナ (敵対者 / データ監査役 / 移行 / リグレッション番人 / " +
        "懐疑的アナリスト) と ISO 25010 品質特性の観点で、変更内容に対する 25 列 CSV のテストケースを設計します。" +
        "一次情報 (仕様 / issue / コード) に紐付け、根拠のないケースは出しません。" +
        "未確認のモジュールは「※要静的解析 (未実施)」と明記します。\n\n" +
        "いま quality_assurance__design_test_cases スキルを実行し、テストケース設計を済ませてから、" +
        "スキルの手順に従ってコミットしてください。";

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName != "Bash") return 0;

        var command = hook.ToolInput?.Command ?? "";
        if (command.Length == 0) return 0;

        if (!Gate.IsBypassedCommit(command)) return 0;
        if (!Gate.HasStagedBackendSource(Git.StagedFiles())) return 0;

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
