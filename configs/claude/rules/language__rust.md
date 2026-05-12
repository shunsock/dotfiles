# Rust Rule

## エラーは型で表現する

production コードの失敗は `Result<T, E>` で、不在は `Option<T>` で表現する。`?` 演算子で呼び出し側に伝播し、失敗パスを型シグネチャに露出させる。

- `unwrap()` / `expect()` / `panic!()` を production コードで書かない
- 唯一の例外は「内部不整合 (起きたらバグ確定で安全に続行不可能)」
  - その場合も `expect("invariant: ...")` のように **不変条件の名前** をメッセージに残す
- テストコード (`#[cfg(test)]` 配下) の `assert!` / `unwrap` (= 「失敗したらテスト落ち」が意図) はこの規律の対象外

## エラー型は ADT で作る

エラーはライブラリ層・アプリ層を問わず、`thiserror::Error` でバリアントを列挙した enum として定義する。

- `anyhow::Error` / `anyhow::Result` は禁止
- `Box<dyn Error>` でぼかさない
- 低レベルエラーの透過変換は `#[from]` を使う
- `main` 関数の戻り値ですら `Result<(), MyError>` で具体型を返す

### 推奨パターン

```rust
use thiserror::Error;

#[derive(Debug, Error)]
pub enum LoadConfigError {
    #[error("config file not found: {path}")]
    NotFound { path: String },

    #[error("failed to parse config")]
    Parse(#[from] toml::de::Error),

    #[error("failed to read config file")]
    Io(#[from] std::io::Error),
}

pub fn load_config(path: &str) -> Result<Config, LoadConfigError> {
    let raw = std::fs::read_to_string(path)?;
    let config = toml::from_str(&raw)?;
    Ok(config)
}
```

### 避けるべきパターン

```rust
// anyhow で全エラーを 1 つの型に潰す
pub fn load_config(path: &str) -> anyhow::Result<Config> {
    let raw = std::fs::read_to_string(path)?;
    let config = toml::from_str(&raw)?;
    Ok(config)
}

// unwrap で実行時クラッシュに化ける
pub fn load_config(path: &str) -> Config {
    let raw = std::fs::read_to_string(path).unwrap();
    toml::from_str(&raw).unwrap()
}
```

## Clippy で機械検証する

ドキュメント上の規律だけに頼らず、`clippy` で違反を機械的に検出可能にする。

### workspace の場合

ルート `Cargo.toml` に lint 設定を集約する。

```toml
[workspace.lints.clippy]
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
```

各 member crate の `Cargo.toml` には以下を追加し、lint を継承させる。

```toml
[lints]
workspace = true
```

### 単一 crate の場合

`Cargo.toml` に直接記述する。

```toml
[lints.clippy]
unwrap_used = "warn"
expect_used = "warn"
panic = "warn"
```

### 検証コマンド

編集後は以下を実行し、警告がないことを確認する。

```bash
cargo fmt
cargo clippy --all-targets --all-features -- -D warnings
cargo test
```

- `cargo fmt` でフォーマットを統一する
- `cargo clippy` で lint 違反を検出する (CI で `-D warnings` を付けて落とす)
- `cargo test` でテストを通す

いずれかが失敗した場合は修正してから次の作業に進むこと。

## 理由

- Rust で `Result` / `Option` を採用している意味は「失敗パスを型で表現させる」こと。`.unwrap()` を 1 行書いた瞬間、その意味は実行時クラッシュに化ける
- `anyhow::Error` は全エラーを 1 つの型に潰すため、`Result` の型シグネチャから「どんな失敗が起きうるか」が消える。Railway / 型駆動の規律と矛盾する
- ADT (enum + `thiserror`) でエラーを定義すると、レビュー時に context を読み下さずとも、型から失敗の種類が読み取れる
- AI 駆動でコードが大量に書かれる前提では、暗黙の規律は守られない。機械検証 (clippy) + ドキュメント (このルール) の二重で固める
