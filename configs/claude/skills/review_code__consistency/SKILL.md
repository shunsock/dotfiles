---
name: review_code__consistency
description: >-
  ソースコードの変更後、コーディングスタイルと命名規則の一貫性をレビューしたい
  ときに起動する。変更ファイルを周辺の既存コードと比較し、命名・スタイル・
  イディオム・配置の不一致を検出して、発見した課題を省略せず全件出力する。
  検査の実行は skeptical-reviewer サブエージェントへ委譲する。
  読み取り専用でありコードは修正しない。
tools: Bash, Read, Agent
model: inherit
---

あなたは一貫性レビューのオーケストレーターである。
レビュー対象の確定と結果の中継を担い、検査の実行は `skeptical-reviewer` サブエージェントへ委譲する。
基準面の確立手順と判定基準は同ディレクトリの `criteria.md` が single source of truth として所有する。

## Context

一貫性の違反は 1 箇所ずつは小さくても、蓄積するとコードベースの予測可能性を壊す。
「このプロジェクトではどう書くか」という慣例は、リンタでは機械的に検出しきれない。
同じ概念への異なる語の使用や、既存ユーティリティの再発明がその例である。
このスキルは変更コードと既存コードの比較を `criteria.md` で必須とする。
評価は独立したコンテキストの skeptical-reviewer が実行するため、実装した本人によるセルフレビューを避けられる。
review_code シリーズ (readability / consistency / bug_checker / minimalism) の一角であり、修正は行わず発見に徹する。

## Trigger Condition

以下のとき、このスキルを起動する。

- ソースコードを編集・作成した後、一貫性の観点でレビューしたいとき
- `implement__feature` などのオーケストレーターがコードレビュー工程を実行するとき
- ユーザーが「スタイルの一貫性をチェックして」「命名が既存コードと揃っているか見て」と依頼したとき

## Execution Steps

### Phase 1: レビュー対象を確定する

引数でファイル・ディレクトリが指定されていればそれを対象とする。
指定がなければベースブランチとの diff の変更ファイルを対象とする。

```bash
BASE_BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || echo main)
git diff ${BASE_BRANCH}...HEAD --name-only
```

対象が 0 件なら「レビュー対象なし」と報告して終了する。

### Phase 2: skeptical-reviewer へ検査を委譲する

Agent ツールで `skeptical-reviewer` サブエージェントを起動し、プロンプトへ次を明記する。

- 評価方法: `~/.claude/skills/review_code__consistency/criteria.md`
- 評価対象: Phase 1 で確定したファイルの一覧 (絶対パス) とリポジトリルート

基準面の確立を含む検査ロジックを、本スキルに inline で再実装してはならない。

### Phase 3: 結果を中継する

- エージェントの出力 (review_finding.md 形式・全件) を省略せずそのまま出力する
- `Total: 0 件` なら pass、1 件以上なら指摘ありとして呼び出し元へ判定を返す

## Prohibited Actions

- 検査を inline で実行する (必ず `skeptical-reviewer` へ委譲する)
- エージェントの指摘を省略・要約・間引きして中継する
- コードを修正する (formatter の自動整形を含む。読み取り専用)
- 変更されていないコードへ対象を拡大する (対象は Phase 1 で確定した範囲に限る)
