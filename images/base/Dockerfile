# syntax=docker/dockerfile:1
ARG BOX_IMAGE=ghcr.io/madarco/agentbox/box:latest

FROM oven/bun:1.4.2 AS bun

FROM ${BOX_IMAGE}

USER root

COPY --from=bun /usr/local/bin/bun /usr/local/bin/bun
RUN ln -s /usr/local/bin/bun /usr/local/bin/bunx

# Keep the default toolbox minimal.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ripgrep fd-find \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

# Preinstall Pi so Agent Box skips its per-box npm installation.
RUN npm install -g --prefix /usr/local @earendil-works/pi-coding-agent@1.0.4 \
    && npm cache clean --force \
    && install -d -o vscode -g vscode \
        /home/vscode/.pi \
        /home/vscode/.pi/agent \
        /home/vscode/.agentbox-creds \
        /home/vscode/.agentbox-creds/pi \
    && ln -sfn /home/vscode/.agentbox-creds/pi/auth.json /home/vscode/.pi/agent/auth.json \
    && chown -h vscode:vscode /home/vscode/.pi/agent/auth.json

USER vscode

RUN bun --version && rg --version && fd --version && pi --version
