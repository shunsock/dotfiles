// validate_comment_format.cs - PostToolUse(Write|Edit) フック。
// ソース編集後にコメントを走査し、語彙とフォーマットの違反を検出して修正を促す。
// 制約: マーカー始まり、2 行以内、80 文字以内、issue/PR 番号なし。
// doc コメントと先頭ヘッダは例外とする。
// SEE: ~/.claude/skills/template/comment_markers.md
// SEE: ~/.claude/hooks/README.md

using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Text.RegularExpressions;

internal enum Family
{
    Slash,
    Hash,
    Dash,
}

internal enum SlashKind
{
    DocBlock,
    Block,
    DocLine,
    LineComment,
    Code,
}

internal readonly record struct Violation(int Line, string Kind, string Snippet);

internal readonly record struct FormatRules(int MaxLines, int MaxWidth);

internal readonly record struct CommentLine(int Number, string Text, int Width);

internal sealed record LogicalComment(
    int StartLine,
    bool HasMarker,
    IReadOnlyList<CommentLine> Lines
);

internal sealed record ScannerConfig(
    IReadOnlySet<string> Extensions,
    Regex MarkerStart,
    Regex IssueRef,
    FormatRules Rules
);

internal static class Vocabulary
{
    // SEE: ~/.claude/skills/template/comment_markers.md
    public static readonly IReadOnlyList<string> Markers =
    [
        "TODO",
        "FIXME",
        "SEE",
        "CONSTRAINT",
        "NOTE",
        "HACK",
        "SAFETY",
    ];

    public static readonly FormatRules DefaultRules = new(MaxLines: 2, MaxWidth: 80);

    public const string IssuePattern =
        @"#\d+|\bGH-\d+\b|\b(?:issues?|pull)/\d+|\b(?:issue|pr)\b\s*#?\s*\d+";

    public static Regex MarkerRegex() =>
        new($"^(?:{string.Join('|', Markers)})\\b", RegexOptions.Compiled);

    public static Regex IssueRegex() =>
        new(IssuePattern, RegexOptions.Compiled | RegexOptions.IgnoreCase);
}

internal static class Tokens
{
    public const string Line = "//";
    public const string Hash = "#";
    public const string Dash = "--";
    public const string DocLine = "///";
    public const string InnerDocLine = "//!";
    public const string BlockOpen = "/*";
    public const string DocBlockOpen = "/**";
    public const string InnerDocBlockOpen = "/*!";
    public const string BlockClose = "*/";
    public const string Shebang = "#!";
}

internal static class Language
{
    public static Family? FamilyOf(string ext) =>
        ext.ToLowerInvariant() switch
        {
            ".rs"
            or ".go"
            or ".ts"
            or ".tsx"
            or ".js"
            or ".jsx"
            or ".java"
            or ".kt"
            or ".kts"
            or ".c"
            or ".h"
            or ".cpp"
            or ".cc"
            or ".hpp"
            or ".cs"
            or ".php"
            or ".swift"
            or ".scala"
            or ".dart" => Family.Slash,
            ".py" or ".rb" or ".sh" or ".bash" or ".zsh" or ".nix" or ".ex" or ".exs" =>
                Family.Hash,
            ".lua" or ".hs" => Family.Dash,
            _ => null,
        };

    public static string LineToken(Family family) =>
        family switch
        {
            Family.Hash => Tokens.Hash,
            Family.Dash => Tokens.Dash,
            _ => Tokens.Line,
        };
}

internal static class ExtensionSource
{
    // SEE: ~/.claude/skills/reference/comment_out_skills_target/extensions.csv
    public static IReadOnlySet<string> Load()
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
}

internal sealed class CommentScanner(ScannerConfig config)
{
    public IReadOnlyList<Violation> Scan(string[] lines, Family family)
    {
        var headerLimit = FirstCodeLine(lines, family);
        var comments = Collect(lines, family);
        var violations = new List<Violation>();
        foreach (var comment in comments)
            CheckComment(comment, comment.StartLine < headerLimit, violations);
        return violations;
    }

    private IReadOnlyList<LogicalComment> Collect(string[] lines, Family family) =>
        family switch
        {
            Family.Slash => CollectSlash(lines),
            Family.Hash => CollectPrefix(lines, Tokens.Hash, shebangAware: true),
            _ => CollectPrefix(lines, Tokens.Dash, shebangAware: false),
        };

    private static int FirstCodeLine(string[] lines, Family family)
    {
        var inBlock = false;
        for (var i = 0; i < lines.Length; i++)
        {
            var trimmed = lines[i].TrimStart();
            if (trimmed.Length == 0)
                continue;
            var isCode = family switch
            {
                Family.Slash => !SlashLineIsComment(trimmed, ref inBlock),
                _ => !trimmed.StartsWith(Language.LineToken(family)),
            };
            if (isCode)
                return i + 1;
        }
        return int.MaxValue;
    }

    private static bool SlashLineIsComment(string trimmed, ref bool inBlock)
    {
        if (inBlock)
        {
            if (trimmed.Contains(Tokens.BlockClose))
                inBlock = false;
            return true;
        }
        if (trimmed.StartsWith(Tokens.BlockOpen))
        {
            if (!trimmed.Contains(Tokens.BlockClose))
                inBlock = true;
            return true;
        }
        return trimmed.StartsWith(Tokens.Line);
    }

    private void CheckComment(LogicalComment comment, bool isHeader, List<Violation> violations)
    {
        if (!isHeader && !comment.HasMarker)
            violations.Add(new(comment.StartLine, "マーカー語彙なし", FirstText(comment)));
        if (!isHeader && comment.Lines.Count > config.Rules.MaxLines)
            violations.Add(
                new(
                    comment.StartLine,
                    $"{config.Rules.MaxLines + 1}行以上 (最大{config.Rules.MaxLines}行)",
                    FirstText(comment)
                )
            );
        foreach (var line in comment.Lines)
        {
            if (line.Width > config.Rules.MaxWidth)
                violations.Add(
                    new(
                        line.Number,
                        $"{config.Rules.MaxWidth}文字超過 ({line.Width}文字)",
                        line.Text
                    )
                );
            if (config.IssueRef.IsMatch(line.Text))
                violations.Add(new(line.Number, "issue/PR 番号を含む", line.Text));
        }
    }

    private static string FirstText(LogicalComment comment) =>
        comment.Lines.Count > 0 ? comment.Lines[0].Text : "";

    private void SplitRun(IReadOnlyList<CommentLine> run, List<LogicalComment> sink)
    {
        var i = 0;
        while (i < run.Count)
        {
            var group = new List<CommentLine> { run[i] };
            var hasMarker = config.MarkerStart.IsMatch(run[i].Text);
            i++;
            while (i < run.Count && !config.MarkerStart.IsMatch(run[i].Text))
            {
                group.Add(run[i]);
                i++;
            }
            sink.Add(new LogicalComment(group[0].Number, hasMarker, group));
        }
    }

    private static SlashKind ClassifySlash(string trimmed) =>
        trimmed switch
        {
            _ when trimmed.StartsWith(Tokens.DocBlockOpen)
                    || trimmed.StartsWith(Tokens.InnerDocBlockOpen) => SlashKind.DocBlock,
            _ when trimmed.StartsWith(Tokens.BlockOpen) => SlashKind.Block,
            _ when trimmed.StartsWith(Tokens.DocLine) || trimmed.StartsWith(Tokens.InnerDocLine) =>
                SlashKind.DocLine,
            _ when trimmed.StartsWith(Tokens.Line) => SlashKind.LineComment,
            _ => SlashKind.Code,
        };

    private IReadOnlyList<LogicalComment> CollectSlash(string[] lines)
    {
        var result = new List<LogicalComment>();
        var i = 0;
        while (i < lines.Length)
        {
            i = ClassifySlash(lines[i].TrimStart()) switch
            {
                SlashKind.DocBlock => SkipBlock(lines, i),
                SlashKind.Block => CollectBlock(lines, i, result),
                SlashKind.LineComment => CollectLineRun(lines, i, result),
                _ => i + 1,
            };
        }
        return result;
    }

    private static int SkipBlock(string[] lines, int start)
    {
        var i = start;
        while (i < lines.Length)
        {
            var closes = lines[i].Contains(Tokens.BlockClose);
            i++;
            if (closes)
                break;
        }
        return i;
    }

    private int CollectBlock(string[] lines, int start, List<LogicalComment> sink)
    {
        var body = new List<CommentLine>();
        var i = start;
        while (i < lines.Length)
        {
            var stripped = lines[i]
                .Replace(Tokens.BlockOpen, "")
                .Replace(Tokens.BlockClose, "")
                .TrimStart()
                .TrimStart('*')
                .Trim();
            body.Add(new CommentLine(i + 1, stripped, WidthOf(lines[i])));
            var closes = lines[i].Contains(Tokens.BlockClose);
            i++;
            if (closes)
                break;
        }
        var hasMarker = body.Any(line => config.MarkerStart.IsMatch(line.Text));
        sink.Add(new LogicalComment(start + 1, hasMarker, body));
        return i;
    }

    private int CollectLineRun(string[] lines, int start, List<LogicalComment> sink)
    {
        var run = new List<CommentLine>();
        var i = start;
        while (i < lines.Length)
        {
            var trimmed = lines[i].TrimStart();
            if (
                trimmed.StartsWith(Tokens.DocLine)
                || trimmed.StartsWith(Tokens.InnerDocLine)
                || !trimmed.StartsWith(Tokens.Line)
            )
                break;
            run.Add(new CommentLine(i + 1, trimmed[2..].Trim(), WidthOf(lines[i])));
            i++;
        }
        SplitRun(run, sink);
        return i;
    }

    private IReadOnlyList<LogicalComment> CollectPrefix(
        string[] lines,
        string token,
        bool shebangAware
    )
    {
        var result = new List<LogicalComment>();
        var i = 0;
        while (i < lines.Length)
        {
            if (i == 0 && shebangAware && lines[i].TrimStart().StartsWith(Tokens.Shebang))
            {
                i++;
                continue;
            }
            if (!lines[i].TrimStart().StartsWith(token))
            {
                i++;
                continue;
            }
            var run = new List<CommentLine>();
            while (i < lines.Length)
            {
                var trimmed = lines[i].TrimStart();
                if (i == 0 && shebangAware && trimmed.StartsWith(Tokens.Shebang))
                    break;
                if (!trimmed.StartsWith(token))
                    break;
                run.Add(
                    new CommentLine(i + 1, trimmed.TrimStart(token[0]).Trim(), WidthOf(lines[i]))
                );
                i++;
            }
            SplitRun(run, result);
        }
        return result;
    }

    private static int WidthOf(string raw) => raw.TrimEnd().Length;
}

internal static class ViolationReporter
{
    public static string Build(
        string path,
        IReadOnlyList<Violation> violations,
        IReadOnlyList<string> markers
    )
    {
        var sb = new StringBuilder();
        sb.Append($"ソースファイルが Write/Edit されました: {path}\n\n");
        sb.Append(
            "[必須アクション] このファイルのコメントに、共有 whitelist 語彙・フォーマット制約への違反が見つかった。"
        );
        sb.Append("ただちに違反を修正しなければならない。省略・ユーザー確認は不要である。\n\n");
        sb.Append("検出された違反 (行: 種別 — 該当コメント):\n");
        foreach (var v in violations.Take(30))
        {
            var snippet = v.Snippet.Length > 60 ? v.Snippet[..60] + "…" : v.Snippet;
            sb.Append($"- L{v.Line}: {v.Kind} — {snippet}\n");
        }
        if (violations.Count > 30)
            sb.Append($"- (ほか {violations.Count - 30} 件)\n");
        sb.Append(
            "\n共有ルール (single source of truth: `~/.claude/skills/template/comment_markers.md`) に従い修正する:\n"
        );
        sb.Append(
            $"1. すべてのコメントは whitelist マーカー ({string.Join('/', markers)}) で始める。始まらないコメントは、コードを直す/モデル化する/削除するのいずれかで解消する (マーカーを機械的に足すだけにしない)。\n"
        );
        sb.Append(
            "2. 1 論理コメントは最大 2 行。3 行以上に渡るなら短く要約するか、コメントに収めない。\n"
        );
        sb.Append("3. 1 行は最大 80 文字。短く簡潔に言い換える。\n");
        sb.Append(
            "4. issue/PR 番号 (#123・GH-123・issues/123・pull/123・issue/PR の URL) を取り除く。外部参照は RFC・仕様・ベンダー doc・ファイルパスに限り SEE で書く。\n"
        );
        sb.Append(
            "5. doc コメント (rustdoc /// ・JSDoc /** */ ・docstring) と先頭のモジュールヘッダは対象外。コメントのみ編集し、コードの挙動は変えない。\n\n"
        );
        sb.Append("すべての違反を解消するまで、他のタスクへ進んではならない。");
        return sb.ToString();
    }
}

internal static class HookIo
{
    public static async Task<string?> ReadEditedFilePathAsync()
    {
        var input = await Console.In.ReadToEndAsync();
        var hook = JsonSerializer.Deserialize(input, HookJson.Default.HookInput);
        if (hook?.ToolName is not ("Write" or "Edit"))
            return null;
        var path = hook.ToolInput?.FilePath ?? "";
        return path.Length == 0 ? null : path;
    }

    public static void WriteContext(string context)
    {
        var output = new Output(new HookSpecificOutput("PostToolUse", context));
        Console.WriteLine(JsonSerializer.Serialize(output, HookJson.Default.Output));
    }
}

internal static class Program
{
    private static async Task<int> Main()
    {
        var config = new ScannerConfig(
            ExtensionSource.Load(),
            Vocabulary.MarkerRegex(),
            Vocabulary.IssueRegex(),
            Vocabulary.DefaultRules
        );

        var path = await HookIo.ReadEditedFilePathAsync();
        if (path is null)
            return 0;
        if (!config.Extensions.Contains(Path.GetExtension(path)))
            return 0;
        if (Language.FamilyOf(Path.GetExtension(path)) is not { } family)
            return 0;
        if (!File.Exists(path))
            return 0;

        var violations = new CommentScanner(config).Scan(File.ReadAllLines(path), family);
        if (violations.Count == 0)
            return 0;

        HookIo.WriteContext(ViolationReporter.Build(path, violations, Vocabulary.Markers));
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
