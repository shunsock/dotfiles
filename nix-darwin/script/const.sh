#!/usr/bin/env bash
# const.sh
#
# nix-darwin スクリプト全体で共有する定数定義。
# 各エントリーポイントが flake 参照や構成名を個別に持つと
# 変更時に修正漏れが生じるため、ここに一元化する (DRY)。
#
# このファイルは実行せず、他スクリプトから source して利用する。

# source 先で参照されるため、単体では未使用に見えるが意図的な定義 (SC2034 抑制)。
# shellcheck disable=SC2034

# nix-darwin flake の取得元 (init / build で利用)
readonly NIX_DARWIN_FLAKE="github:LnL7/nix-darwin"

# darwin 構成名 (flake output attribute)
readonly DARWIN_CONFIG="shunsock-darwin"

# flake への参照 (.#<構成名>)
readonly FLAKE_REF=".#${DARWIN_CONFIG}"

# build.sh が生成する darwin-rebuild バイナリのパス。
# sudo 下で再評価しないよう、ビルド済みバイナリを直接呼び出す。
readonly DARWIN_REBUILD_BIN="./result/sw/bin/darwin-rebuild"

# nix-collect-garbage で保持する世代の最大期間
readonly GC_KEEP_DURATION="30d"
