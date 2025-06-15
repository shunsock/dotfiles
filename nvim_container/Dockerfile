FROM ubuntu:22.04 AS builder

ENV ARCH=arm64
ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR=/root/.nvm
ENV NEOVIM_VERSION=v0.11.1
ENV NODE_VERSION=24
ENV NVM_VERSION=v0.40.3

RUN apt-get update && apt-get install -y \
    build-essential curl git ca-certificates xz-utils bash tar \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Node.js install via nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash && \
    bash -c ". $NVM_DIR/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION} && \
    cp $NVM_DIR/versions/node/v${NODE_VERSION}*/bin/node /usr/local/bin/ && \
    cp $NVM_DIR/versions/node/v${NODE_VERSION}*/bin/npm /usr/local/bin/"

# Neovim install
RUN curl -LO https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION}/nvim-linux-${ARCH}.tar.gz && \
    tar xzvf nvim-linux-${ARCH}.tar.gz && \
    cp nvim-linux-${ARCH}/bin/nvim /usr/local/bin/ && \
    cp -r nvim-linux-${ARCH}/share/nvim /usr/local/share/ && \
    rm -rf nvim-linux-${ARCH} nvim-linux-${ARCH}.tar.gz


# -----------------------------------------------
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl git sudo build-essential unzip wget python3 python3-pip nodejs npm cargo \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER root
RUN mkdir -p /root/.config/nvim
COPY config/ /root/.config/nvim/

# COPY binaries from builder
COPY --from=builder /usr/local/bin/nvim /usr/local/bin/
COPY --from=builder /usr/local/share/nvim /usr/local/share/nvim
COPY --from=builder /usr/local/bin/node /usr/local/bin/
COPY --from=builder /usr/local/bin/npm /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/nvim"]

