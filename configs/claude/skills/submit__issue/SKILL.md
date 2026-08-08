---
name: submit__issue
description: >-
  ユーザーが GitHub Issue を起票したいときに起動する。pull_out__knowledge_from_me の
  インタビューで要件 (背景・課題・目標・受入基準) を確定し、issue-writer agent が
  要件定義テンプレートを充填した本文を、ラベル自動選択・assignee 付与つきで
  status:acknowledged として確認なしに起票する。起票後は prepare__issue の実行を推薦する。
tools: Bash, Read, Write, Glob, Grep
model: inherit
---

あなたは要件インタビューから起票までを一貫して実行するオーケストレーターである。
Issue はステージ 1 (要件定義済み = `status:acknowledged`) として起票し、システム要件の具体化はステージ 2 の `prepare__issue` に委ねる。

起票にユーザーへの確認は不要である。自律的に実行する。

> **構成**: 要件の聞き出しは Skill ツールで `pull_out__knowledge_from_me` を起動して委譲する (Phase 1)。
> 本文生成は `issue-writer` agent へ委譲する (Phase 2)。
> 本スキルはそれらを kick し、`gh` 操作 (ラベル・assignee・起票) を担うオーケストレーターである。
> インタビューや本文生成のロジックを本スキルに inline で再実装してはならない。

## 処理フロー

### Phase 1: 要件インタビュー (pull_out__knowledge_from_me へ委譲)

Skill ツールで `pull_out__knowledge_from_me` を起動する。このフェーズで確定させる論点は次のとおり。

- Issue の種別 (バグ報告 / 機能開発)。バグなら根本原因の手がかり、機能ならユーザーストーリー
- 背景 (なぜ今取り組むのか) と課題 (現状の何が問題か)
- 目標 (解決後の理想像)
- 受入基準 (利用者・ビジネス観点で計測可能な Close 条件)

実装手段 (提案手法・SP・分割) はこのフェーズでは扱わない。ステージ 2 の `prepare__issue` が担う。
ユーザーの依頼に十分な情報が揃っている場合、インタビューは確認だけで短く終えてよい。

### Phase 2: 本文生成 (issue-writer agent へ委譲)

`issue-writer` agent を起動し、次を渡す。

- Issue の種別
- Phase 1 の共通理解の要約
- 対象リポジトリのパスと関連リンク

agent は 1 行目に `TITLE: <タイトル案>`、2 行目以降に `issue_acknowledged.md` を充填した本文を返す。
本文を一時ファイルに保存して Phase 3 で使う。

### Phase 3: 自動起票

ユーザーへの確認なしで実行する。

```bash
# 既存ラベルを取得し、Issue の内容に合うラベル (bug / enhancement など) を選ぶ
gh label list --json name,description

# status ラベルが無ければ固定の色・説明で作成する (既存ならスキップ)
gh label create "status:acknowledged" --color FBCA04 --description "要件定義済み・実装準備前" 2>/dev/null || true
gh label create "status:ready" --color 0E8A16 --description "実装準備完了・着手可能" 2>/dev/null || true

# assignee は実行ユーザー
gh issue create --title "<タイトル>" --body-file <本文ファイル> --assignee @me \
  --label "<選択したラベル>,status:acknowledged"
```

ラベル選択の基準: 種別に対応するラベル (バグ報告 → `bug` 系、機能開発 → `enhancement` 系) を最優先し、説明文から内容に合う補助ラベルがあれば加える。合うラベルが無ければ status ラベルのみでよく、新しい種別ラベルを勝手に作らない。

### Phase 4: サマリーと次アクションの推薦

以下の形式で出力する。`prepare__issue` の推薦は省略できない必須項目である。

```
## Issue Submission Summary

### Issue Created
- Issue: #<number>
- Title: <title>
- URL: <url>
- Labels: <labels>
- Assignee: <user>
- Status: acknowledged

### Next Action
この Issue はまだ要件定義のみ (status:acknowledged) です。
実装に着手できる状態 (status:ready) にするには、`prepare__issue` を実行してください。
調査・提案手法・SP 見積り・サブイシュー分割を行い、Issue を実装準備完了へ引き上げます。
```

## 禁止事項

- インタビューロジックを inline で再実装する (必ず `pull_out__knowledge_from_me` を kick する)
- 本文生成を inline で行う (必ず `issue-writer` agent へ委譲する)
- 起票前にユーザーへ確認を求める
- 本文にシステム要件セクション (提案手法・検証方法・作業単位・SP) を含める
- status ラベル以外のラベルを新規作成する
- サマリーで `prepare__issue` の推薦を省略する
