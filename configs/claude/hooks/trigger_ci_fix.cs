// trigger_ci_fix.cs - PostToolUse hook for Claude Code (.NET file-based app)
// `git push` または `gh pr create` の成功後に、monitor__ci_status スキルの実行を促す
// 必須指示を注入する。これにより CI の失敗がユーザー介入なしに監視・修正される。
// 監視と修正のループは monitor__ci_status が所有し、各修復パスは rescue__ci_failure
// へ委譲される。
//
// 実行は AOT ビルドせず `dotnet run trigger_ci_fix.cs` で単一ファイルのまま行う。
// 「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
//
// additionalContext による注入は会話へ文章を追加するだけで、ツール実行を強制しない。
// そのため Claude が即座に行動する確度を上げるよう、メッセージは明示的かつ段階的な
// 手順で書く。注入先は hookSpecificOutput.additionalContext。
// see: https://code.claude.com/docs/en/hooks#posttooluse-decision-control

using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

internal static class Trigger
{
    private static readonly Regex GitPush = new(@"\bgit\s+push\b");
    private static readonly Regex GhPrCreate = new(@"\bgh\s+pr\s+create\b");

    // 発火対象なら CI 監視を促す文脈文を、対象外なら null を返す。gh pr create を
    // git push より優先して判定する (PR 作成は push を含む複合コマンドのことがある)。
    public static string? Context(string command)
    {
        if (GhPrCreate.IsMatch(command)) return "PR が作成されました。";
        if (GitPush.IsMatch(command)) return "PR ブランチへ commit が push されました。";
        return null;
    }
}

internal static class Program
{
    private static string BuildContext(string trigger) =>
        trigger + "\n\n" +
        "[必須アクション] ただちに monitor__ci_status スキルを実行しなければならない。省略してはならない。" +
        "ユーザーへの確認も不要である。これは CLAUDE.md のプロジェクト規約で要求されている。\n\n" +
        "monitor__ci_status スキルは監視と修正のループを所有し、CI をポーリングして失敗時には各修復パスで " +
        "rescue__ci_failure を起動する。いま次の手順を実行すること:\n" +
        "1. 現在のブランチと PR 番号を取得する:\n" +
        "   BRANCH=$(git branch --show-current)\n" +
        "   PR_NUMBER=$(gh pr view \"$BRANCH\" --json number --jq \".number\")\n" +
        "2. CI チェックが登録されるまで待つ (最大 60 秒ポーリング)\n" +
        "3. 全チェック完了まで 30 秒ごとに CI 状態をポーリングする (タイムアウト: 30 分)\n" +
        "4. 全チェックがパスしたら成功を報告する\n" +
        "5. いずれかが失敗したら rescue__ci_failure を起動する (gh run view <run_id> --log-failed でログを読み、コードを修正し、commit して push する)\n" +
        "6. 手順 2 から繰り返す (最大 5 回)\n\n" +
        "この CI 監視ワークフローが完了するまで、他のタスクへ進んではならない。";

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName != "Bash") return 0;

        var command = hook.ToolInput?.Command ?? "";
        if (command.Length == 0) return 0;

        var trigger = Trigger.Context(command);
        if (trigger is null) return 0;

        // ツール実行が成功したとき (exit code 0) だけ CI 監視を促す。フィールド名は
        // 実装差を吸収し exit_code / exitCode の双方を見る。欠落は成功扱い (= 発火)。
        var exitCode = hook.ToolOutput?.ExitCode ?? hook.ToolOutput?.ExitCodeCamel ?? 0;
        if (exitCode != 0) return 0;

        var output = new Output(new HookSpecificOutput("PostToolUse", BuildContext(trigger)));
        Console.WriteLine(JsonSerializer.Serialize(output, HookJson.Default.Output));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput,
    [property: JsonPropertyName("tool_output")] ToolOutput? ToolOutput);

record ToolInput([property: JsonPropertyName("command")] string? Command);

record ToolOutput(
    [property: JsonPropertyName("exit_code")] int? ExitCode,
    [property: JsonPropertyName("exitCode")] int? ExitCodeCamel);

record Output(
    [property: JsonPropertyName("hookSpecificOutput")] HookSpecificOutput HookSpecificOutput);

record HookSpecificOutput(
    [property: JsonPropertyName("hookEventName")] string HookEventName,
    [property: JsonPropertyName("additionalContext")] string AdditionalContext);

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(Output))]
partial class HookJson : JsonSerializerContext;
