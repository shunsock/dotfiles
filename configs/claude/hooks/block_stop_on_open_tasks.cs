// block_stop_on_open_tasks.cs - Stop hook for Claude Code (.NET file-based app)
//
// 未完了 (pending / in_progress) の Task が残ったままの停止をブロックする。
// require_tasks (編集前に in_progress を要求する PreToolUse ゲート) と対で機能し、
// 「捨て Task を 1 つ in_progress にして放置」を防ぐ。停止しようとした時点で未完了
// Task があれば、それらを片付ける (実作業を行う) まで停止できない。
//
// 実行は AOT ビルドせず `dotnet run block_stop_on_open_tasks.cs` で単一ファイルのまま
// 行う。「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
//
// Task 状態は $HOME/.claude/tasks/<session_id>/<id>.json の .status を読む。形式と
// 同期性は require_tasks のヘッダコメント参照。Stop hook は PreToolUse と出力スキーマ
// が異なり、トップレベルの decision:"block" + reason で停止を拒否する。
// see: https://code.claude.com/docs/en/hooks#stop-and-subagentstop-decision-control

using System.Text.Json;
using System.Text.Json.Serialization;

internal static class Tasks
{
    private static readonly string[] IncompleteStatuses = ["pending", "in_progress"];

    // session の未完了 Task を "- [status] subject" の行で集める。読めない json は無視。
    public static IReadOnlyList<string> IncompleteLines(string sessionId)
    {
        var home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        var dir = Path.Combine(home, ".claude", "tasks", sessionId);
        if (!Directory.Exists(dir)) return [];

        var lines = new List<string>();
        foreach (var path in Directory.EnumerateFiles(dir, "*.json"))
        {
            var task = Read(path);
            if (task?.Status is { } status && IncompleteStatuses.Contains(status))
            {
                lines.Add($"- [{status}] {task.Subject}");
            }
        }

        return lines;
    }

    private static TaskState? Read(string path)
    {
        try
        {
            return JsonSerializer.Deserialize(File.ReadAllText(path), TaskJson.Default.TaskState);
        }
        catch
        {
            return null;
        }
    }
}

internal static class Program
{
    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);

        // stop_hook_active な停止は、この hook 自身のブロックで再入した停止。ここで再び
        // ブロックすると無限ループになるため許可する。
        if (hook?.StopHookActive == true) return 0;

        // session_id が取れない場合は、別セッションの状態で誤ってブロックしないよう
        // 安全側に倒して許可する。
        var sessionId = hook?.SessionId ?? "";
        if (sessionId.Length == 0) return 0;

        var incomplete = Tasks.IncompleteLines(sessionId);
        if (incomplete.Count == 0) return 0;

        var reason =
            "未完了の Task が残っている:\n" +
            string.Join('\n', incomplete) +
            "\n各 Task は実際に作業を行って解決すること (作業せずに completed にしてはならない)。" +
            "すべて片付けてから停止し直すこと。";

        var decision = new Decision("block", reason);
        Console.WriteLine(JsonSerializer.Serialize(decision, HookJson.Default.Decision));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("session_id")] string? SessionId,
    [property: JsonPropertyName("stop_hook_active")] bool? StopHookActive);

record TaskState(
    [property: JsonPropertyName("status")] string? Status,
    [property: JsonPropertyName("subject")] string? Subject);

record Decision(
    [property: JsonPropertyName("decision")] string DecisionValue,
    [property: JsonPropertyName("reason")] string Reason);

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(Decision))]
partial class HookJson : JsonSerializerContext;

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(TaskState))]
partial class TaskJson : JsonSerializerContext;
