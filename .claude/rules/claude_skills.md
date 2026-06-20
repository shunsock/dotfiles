---
paths:
  - "configs/claude/skills/**"
---

# Claude スキルの命名規則

`configs/claude/skills/` 配下のスキルは `<動詞>__<目的語>` 形式で命名する。
ディレクトリ名と `SKILL.md` の `name:` フィールドは常に一致させる。

## 形式

- 動詞と目的語をダブルアンダースコア `__` で区切る
- 各セグメント内の語はシングルアンダースコア `_` で区切る (snake_case)
- 動詞は動作を正確に表すものを選ぶ (`get` より `fetch` / `validate` / `rescue` など)

| 良い例 | 構造 |
|---|---|
| `validate__japanese` | validate (動詞) / japanese (目的語) |
| `monitor__ci_status` | monitor (動詞) / ci_status (目的語) |
| `pull_out__knowledge_from_me` | pull_out (動詞) / knowledge_from_me (目的語) |

| 避ける例 | 理由 | 修正後 |
|---|---|---|
| `grill_me` | `__` 区切りがなく動詞と目的語の境界が不明瞭 | `pull_out__knowledge_from_me` |
| `clean_comment_out` | 動詞 clean と目的語の境界を `__` で示せていない | `clean__comment_out` |
| `hold_personal_meeting` | 同上 | `hold__personal_meeting` |

## 注意

- `template/` はスキルではなく雛形なので命名規則の対象外とする。
- スキル名を変更したら、そのスキルを名指しで起動するフック (`configs/claude/hooks/`)
  の参照も合わせて更新する。参照が旧名のまま残ると、フックが存在しないスキルを
  指してしまう。
