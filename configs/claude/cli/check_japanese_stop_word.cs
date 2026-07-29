// check_japanese_stop_word.cs - AI が下書きした日本語に混ざる不自然な語彙を検出する CLI。
// 引数のファイルを 1 行ずつ走査し、stop_word.csv の禁止語彙を見つけたら stderr へ
// 言い換え先を提案する。終了コード: 0 = 検出なし, 1 = 検出あり, 2 = 引数誤り。
// 実行は AOT ビルドせず `dotnet run check_japanese_stop_word.cs -- <file>...` で
// 単一ファイルのまま行う (hooks/README.md の設計判断と同じ)。
// SEE: ~/.claude/skills/reference/japanese_stop_word/stop_word.csv

internal sealed record StopWord(string Word, string Replacement);

internal readonly record struct Finding(
    string Path,
    int LineNumber,
    StopWord StopWord,
    string Snippet
);

internal readonly record struct CliArguments(string CsvPath, IReadOnlyList<string> Files);

internal static class StopWordSource
{
    public static string DefaultCsvPath()
    {
        var home = Environment.GetEnvironmentVariable("HOME") ?? "";
        return Path.Combine(
            home,
            ".claude",
            "skills",
            "reference",
            "japanese_stop_word",
            "stop_word.csv"
        );
    }

    public static IReadOnlyList<StopWord> Load(string csvPath)
    {
        if (!File.Exists(csvPath))
            return [];
        return File.ReadLines(csvPath)
            .Skip(1)
            .Select(line => line.Split(','))
            .Where(columns => columns.Length >= 2 && columns[0].Trim().Length > 0)
            .Select(columns => new StopWord(columns[0].Trim(), columns[1].Trim()))
            .OrderByDescending(stopWord => stopWord.Word.Length)
            .ToList();
    }
}

internal static class LineScanner
{
    public static IReadOnlyList<StopWord> MatchedWords(
        string line,
        IReadOnlyList<StopWord> stopWords
    )
    {
        var claimed = new List<(int Start, int End)>();
        return stopWords.Where(stopWord => HasUnclaimedMatch(line, stopWord.Word, claimed)).ToList();
    }

    private static bool HasUnclaimedMatch(string line, string word, List<(int Start, int End)> claimed)
    {
        var found = false;
        var index = line.IndexOf(word, StringComparison.Ordinal);
        while (index >= 0)
        {
            var candidate = (Start: index, End: index + word.Length);
            var overlaps = claimed.Any(range =>
                candidate.Start < range.End && range.Start < candidate.End
            );
            if (!overlaps)
            {
                claimed.Add(candidate);
                found = true;
            }
            index = line.IndexOf(word, index + 1, StringComparison.Ordinal);
        }
        return found;
    }
}

internal static class FileScanner
{
    private const int SnippetWidth = 60;

    public static IReadOnlyList<Finding> Scan(string path, IReadOnlyList<StopWord> stopWords)
    {
        var findings = new List<Finding>();
        var lineNumber = 0;
        foreach (var line in File.ReadLines(path))
        {
            lineNumber++;
            foreach (var stopWord in LineScanner.MatchedWords(line, stopWords))
                findings.Add(new Finding(path, lineNumber, stopWord, Snip(line)));
        }
        return findings;
    }

    private static string Snip(string line)
    {
        var trimmed = line.Trim();
        return trimmed.Length > SnippetWidth ? trimmed[..SnippetWidth] + "…" : trimmed;
    }
}

internal static class Reporter
{
    public static void Write(TextWriter writer, IEnumerable<Finding> findings)
    {
        foreach (var finding in findings)
            writer.WriteLine(
                $"{finding.Path}:{finding.LineNumber}: "
                    + $"「{finding.StopWord.Word}」は不自然な語彙です。"
                    + $"「{finding.StopWord.Replacement}」への言い換えを提案します"
                    + $" — {finding.Snippet}"
            );
    }
}

internal static class Program
{
    private static int Main(string[] args)
    {
        var arguments = ParseArguments(args);
        if (arguments.Files.Count == 0)
        {
            Console.Error.WriteLine(
                "usage: dotnet run check_japanese_stop_word.cs [--csv <path>] -- <file> [<file>...]"
            );
            return 2;
        }

        var stopWords = StopWordSource.Load(arguments.CsvPath);
        var findings = arguments
            .Files.Where(File.Exists)
            .SelectMany(file => FileScanner.Scan(file, stopWords))
            .ToList();

        if (findings.Count == 0)
            return 0;

        Reporter.Write(Console.Error, findings);
        return 1;
    }

    private static CliArguments ParseArguments(string[] args)
    {
        var csvPath = StopWordSource.DefaultCsvPath();
        var files = new List<string>();
        for (var i = 0; i < args.Length; i++)
        {
            if (args[i] == "--csv" && i + 1 < args.Length)
            {
                csvPath = args[++i];
                continue;
            }
            files.Add(args[i]);
        }
        return new CliArguments(csvPath, files);
    }
}
