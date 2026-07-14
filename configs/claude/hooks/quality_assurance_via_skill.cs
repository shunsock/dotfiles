// quality_assurance_via_skill.cs - PreToolUse hook (.NET file-based app)
// バックエンドのソースが staged された状態での `git commit` を捕捉し、先に
// review_code__bug_checker スキル (コミットゲートモード) を実行するよう誘導する。
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
    private static readonly Regex GitCommit = new(@"\bgit\s+commit(\s|$)");
    private static readonly Regex BackendSource = new(
        @"\.(py|go|rs|ts|mjs|cjs|rb|java|kt|kts|scala|php|ex|exs|c|h|cpp|cc|hpp|cs|swift|sql)$"
    );
    private const string BypassMarker = "@quality-assurance-via-skill-bypass";

    public static bool IsBypassedCommit(string command) =>
        GitCommit.IsMatch(command) && !command.Contains(BypassMarker);

    public static bool HasStagedBackendSource(IEnumerable<string> stagedFiles) =>
        stagedFiles.Any(BackendSource.IsMatch);
}

internal static class Git
{
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
            if (process is null)
                return [];
            var output = process.StandardOutput.ReadToEnd();
            process.WaitForExit();
            if (process.ExitCode != 0)
                return [];

            return output.Split(
                '\n',
                StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries
            );
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
        "バックエンドのソース変更を含む `git commit` を直接実行することは禁止されています。"
        + "コミット前の品質ゲートとして、先に review_code__bug_checker スキルをコミットゲートモードで実行してください。\n\n"
        + "このスキルは、攻撃観点 (境界値 / 不正な値 / 悪意ある入力 / 状態と時間) に 5 つのバックエンド QA ペルソナ "
        + "(敵対者 / データ監査役 / 移行 / リグレッション番人 / 懐疑的アナリスト) と ISO 25010 品質特性を重ねて "
        + "テストケースを設計・実行し、変更内容に対する 25 列 CSV のテストケース設計書を出力します。"
        + "一次情報 (仕様 / issue / コード) に紐付け、根拠のないケースは出しません。"
        + "未確認のモジュールは「※要静的解析 (未実施)」と明記します。\n\n"
        + "いま review_code__bug_checker スキルを実行し、テストケース設計を済ませてから、"
        + "スキルの手順に従ってコミットしてください。";

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName != "Bash")
            return 0;

        var command = hook.ToolInput?.Command ?? "";
        if (command.Length == 0)
            return 0;

        if (!Gate.IsBypassedCommit(command))
            return 0;
        if (!Gate.HasStagedBackendSource(Git.StagedFiles()))
            return 0;

        // CONSTRAINT: PreToolUse は permissionDecision "deny" の JSON でのみ拒否できる
        // SEE: https://code.claude.com/docs/en/hooks
        var decision = new Decision(new HookSpecificOutput("PreToolUse", "deny", Reason));
        Console.WriteLine(JsonSerializer.Serialize(decision, HookJson.Default.Decision));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput
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
