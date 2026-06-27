// require_tasks.cs - PreToolUse hook for Claude Code (.NET file-based app, Write|Edit)
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
// see: https://code.claude.com/docs/en/hooks#pretooluse-decision-control

using System.Text.Json;
using System.Text.Json.Serialization;

internal static class Tasks
{
    // session のタスク json を走査し、in_progress な Task が 1 つでもあれば true。
    // ディレクトリが無い / 読めない json は安全側に無視する。
    public static bool HasInProgress(string sessionId)
    {
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var dir = Path.Combine(home, ".claude", "tasks", sessionId);
        if (!Directory.Exists(dir)) return false;

        foreach (var path in Directory.EnumerateFiles(dir, "*.json"))
        {
            if (ReadStatus(path) == "in_progress") return true;
        }

        return false;
    }

    private static string? ReadStatus(string path)
    {
        try
        {
            var task = JsonSerializer.Deserialize(File.ReadAllText(path), TaskJson.Default.TaskState);
            return task?.Status;
        }
        catch
        {
            return null;
        }
    }
}

internal static class Program
{
    private const string Reason =
        "in_progress な Task が無い状態での Write/Edit は禁止されている。\n\n" +
        "ファイルを編集する前に、その編集を担う Task を必ず in_progress にしなければならない。" +
        "in_progress な Task が 1 つも無いままの編集は規約違反であり、この編集はブロックされた。\n\n" +
        "1. まだ Task が無ければ TaskCreate で作業を分解する\n" +
        "2. これから着手するステップの Task を TaskUpdate で in_progress にする\n" +
        "3. そのステップが完了したら completed にする\n\n" +
        "いま該当 Task を in_progress にしてから、編集をやり直すこと。";

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName is not ("Write" or "Edit")) return 0;

        // session_id が取れない場合は、別セッションやサブエージェントの状態で
        // 誤ってブロックしないよう、安全側に倒して許可する。
        var sessionId = hook.SessionId ?? "";
        if (sessionId.Length == 0) return 0;

        // 計画立案そのものは止めない。plan ファイルの作成は編集前の安全なステップで
        // あり、Task の存在を要求すると plan モードが自身の plan を書けなくなる。
        var filePath = hook.ToolInput?.FilePath ?? "";
        if (filePath.Contains("/.claude/plans/")) return 0;

        if (Tasks.HasInProgress(sessionId)) return 0;

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
    [property: JsonPropertyName("session_id")] string? SessionId,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput);

record ToolInput([property: JsonPropertyName("file_path")] string? FilePath);

record TaskState([property: JsonPropertyName("status")] string? Status);

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

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(TaskState))]
partial class TaskJson : JsonSerializerContext;
