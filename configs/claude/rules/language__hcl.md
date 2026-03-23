# HCL (Terraform) Rule

## コード検証

HCL ファイルを編集した後は、以下のコマンドを順に実行して品質を確認する。

```bash
terraform fmt -recursive
terraform validate
tflint
```

- `terraform fmt -recursive` でフォーマットを統一する
- `terraform validate` で構文・参照の整合性を検証する
- `tflint` でベストプラクティス違反や潜在的な問題を検出する

いずれかが失敗した場合は修正してから次の作業に進むこと。

## Push 前の Plan 実行

差分をリモートに push する前に `terraform plan` を実行し、意図しない変更が含まれていないことを確認する。

```bash
terraform plan
```

- plan の出力を確認し、想定外のリソース変更がないことを検証する
- 破壊的変更 (destroy / replace) が含まれる場合はユーザーに報告し、承認を得てから push する

## モジュール間の情報伝達

`output.tf` による情報伝達は可能な限り避ける。代わりに `data` ソースと `depends_on` を利用してモジュール間の依存を解決する。

### 避けるべきパターン

```hcl
# output.tf で値を公開し、別モジュールから参照する
output "vpc_id" {
  value = aws_vpc.main.id
}
```

### 推奨パターン

```hcl
# data.tf でリソースを参照する
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["main"]
  }
}

# depends_on で暗黙の依存を明示する
resource "aws_subnet" "example" {
  vpc_id = data.aws_vpc.main.id

  depends_on = [aws_vpc.main]
}
```

### 理由

- `output` はモジュール間の結合度を高め、変更の影響範囲が広がる
- `data` ソースは実際のインフラ状態を参照するため、宣言的かつ疎結合になる
- `depends_on` で依存関係を明示することで、適用順序の意図がコードに表れる
