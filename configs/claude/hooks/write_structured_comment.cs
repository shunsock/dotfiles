// write_structured_comment.cs - PostToolUse hook for Claude Code (.NET file-based app)
// ソースファイルへの Write/Edit の後に、write__structured_comment スキルの実行を促す
// 必須指示を注入する。デフォルトはコメント 0 とし、コードに表現できない知識
// (未完の事実と外部世界の事実) のみを共有マーカー語彙から whitelist として書かせる。
//
// 発火順は writer -> cleaner。settings.json の Write|Edit matcher で本フックを
// clean_comment_out.cs より前に登録し、まず構造化マーカーを書いてから掃除を回す。
// 「write (構造化) -> clean (掃除) で cleaner が no-op になる」品質ゲートの流れによる。
//
// 実行は AOT ビルドせず `dotnet run write_structured_comment.cs` で単一ファイルのまま行う。
// 「app.cs 単体で動く」ことを .NET 採用の主目的に置いた設計判断による。
//
// additionalContext による注入は会話へ文章を追加するだけで、ツール実行を強制しない。
// そのためメッセージは明示的な指示で書く。注入先は hookSpecificOutput.additionalContext。
// see: https://code.claude.com/docs/en/hooks#posttooluse-decision-control
//
// 非ソースファイル (設定 / ドキュメント / データ) はスキップする。マーカー判断は
// プログラミング言語に適用され、すべての Write/Edit (例: markdown, json) で発火させると
// ノイズになるため。

using System.Text.Json;
using System.Text.Json.Serialization;

internal static class SourceFile
{
    // HACK:
    // clean_comment_out.cs と拡張子集合を重複定義している。file-based app は単一
    // ファイルで動く設計 (共有モジュールを持てない) ための意図的な重複であり、直さない。
    // 片方の拡張子を変えたら、もう片方も必ず揃えること。
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
        "[必須アクション] いま変更したファイルに対して、ただちに write__structured_comment スキルを実行しなければならない。" +
        "これは後続の clean__comment_out より先に行う。省略してはならない。ユーザーへの確認も不要である。\n\n" +
        "write__structured_comment スキルは、デフォルトをコメント 0 とし、コードに表現できない知識だけを" +
        "共有マーカー語彙から whitelist として書く。いま次を適用すること:\n" +
        "1. 語彙・フォーマット・契約の single source of truth `~/.claude/skills/template/comment_markers.md` を読み込む。\n" +
        "2. いま編集した箇所ごとに「コードへ表現できない知識があるか」を問う。既定の答えは No (コメントを足さない)。\n" +
        "3. 足すのは whitelist の 7 マーカー (TODO/FIXME/HACK/SEE/CONSTRAINT/COMPAT/SAFETY) に該当するときだけ。正規フォーマット (インライン `MARKER: content` / 複数行) で書く。\n" +
        "4. プログラム知識は命名・型・構造で、ドメイン知識はドメインモデルで表現する — コメントにしない。一過性の経緯は commit/PR へ。\n" +
        "5. コメントのみを追加する — コードの挙動は変えず、いま変更したファイルだけを対象にする。\n\n" +
        "いま編集したファイルへのマーカー記述が完了するまで、他のタスクへ進んではならない。";

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
