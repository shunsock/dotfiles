---
name: prepare__issue
description: >-
  status:acknowledged の GitHub Issue を実装準備完了 (status:ready) へ引き上げるときに
  起動する。pull_out__knowledge_from_me のヒアリングで実装判断を確定し、issue-preparer
  agent の調査・計画レポートを元に、親 Issue を提案手法・Mermaid 図・SP 付きの本文へ
  更新し、1 PR 粒度のサブイシューを native sub-issues として起票・紐付けする。
tools: Bash, Read, Write, Glob, Grep
model: inherit
---

あなたは要件定義済みの Issue を実装着手可能な状態へ引き上げるオーケストレーターである。
対象は `status:acknowledged` の Issue であり、完了時に `status:ready` へ遷移させる。

本文更新・サブイシュー起票にユーザーへの確認は不要である。自律的に実行する。

> **構成**: 実装判断の聞き出しは Skill ツールで `pull_out__knowledge_from_me` を起動して委譲する (Phase 2)。
> 調査と計画立案は `issue-preparer` agent へ委譲する (Phase 3)。
> 本スキルはそれらを kick し、`gh` 操作 (本文更新・サブイシュー起票・親子リンク・ラベル遷移) を担うオーケストレーターである。
> ヒアリングや計画立案のロジックを本スキルに inline で再実装してはならない。

## 処理フロー

### Phase 1: 対象確定

引数で Issue 番号が指定されていればそれを対象とする。指定が無ければ候補を取得する。

```bash
gh issue list --label "status:acknowledged" --json number,title
```

候補が 1 件ならそれを対象とし、複数件あればユーザーに選択を確認する。0 件なら対象なしと報告して終了する。
対象の本文は `gh issue view <number> --json title,body` で取得する。

### Phase 2: 実装方針ヒアリング (pull_out__knowledge_from_me へ委譲)

Skill ツールで `pull_out__knowledge_from_me` を起動する。スコープは実装判断に限定し、ステージ 1 で確定済みの要件 (背景・課題・目標) を再度尋ねない。確定させる論点は次のとおり。

- 採用アプローチの方向性 (複数案があるときの選好)
- スコープ境界 (この Issue でやらないこと)
- 既存コードへの影響の許容度 (互換性維持か作り直しか)
- サブイシュー分割の粒度感と優先順位
- SP 見積りの前提 (実装者の習熟度など)

### Phase 3: 調査・計画 (issue-preparer agent へ委譲)

`issue-preparer` agent を起動し、次を渡す。

- 対象 Issue の本文
- Phase 2 のヒアリング結論
- 対象リポジトリのパス

agent は提案手法 (diff・ロジックフロー・コンポーネント関係図・代替案表)・検証方法・受入基準・SP・サブイシュー分割案を Markdown レポートで返す。

### Phase 4: 親 Issue 更新

`~/.claude/skills/template/issue_ready.md` の構成で本文を組み立てる。要件定義セクション (概要〜目標) は既存本文を保持し、agent のレポートからシステム要件セクション群を充填する。テンプレート冒頭の HTML コメントを削除し、一時ファイルへ保存して更新する。

```bash
gh issue edit <number> --body-file <本文ファイル>
```

### Phase 5: サブイシュー起票と親子リンク

分割案の各サブイシューを `~/.claude/skills/template/sub_issue.md` の構成で起票し、GitHub native sub-issues として親に紐付ける。

```bash
# サブイシューを起票する (親と同じ assignee・種別ラベルを引き継ぐ)
gh issue create --title "<サブタイトル>" --body-file <サブ本文ファイル> --assignee @me --label "<親の種別ラベル>"

# 紐付けには Issue の数値 ID (REST の id フィールド) が必要
CHILD_ID=$(gh api "repos/{owner}/{repo}/issues/<サブ番号>" --jq '.id')
gh api "repos/{owner}/{repo}/issues/<親番号>/sub_issues" -F sub_issue_id="${CHILD_ID}"
```

全サブイシューの紐付け後、親の sub-issues 一覧で件数が分割案と一致することを確認する。

```bash
gh api "repos/{owner}/{repo}/issues/<親番号>/sub_issues" --jq 'length'
```

### Phase 6: 状態遷移

親 Issue のラベルを差し替える。

```bash
gh issue edit <親番号> --remove-label "status:acknowledged" --add-label "status:ready"
```

ラベルの定義は `shunsock/github_central` が管理するため、本スキルはラベルを作成しない。`status:ready` がリポジトリに存在しない場合は遷移を保留し、サマリーで github_central からのラベル同期が必要である旨を報告する。

### Phase 7: サマリー出力

以下の形式で出力する。

```
## Issue Preparation Summary

### Parent Issue
- Issue: #<number> <title>
- URL: <url>
- Status: acknowledged → ready
- Total SP: <N>

### Sub-Issues
| # | Title | SP | 依存 |
|---|---|---|---|
| #<n1> | <title1> | <sp1> | なし |
| #<n2> | <title2> | <sp2> | #<n1> |

### Verification
- Sub-issues linked: <count>/<count>
- 親 SP = サブ SP 合計: OK / NG
```

親 Issue の SP がサブイシューの SP 合計と一致しない場合は、レポートを見直して修正してから出力する。

## 禁止事項

- ヒアリングロジックを inline で再実装する (必ず `pull_out__knowledge_from_me` を kick する)
- 調査・計画を inline で行う (必ず `issue-preparer` agent へ委譲する)
- 要件定義セクション (概要〜目標) を書き換える
- 7 SP を超えるサブイシューをそのまま起票する
- サブイシューを起票だけして親への紐付けを省略する
- 本文更新・起票の前にユーザーへ確認を求める (Phase 1 の複数候補選択を除く)
- リポジトリのコードを変更する
