# ======================================
# Builder Stage
# ======================================
FROM ubuntu:22.04 AS builder

# 引数の定義
ARG ARCH=arm64
ARG NEOVIM_VERSION=v0.11.1
ARG NODE_VERSION=20.x

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive \
    CARGO_HOME=/root/.cargo \
    RUSTUP_HOME=/root/.rustup \
    PATH="/root/.cargo/bin:${PATH}"

# 基本パッケージのインストール
RUN apt-get update && apt-get install -y \
    build-essential \
    ca-certificates \
    curl \
    git \
    python3 \
    python3-pip \
    sudo \
    tar \
    unzip \
    wget \
    xz-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Neovimのインストール
RUN curl -LO "https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-${ARCH}.tar.gz" \
    && tar xzvf "nvim-linux-${ARCH}.tar.gz" \
    && cp "nvim-linux-${ARCH}/bin/nvim" /usr/local/bin/ \
    && cp -r "nvim-linux-${ARCH}/share/nvim" /usr/local/share/ \
    && rm -rf "nvim-linux-${ARCH}" "nvim-linux-${ARCH}.tar.gz"

# Node.jsのインストール
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}" | bash - \
    && apt-get update \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Rustのインストール
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain=nightly \
    && . "$HOME/.cargo/env" \
    && rustup component add rust-analyzer-preview --toolchain nightly

# ======================================
# Runtime Stage
# ======================================
FROM ubuntu:22.04

# 引数の定義
ARG DOTNET_VERSION=8.0

# 環境変数の設定
ENV DEBIAN_FRONTEND=noninteractive \
    CARGO_HOME=/root/.cargo \
    RUSTUP_HOME=/root/.rustup \
    PATH="/root/.cargo/bin:${PATH}"

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    build-essential \
    curl \
    fd-find \
    gcc \
    git \
    python3 \
    python3-pip \
    ripgrep \
    unzip \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# .NET SDKのインストール（Marksman用）
RUN wget "https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb" -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y "dotnet-runtime-${DOTNET_VERSION}" "aspnetcore-runtime-${DOTNET_VERSION}" "dotnet-sdk-${DOTNET_VERSION}" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# F#ツールのインストール
RUN dotnet tool install -g fsautocomplete && \
    dotnet tool install -g fantomas
ENV PATH="${PATH}:/root/.dotnet/tools"

# 必要なディレクトリの作成とNvim設定のコピー
RUN mkdir -p /root/.config/nvim /root/.local/share/nvim/mason
COPY config/ /root/.config/nvim/

# builderステージからバイナリと必要なツールをコピー
COPY --from=builder /usr/local/bin/nvim /usr/local/bin/
COPY --from=builder /usr/local/share/nvim /usr/local/share/nvim
COPY --from=builder /usr/bin/node /usr/bin/
COPY --from=builder /usr/bin/npm /usr/bin/
COPY --from=builder ${CARGO_HOME} ${CARGO_HOME}
COPY --from=builder ${RUSTUP_HOME} ${RUSTUP_HOME}

ENTRYPOINT ["/usr/local/bin/nvim"]
