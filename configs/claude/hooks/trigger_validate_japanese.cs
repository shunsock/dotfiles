// trigger_validate_japanese.cs - PostToolUse(Write|Edit) フック。
// 日本語を含む Markdown の編集後に validate__japanese スキルの実行を促す。
// ファイルが読めない環境では何も出力しない (fail open)。
// SEE: ~/.claude/skills/validate__japanese/SKILL.md

using System.Text.Json;
using System.Text.Json.Serialization;

internal static class JapaneseMarkdown
{
    private static readonly string[] MarkdownExtensions = [".md", ".markdown"];

    public static bool IsMarkdown(string filePath) =>
        MarkdownExtensions.Contains(Path.GetExtension(filePath), StringComparer.OrdinalIgnoreCase);

    public static bool ContainsJapanese(string filePath)
    {
        try
        {
            return File.ReadLines(filePath)
                .Any(line => line.Any(ch => IsKanaOrCjkPunctuation(ch) || IsCjkIdeograph(ch)));
        }
        catch (Exception)
        {
            return false;
        }
    }

    private static bool IsKanaOrCjkPunctuation(char ch) => ch is >= '　' and <= 'ヿ';

    private static bool IsCjkIdeograph(char ch) => ch is >= '一' and <= '鿿';
}

internal static class Program
{
    private static string BuildContext(string path) =>
        $"日本語 Markdown が Write/Edit されました: {path}\n\n"
        + "[必須アクション] いま変更したファイルに対して、ただちに validate__japanese スキルを実行しなければならない。"
        + "省略してはならない。ユーザーへの確認も不要である。\n\n"
        + "validate__japanese スキルは textlint による機械的リント・文中ハードラップの連結・"
        + "文中改行の最終探索・AI 臭レビューへの引き継ぎ判定を行う。いま次を適用すること:\n"
        + "1. Skill ツールで validate__japanese を起動し、いま編集したファイルを対象として渡す。\n"
        + "2. スキルの全フェーズを完了させる (レポートの出力と引き継ぎ判定まで)。\n\n"
        + "例外: validate__japanese の実行中にこの通知を受け取った場合は、進行中の実行がこの要求を満たす。"
        + "新たに起動し直してはならない。\n\n"
        + "日本語リントが完了するまで、他のタスクへ進んではならない。";

    private static async Task<int> Main()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName is not ("Write" or "Edit"))
            return 0;

        var filePath = hook.ToolInput?.FilePath ?? "";
        if (filePath.Length == 0)
            return 0;
        if (!JapaneseMarkdown.IsMarkdown(filePath))
            return 0;
        if (!File.Exists(filePath))
            return 0;
        if (!JapaneseMarkdown.ContainsJapanese(filePath))
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
