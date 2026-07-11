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

internal static class Markers
{
    // SEE: ~/.claude/skills/reference/comment_out_skills_target/markers.csv
    private static readonly Regex StartsWithMarker = BuildRegex();

    private static Regex BuildRegex()
    {
        var home = Environment.GetEnvironmentVariable("HOME") ?? "";
        var csv = Path.Combine(
            home,
            ".claude",
            "skills",
            "reference",
            "comment_out_skills_target",
            "markers.csv"
        );
        var names = new List<string>();
        if (File.Exists(csv))
        {
            foreach (var line in File.ReadLines(csv))
            {
                var token = line.Trim();
                if (token.Length > 0 && token.All(char.IsAsciiLetterUpper))
                    names.Add(Regex.Escape(token));
            }
        }
        if (names.Count == 0)
            names.AddRange(["TODO", "FIXME", "SEE", "CONSTRAINT", "NOTE", "HACK", "SAFETY"]);
        return new Regex($"^(?:{string.Join('|', names)})\\b", RegexOptions.Compiled);
    }

    public static bool StartsMarker(string commentText) => StartsWithMarker.IsMatch(commentText);
}

internal enum Family
{
    Slash,
    Hash,
    Dash,
}

internal readonly record struct Violation(int Line, string Kind, string Snippet);

internal sealed class LogicalComment
{
    public int StartLine { get; init; }
    public bool HasMarker { get; init; }
    public List<(int Line, string Text, int Width)> Lines { get; } = [];
}

internal static class CommentScanner
{
    private const int MaxLines = 2;
    private const int MaxWidth = 80;

    private static readonly Regex IssueRef = new(
        @"#\d+|\bGH-\d+\b|\b(?:issues?|pull)/\d+|\b(?:issue|pr)\b\s*#?\s*\d+",
        RegexOptions.Compiled | RegexOptions.IgnoreCase
    );

    private static Family? FamilyOf(string ext) =>
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

    public static List<Violation> Scan(string filePath)
    {
        var family = FamilyOf(Path.GetExtension(filePath));
        if (family is null || !File.Exists(filePath))
            return [];

        var lines = File.ReadAllLines(filePath);
        var headerLimit = FirstCodeLine(lines, family.Value);
        var comments = family switch
        {
            Family.Slash => CollectSlash(lines),
            Family.Hash => CollectPrefix(lines, "#", shebangAware: true),
            _ => CollectPrefix(lines, "--", shebangAware: false),
        };

        var violations = new List<Violation>();
        foreach (var c in comments)
            Check(c, violations, isHeader: c.StartLine < headerLimit);
        return violations;
    }

    private static int FirstCodeLine(string[] lines, Family family)
    {
        var inBlock = false;
        for (var i = 0; i < lines.Length; i++)
        {
            var t = lines[i].TrimStart();
            if (t.Length == 0)
                continue;
            if (family == Family.Slash)
            {
                if (inBlock)
                {
                    if (t.Contains("*/"))
                        inBlock = false;
                    continue;
                }
                if (t.StartsWith("/*"))
                {
                    if (!t.Contains("*/"))
                        inBlock = true;
                    continue;
                }
                if (t.StartsWith("//"))
                    continue;
                return i + 1;
            }
            var token = family == Family.Hash ? "#" : "--";
            if (t.StartsWith(token))
                continue;
            return i + 1;
        }
        return int.MaxValue;
    }

    private static void Check(LogicalComment c, List<Violation> violations, bool isHeader)
    {
        if (!isHeader && !c.HasMarker)
            violations.Add(new(c.StartLine, "マーカー語彙なし", First(c)));
        if (!isHeader && c.Lines.Count > MaxLines)
            violations.Add(new(c.StartLine, $"{MaxLines + 1}行以上 (最大{MaxLines}行)", First(c)));
        foreach (var (line, text, width) in c.Lines)
        {
            if (width > MaxWidth)
                violations.Add(new(line, $"{MaxWidth}文字超過 ({width}文字)", text));
            if (IssueRef.IsMatch(text))
                violations.Add(new(line, "issue/PR 番号を含む", text));
        }
    }

    private static string First(LogicalComment c) => c.Lines.Count > 0 ? c.Lines[0].Text : "";

    private static void SplitRun(
        List<(int Line, string Text, int Width)> run,
        List<LogicalComment> sink
    )
    {
        LogicalComment? current = null;
        foreach (var entry in run)
        {
            var isMarker = Markers.StartsMarker(entry.Text);
            if (isMarker || current is null)
            {
                current = new LogicalComment { StartLine = entry.Line, HasMarker = isMarker };
                sink.Add(current);
            }
            current.Lines.Add(entry);
        }
    }

    private static int Width(string raw) => raw.TrimEnd().Length;

    private static List<LogicalComment> CollectSlash(string[] lines)
    {
        var result = new List<LogicalComment>();
        var i = 0;
        while (i < lines.Length)
        {
            var trimmed = lines[i].TrimStart();

            if (trimmed.StartsWith("/**") || trimmed.StartsWith("/*!"))
            {
                i = SkipBlock(lines, i);
                continue;
            }
            if (trimmed.StartsWith("/*"))
            {
                i = CollectBlock(lines, i, result);
                continue;
            }
            if (trimmed.StartsWith("///") || trimmed.StartsWith("//!"))
            {
                i++;
                continue;
            }
            if (trimmed.StartsWith("//"))
            {
                var run = new List<(int, string, int)>();
                while (i < lines.Length)
                {
                    var t = lines[i].TrimStart();
                    if (t.StartsWith("///") || t.StartsWith("//!") || !t.StartsWith("//"))
                        break;
                    run.Add((i + 1, t[2..].Trim(), Width(lines[i])));
                    i++;
                }
                SplitRun(run, result);
                continue;
            }
            i++;
        }
        return result;
    }

    private static int SkipBlock(string[] lines, int start)
    {
        var i = start;
        while (i < lines.Length)
        {
            var closes = lines[i].Contains("*/");
            i++;
            if (closes)
                break;
        }
        return i;
    }

    private static int CollectBlock(string[] lines, int start, List<LogicalComment> sink)
    {
        var i = start;
        var body = new List<(int, string, int)>();
        while (i < lines.Length)
        {
            var stripped = lines[i]
                .Replace("/*", "")
                .Replace("*/", "")
                .TrimStart()
                .TrimStart('*')
                .Trim();
            body.Add((i + 1, stripped, Width(lines[i])));
            var closes = lines[i].Contains("*/");
            i++;
            if (closes)
                break;
        }
        var comment = new LogicalComment
        {
            StartLine = start + 1,
            HasMarker = body.Any(b => Markers.StartsMarker(b.Item2)),
        };
        comment.Lines.AddRange(body);
        sink.Add(comment);
        return i;
    }

    private static List<LogicalComment> CollectPrefix(
        string[] lines,
        string token,
        bool shebangAware
    )
    {
        var result = new List<LogicalComment>();
        var i = 0;
        while (i < lines.Length)
        {
            if (i == 0 && shebangAware && lines[i].TrimStart().StartsWith("#!"))
            {
                i++;
                continue;
            }
            var trimmed = lines[i].TrimStart();
            if (!trimmed.StartsWith(token))
            {
                i++;
                continue;
            }
            var run = new List<(int, string, int)>();
            while (i < lines.Length)
            {
                var t = lines[i].TrimStart();
                if (i == 0 && shebangAware && t.StartsWith("#!"))
                    break;
                if (!t.StartsWith(token))
                    break;
                run.Add((i + 1, t.TrimStart(token[0]).Trim(), Width(lines[i])));
                i++;
            }
            SplitRun(run, result);
        }
        return result;
    }
}

internal static class Program
{
    private static string BuildContext(string path, List<Violation> violations)
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
            "1. すべてのコメントは whitelist マーカー (TODO/FIXME/SEE/CONSTRAINT/NOTE/HACK/SAFETY) で始める。始まらないコメントは、コードを直す/モデル化する/削除するのいずれかで解消する (マーカーを機械的に足すだけにしない)。\n"
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

        var violations = CommentScanner.Scan(filePath);
        if (violations.Count == 0)
            return 0;

        var output = new Output(
            new HookSpecificOutput("PostToolUse", BuildContext(filePath, violations))
        );
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
