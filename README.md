# dotfiles

開発用 Docker コンテナ `nvimc` を管理するリポジトリ。

Nix によるマシン構成 (`nix-darwin` / `nix-os`) とグローバル Claude 設定 (`configs/`) は [shunsock/devtools](https://github.com/shunsock/devtools) へ移設した。管理下の 4 マシンの構成を 1 箇所へ集約するためである。横断的な変更が 1 リポジトリで完結する。

## nvimc

Ubuntu 24.04 をベースにした、携帯可能な Neovim 開発環境コンテナ。

| イメージ | 対象アーキテクチャ |
|---|---|
| `nvimc-default-arm` | ARM (Apple Silicon) |
| `nvimc-default-amd` | AMD / Intel |
| `nvimc-python` | Python 開発環境 |

### 使い方

コマンドは `nvimc/` で実行する。

```bash
cd nvimc

task build:default:arm          # ARM イメージをビルド
task run:default:arm <workspace> # workspace をマウントして起動

task build:python               # Python イメージをビルド
```

バージョンは `nvimc/Taskfile.yml` の `VERSION` 変数で管理する。
レジストリは `tsuchiya55docker/nvimc` である。
デプロイは GitHub Actions の手動トリガで行う。

## document

`document/quality_assuarance/` には Claude Code フックの品質保証記録を残している。
フック本体は devtools へ移設したが、記録は作成時点の経緯を示す資料として残す。
