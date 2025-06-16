FROM ubuntu:22.04 AS builder

ENV ARCH=arm64
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NEOVIM_VERSION=v0.11.1
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.rustup
ENV PATH="${CARGO_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    build-essential curl git ca-certificates xz-utils bash tar \
    sudo unzip wget python3 python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Neovimのインストール
RUN curl -LO https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-${ARCH}.tar.gz && \
    tar xzvf nvim-linux-${ARCH}.tar.gz && \
    cp nvim-linux-${ARCH}/bin/nvim /usr/local/bin/ && \
    cp -r nvim-linux-${ARCH}/share/nvim /usr/local/share/ && \
    rm -rf nvim-linux-${ARCH} nvim-linux-${ARCH}.tar.gz

# Node.js 20.xのインストール
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Rustのインストール
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain=nightly && \
    . "$HOME/.cargo/env" && rustup show

# -----------------------------------------------
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.rustup
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# 必要なパッケージをインストール
RUN apt-get update && apt-get install -y \
    curl git build-essential gcc python3 python3-pip \
    ripgrep fd-find unzip wget apt-transport-https && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# .NET SDKのインストール（Marksman用）
RUN wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt-get update && \
    apt-get install -y dotnet-runtime-8.0 aspnetcore-runtime-8.0 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

USER root
RUN mkdir -p /root/.config/nvim
RUN mkdir -p /root/.local/share/nvim/mason
COPY config/ /root/.config/nvim/

# builderからバイナリと必要なツールをコピー
COPY --from=builder /usr/local/bin/nvim /usr/local/bin/
COPY --from=builder /usr/local/share/nvim /usr/local/share/nvim
COPY --from=builder /usr/bin/node /usr/bin/
COPY --from=builder /usr/bin/npm /usr/bin/
COPY --from=builder ${CARGO_HOME} ${CARGO_HOME}
COPY --from=builder ${RUSTUP_HOME} ${RUSTUP_HOME}

ENTRYPOINT ["/usr/local/bin/nvim"]
