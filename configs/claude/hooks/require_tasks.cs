// require_tasks.cs - PreToolUse hook for Claude Code (Write|Edit)
//
// in_progress な Task が 1 つも無い状態での Write/Edit を deny でブロックする。
// 「編集を始める前に、その作業を担う Task を in_progress にする」規約を強制する
// ハードゲート。「捨て Task を 1 つ作れば以降ずっと編集し放題」という抜け穴を塞ぐ。
//
// 実行は AOT ビルドせず `dotnet run require_tasks.cs` で単一ファイルのまま行う。
// 「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
//
// 判定は $HOME/.claude/tasks/<session_id>/<id>.json の .status を直接読む。
// 実機検証の結果、アクティブセッション中は TaskCreate/TaskUpdate が同 json を同期で
// 生成・更新するため、編集の瞬間の「現在 in_progress な Task」をディスクから確実に
// 判定できる。session_id を得る環境変数は無いため、stdin ペイロードが唯一の取得元。
// SEE: https://code.claude.com/docs/en/hooks#pretooluse-decision-control

using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

internal static class Tasks
{
    // CONSTRAINT: ディレクトリ欠落・不正 json は false を返して黙って握らねばならない。
    // REASON: 起動時失敗で編集ゲートが常時 deny に張り付くと開発が止まる。
    public static bool HasInProgress(string sessionId)
    {
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var dir = Path.Combine(home, ".claude", "tasks", sessionId);
        return Directory.Exists(dir) && Directory.EnumerateFiles(dir, "*.json").Any(IsInProgress);
    }

    private static bool IsInProgress(string path)
    {
        try
        {
            var t = JsonSerializer.Deserialize(File.ReadAllText(path), TaskJson.Default.TaskState);
            return t?.Status == "in_progress";
        }
        catch
        {
            return false;
        }
    }
}

internal static class Program
{
    // CONSTRAINT: session_id に "." や ".." だけの文字列を通してはならない。
    // REASON: tasks/../ 外を指し無関係ディレクトリを in_progress 判定に混入させる。
    private static readonly Regex SessionIdPattern = new(@"^(?!\.+$)[A-Za-z0-9._-]+$");

    // CONSTRAINT: fallback の task json 手動作成コマンドを reason に必ず埋め込まねばならない。
    // REASON: Task ツール不在セッションでは手動 fallback しか脱出手段が無い。
    private static string BuildReason(string sessionId) =>
        "in_progress な Task が無い状態での Write/Edit は禁止されている。\n\n"
        + "ファイルを編集する前に、その編集を担う Task を必ず in_progress にしなければならない。"
        + "in_progress な Task が 1 つも無いままの編集は規約違反であり、この編集はブロックされた。\n\n"
        + "1. まだ Task が無ければ TaskCreate で作業を分解する\n"
        + "2. これから着手するステップの Task を TaskUpdate で in_progress にする\n"
        + "3. そのステップが完了したら completed にする\n\n"
        + "いま該当 Task を in_progress にしてから、編集をやり直すこと。\n\n"
        + "TaskCreate/TaskUpdate ツールがこのセッションで利用不可の場合は、"
        + "作業単位を宣言する task json を直接作成してから編集をやり直すこと。実行例:\n"
        + $"mkdir -p ~/.claude/tasks/{sessionId} && "
        + "printf '{\"status\":\"in_progress\",\"subject\":\"<作業内容>\"}' "
        + $"> ~/.claude/tasks/{sessionId}/manual-1.json";

    private static async Task<int> Main()
    {
        HookInput? hook = TryParse(await Console.In.ReadToEndAsync());
        var sessionId = hook?.SessionId ?? "";
        var filePath = hook?.ToolInput?.FilePath ?? "";
        var mustDeny =
            hook?.ToolName is "Write" or "Edit"
            && SessionIdPattern.IsMatch(sessionId)
            && !IsExemptPath(filePath)
            && !Tasks.HasInProgress(sessionId);
        if (!mustDeny)
            return 0;

        // CONSTRAINT: deny は stdout JSON 経由で返さねばならない。
        // REASON: Claude Code 仕様上、終了コード非 0 ではツール実行をブロックできない。
        // SEE: https://code.claude.com/docs/en/hooks
        var decision = new Decision(
            new HookSpecificOutput("PreToolUse", "deny", BuildReason(sessionId))
        );
        Console.WriteLine(JsonSerializer.Serialize(decision, HookJson.Default.Decision));
        return 0;
    }

    // CONSTRAINT: 不正 JSON・空 stdin では例外を捕まえて null を返さねばならない。
    // REASON: 未捕捉例外で落ちると PreToolUse 全体が失敗しツールが止まる。
    private static HookInput? TryParse(string input)
    {
        try
        {
            return JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        }
        catch
        {
            return null;
        }
    }

    // CONSTRAINT: plans/ 配下と /private/tmp/claude-* パスは対象から外さねばならない。
    // REASON: いずれもスクラッチ領域で Task in_progress を持たない作業単位外である。
    private static bool IsExemptPath(string filePath) =>
        filePath.Length > 0
        && Path.GetFullPath(filePath) is string full
        && (full.Contains("/.claude/plans/") || full.StartsWith("/private/tmp/claude-"));
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("session_id")] string? SessionId,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput
);

record ToolInput([property: JsonPropertyName("file_path")] string? FilePath);

record TaskState([property: JsonPropertyName("status")] string? Status);

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

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(TaskState))]
partial class TaskJson : JsonSerializerContext;
