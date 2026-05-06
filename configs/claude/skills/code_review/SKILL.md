---
name: code_review
description: >-
  コードレビューのオーケストレーター。Phase 1 (意図確認) → Phase 2 (技術レビュー) →
  集約レポートの流れで、変更されたコードに対するレビューを行う。コードは書き換えない。
  「コードレビューして」「レビューお願い」「セルフレビュー」「PRレビュー」「変更をチェックして」
  などの文脈で起動される。
tools: Read, Bash, AskUserQuestion, Task
---

## 概要

このスキルはコードレビューの親プロセスとして機能する。
Phase 1 で人間レビュアーが行うような意図確認の対話を行い、
Phase 2 で 7 観点の技術レビューを並列に実施し、
最終的に集約レポートをユーザーに返す。

このスキルおよび配下のサブスキルは **コードを書き換えない**。
レビュー結果に基づく修正は、ユーザーが別途行う。

## Step 1: レビュー対象ファイルの特定

以下の順で対象を取得する。

```bash
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD --short 2>/dev/null)
git diff --name-only --diff-filter=ACMR ${DEFAULT_BRANCH}...HEAD
```

差分が空の場合は staged をチェックする。

```bash
git diff --name-only --diff-filter=ACMR --cached
```

両方とも空なら AskUserQuestion でレビュー対象を尋ねる。

`origin/HEAD` が未設定で `git symbolic-ref` が失敗した場合は、
`git remote set-head origin --auto` を試し、それでも失敗したら
AskUserQuestion で対象を尋ねる。

## Step 2: Phase 1 — 意図確認 (code_interview)

`.claude/skills/code_interview/SKILL.md` の指示に従って起動する。
Step 1 で特定したレビュー対象ファイル一覧を入力として渡す。

出力は「変更要約」と「ユーザーの回答」を含む Markdown。
ユーザーが「質問なし」「先に進んで」と回答した場合、
code_interview は空の回答セクションを返す。それでも Phase 2 には進む。

## Step 3: Phase 2 — 技術レビュー (code_inspect)

`.claude/skills/code_inspect/SKILL.md` の指示に従って起動する。
以下を入力として渡す。

- レビュー対象ファイル一覧
- Phase 1 で得たユーザーの回答 (Markdown のまま)

出力は 7 観点の集約レポート。

## Step 4: 最終レポートの提示

code_inspect の出力をユーザーに提示する。orchestrator 側での加工は不要。
冒頭に Phase 1 の要約を付け加える。

```markdown
# コードレビュー結果

## ユーザーの意図 (Phase 1)
（code_interview の出力から要約・引用）

## 技術レビュー (Phase 2)
（code_inspect の出力をそのまま埋め込む）
```

## エラー処理

code_interview または code_inspect がエラーで返った場合、
code_review は処理を中止してユーザーにエラー内容を報告する。
部分的な結果は提示しない。

## 禁止事項

- Edit / Write を使わない。このスキルはレビューに専念し、修正は行わない
- Phase 1 をスキップしない。ユーザーが質問なしと答えても、code_interview は必ず呼ぶ
