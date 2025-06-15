FROM ubuntu:22.04 AS builder

ENV ARCH=arm64
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NEOVIM_VERSION=v0.11.1

RUN apt-get update && apt-get install -y \
    build-essential curl git ca-certificates xz-utils bash tar \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -LO https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-${ARCH}.tar.gz && \
    tar xzvf nvim-linux-${ARCH}.tar.gz && \
    cp nvim-linux-${ARCH}/bin/nvim /usr/local/bin/ && \
    cp -r nvim-linux-${ARCH}/share/nvim /usr/local/share/ && \
    rm -rf nvim-linux-${ARCH} nvim-linux-${ARCH}.tar.gz


# -----------------------------------------------
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.rustup
ENV PATH="${CARGO_HOME}/bin:${PATH}"

# Node.js 20.xのインストール
RUN apt-get update && apt-get install -y \
    curl git sudo build-essential unzip wget python3 python3-pip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Node.js 20.xのインストール
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --default-toolchain=nightly && \
    . "$HOME/.cargo/env" && rustup show

USER root
RUN mkdir -p /root/.config/nvim
COPY config/ /root/.config/nvim/

# COPY binaries from builder
COPY --from=builder /usr/local/bin/nvim /usr/local/bin/
COPY --from=builder /usr/local/share/nvim /usr/local/share/nvim

ENTRYPOINT ["/usr/local/bin/nvim"]
