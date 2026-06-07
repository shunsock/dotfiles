#!/usr/bin/env bash
# runner.sh
#
# コマンドをログ付きで実行する run 関数を提供する。
# 各エントリーポイントが開始・成功・失敗ログを個別に書かずに済むよう一元化する。
# このファイルは実行せず、他スクリプトから source して利用する。

RUNNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$RUNNER_DIR/logger.sh"

# 第1引数のラベルで開始・成功・失敗を info/error に出力しつつ、残りの引数をコマンドとして実行する。
# コマンドの終了コードをそのまま返し、失敗時の中断は呼び出し元の set -e に委ねる。
run() {
  local label="$1"
  shift

  info "${label}を開始します"

  local exit_code=0
  "$@" || exit_code=$?

  if [ "$exit_code" -eq 0 ]; then
    info "${label}に成功しました"
  else
    error "${label}に失敗しました (exit ${exit_code})"
  fi

  return "$exit_code"
}
