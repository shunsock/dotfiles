// clean_comment_out.cs - PostToolUse hook for Claude Code (.NET file-based app)
// ソースファイルへの Write/Edit の後に、clean__comment_out スキルの実行を促す必須
// 指示を注入する。意味のないコメントやコメントアウトされたデッドコードを削除させ、
// 価値あるコメント (Why / 設計判断 / 共有テンプレートのマーカー / 公開仕様) は残させる。
// 保持マーカー語彙は write_structured_comment.cs と
// `~/.claude/skills/template/comment_markers.md` を single source of truth として共有する。
//
// 実行は AOT ビルドせず `dotnet run clean_comment_out.cs` で単一ファイルのまま行う。
// 「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
//
// additionalContext による注入は会話へ文章を追加するだけで、ツール実行を強制しない。
// そのためメッセージは明示的な指示で書く。注入先は hookSpecificOutput.additionalContext。
// see: https://code.claude.com/docs/en/hooks#posttooluse-decision-control
//
// 非ソースファイル (設定 / ドキュメント / データ) はスキップする。コメント整理の判断
// (Why か What か、デッドコード、ドキュメントコメント、マーカー) はプログラミング言語に
// 適用され、すべての Write/Edit (例: markdown, json) で発火させるとノイズになるため。

using System.Text.Json;
using System.Text.Json.Serialization;

internal static class SourceFile
{
    private static readonly HashSet<string> Extensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".rs", ".go", ".py", ".ts", ".tsx", ".js", ".jsx", ".java", ".kt", ".kts",
        ".c", ".h", ".cpp", ".cc", ".hpp", ".cs", ".rb", ".php", ".swift",
        ".scala", ".sh", ".bash", ".zsh", ".lua", ".ex", ".exs", ".hs",
        ".ml", ".dart", ".nix",
    };

    public static bool IsSource(string filePath) => Extensions.Contains(Path.GetExtension(filePath));
}

internal static class Program
{
    private static string BuildContext(string path) =>
        $"ソースファイルが Write/Edit されました: {path}\n\n" +
        "[必須アクション] いま変更したファイルに対して、ただちに clean__comment_out スキルを実行しなければならない。" +
        "省略してはならない。ユーザーへの確認も不要である。\n\n" +
        "clean__comment_out スキルは、意味のないコメントとコメントアウトされたデッドコードを削除し、" +
        "価値あるコメントは残す。保持すべきマーカー語彙は write__structured_comment と共有する。いま次を適用すること:\n" +
        "1. 保持マーカー語彙の single source of truth `~/.claude/skills/template/comment_markers.md` を読み込む。\n" +
        "2. いま編集したファイルのコメントを洗い出す。\n" +
        "3. 削除する: コードを見れば自明な内容 (What) を述べただけのコメント、コメントアウトされた古いコード (デッドコード)。\n" +
        "4. 残す: なぜ (Why) を説明するコメント (設計判断 / 制約 / トレードオフ)、共有テンプレートのマーカー (および legacy XXX)、公開インターフェースのドキュメントコメント。\n" +
        "5. 迷ったらコメントを残す。\n" +
        "6. コメントのみを編集する — コードの挙動は変えず、いま変更したファイルだけを対象にする。\n\n" +
        "いま編集したファイルのコメント整理が完了するまで、他のタスクへ進んではならない。";

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName is not ("Write" or "Edit")) return 0;

        var filePath = hook.ToolInput?.FilePath ?? "";
        if (filePath.Length == 0) return 0;
        if (!SourceFile.IsSource(filePath)) return 0;

        var output = new Output(new HookSpecificOutput("PostToolUse", BuildContext(filePath)));
        Console.WriteLine(JsonSerializer.Serialize(output, HookJson.Default.Output));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput);

record ToolInput([property: JsonPropertyName("file_path")] string? FilePath);

record Output(
    [property: JsonPropertyName("hookSpecificOutput")] HookSpecificOutput HookSpecificOutput);

record HookSpecificOutput(
    [property: JsonPropertyName("hookEventName")] string HookEventName,
    [property: JsonPropertyName("additionalContext")] string AdditionalContext);

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(Output))]
partial class HookJson : JsonSerializerContext;
