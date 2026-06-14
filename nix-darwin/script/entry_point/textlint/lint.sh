#!/usr/bin/env bash
set -euo pipefail

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_ROOT/library/runner.sh"

# 校正対象はリポジトリの Claude 設定 (configs/claude) 配下の Markdown。
# SCRIPT_ROOT は nix-darwin/script なので、2 つ上がリポジトリルート。
REPO_ROOT="$(cd "$SCRIPT_ROOT/../.." && pwd)"
TARGET_DIR="$REPO_ROOT/configs/claude"
# ルールは validate__japanese スキルの設定を single source として共有する。
CONFIG="$REPO_ROOT/configs/claude/skills/validate__japanese/.textlintrc.json"

# textlint 本体と ja ルールプリセットは別々の Nix ストアパスに入るため、
# textlint がルールを解決できるよう各プリセットの node_modules を NODE_PATH に通す。
technical_writing="$(nix eval --raw nixpkgs#textlint-rule-preset-ja-technical-writing)"
spacing="$(nix eval --raw nixpkgs#textlint-rule-preset-ja-spacing)"
node_path="$technical_writing/lib/node_modules:$spacing/lib/node_modules"

# 対象 Markdown を収集する。
# mapfile は macOS 標準の bash 3.2 に無いため while-read で配列に積む。
md_files=()
while IFS= read -r file; do
  md_files+=("$file")
done < <(find "$TARGET_DIR" -name '*.md')

# textlint の起動をまとめる。第1引数以降がそのまま textlint の引数になる。
textlint() {
  nix shell nixpkgs#textlint \
    nixpkgs#textlint-rule-preset-ja-technical-writing \
    nixpkgs#textlint-rule-preset-ja-spacing \
    --command env NODE_PATH="$node_path" \
    textlint --config "$CONFIG" "$@"
}

# Phase 1: 自動修正の適用。
# textlint --fix は「修正不能な指摘 (一文の長さ等)」を出力にも終了コードにも反映せず
# exit 0 で終わる。そのためこのパスでは合否を判定せず、修正適用だけを目的にする。
info "自動修正可能な指摘 (全角・半角間スペース等) を適用します"
textlint --fix "${md_files[@]}" || true

# Phase 2: 再検査と報告。
# 自動修正後に残る指摘 (一文の長さ・助詞の重複など手動対応が必要なもの) を出力し、
# その有無で run の終了コード = タスクの合否を決める。
run "日本語テクニカルライティングの校正" \
  textlint "${md_files[@]}"
