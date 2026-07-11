// clean_comment_out.cs - PostToolUse(Write|Edit) フック。ソース編集後に
// clean__comment_out スキルの実行を促す。
// SEE: ~/.claude/hooks/README.md

using System.Text.Json;
using System.Text.Json.Serialization;

internal static class SourceFile
{
    // SEE: ~/.claude/skills/reference/comment_out_skills_target/extensions.csv
    private static readonly HashSet<string> Extensions = LoadExtensions();

    private static HashSet<string> LoadExtensions()
    {
        var home = Environment.GetEnvironmentVariable("HOME") ?? "";
        var csv = Path.Combine(
            home,
            ".claude",
            "skills",
            "reference",
            "comment_out_skills_target",
            "extensions.csv"
        );
        var set = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        if (!File.Exists(csv))
            return set;
        foreach (var line in File.ReadLines(csv))
        {
            var ext = line.Trim();
            if (ext.StartsWith('.'))
                set.Add(ext);
        }
        return set;
    }

    public static bool IsSource(string filePath) =>
        Extensions.Contains(Path.GetExtension(filePath));
}

internal static class Program
{
    private static string BuildContext(string path) =>
        $"ソースファイルが Write/Edit されました: {path}\n\n"
        + "[必須アクション] いま変更したファイルに対して、ただちに clean__comment_out スキルを実行しなければならない。"
        + "省略してはならない。ユーザーへの確認も不要である。\n\n"
        + "clean__comment_out スキルは、whitelist マーカーで始まらない非 doc コメントをすべて削除し、"
        + "マーカー付きコメントと doc コメントだけを残す。語彙は write__structured_comment と共有する。いま次を適用すること:\n"
        + "1. 保持マーカー語彙の single source of truth `~/.claude/skills/template/comment_markers.md` を読み込む。\n"
        + "2. いま編集したファイルのコメントを洗い出す。\n"
        + "3. 残す: whitelist マーカー (TODO/FIXME/SEE/CONSTRAINT/NOTE/HACK/SAFETY) で始まるコメントと、公開インターフェースの doc コメント (rustdoc /// ・JSDoc ・docstring)。\n"
        + "4. 削除する: 上記以外すべて。What コメント・マーカー無しの Why 散文・コメントアウトされたデッドコード・legacy XXX を含む。\n"
        + "5. 迷ったら削除する。本当に必要な知識なら writer がマーカー付きで書き直す。\n"
        + "6. コメントのみを編集する — コードの挙動は変えず、いま変更したファイルだけを対象にする。\n\n"
        + "いま編集したファイルのコメント整理が完了するまで、他のタスクへ進んではならない。";

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName is not ("Write" or "Edit"))
            return 0;

        var filePath = hook.ToolInput?.FilePath ?? "";
        if (filePath.Length == 0)
            return 0;
        if (!SourceFile.IsSource(filePath))
            return 0;

        var output = new Output(new HookSpecificOutput("PostToolUse", BuildContext(filePath)));
        Console.WriteLine(JsonSerializer.Serialize(output, HookJson.Default.Output));
        return 0;
    }
}

record HookInput(
    [property: JsonPropertyName("tool_name")] string? ToolName,
    [property: JsonPropertyName("tool_input")] ToolInput? ToolInput
);

record ToolInput([property: JsonPropertyName("file_path")] string? FilePath);

record Output(
    [property: JsonPropertyName("hookSpecificOutput")] HookSpecificOutput HookSpecificOutput
);

record HookSpecificOutput(
    [property: JsonPropertyName("hookEventName")] string HookEventName,
    [property: JsonPropertyName("additionalContext")] string AdditionalContext
);

[JsonSourceGenerationOptions(DefaultIgnoreCondition = JsonIgnoreCondition.Never)]
[JsonSerializable(typeof(HookInput))]
[JsonSerializable(typeof(Output))]
partial class HookJson : JsonSerializerContext;
