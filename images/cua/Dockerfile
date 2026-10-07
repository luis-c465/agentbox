# syntax=docker/dockerfile:1
ARG BASE_IMAGE=agentbox/base:latest
FROM ${BASE_IMAGE}

USER root

# The qualified desktop/browser setup is Linux amd64.
RUN test "$(dpkg --print-architecture)" = amd64 \
    || { echo 'Cua requires linux/amd64; build with PLATFORM=linux/amd64.' >&2; exit 1; }

# libglib2.0-bin supplies gdbus, used by cua-driver doctor's AT-SPI probe.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl util-linux \
        dbus dbus-x11 at-spi2-core libglib2.0-bin \
        libxi6 libxtst6 libx11-6 libxext6 \
        x11-utils \
        libvulkan1 mesa-vulkan-drivers vulkan-tools \
    && rm -rf /var/lib/apt/lists/*

# Shared per-box bus for GUI apps, agent shells, and the driver.
RUN install -d -m 0700 -o vscode -g vscode /tmp/agentbox-cua-runtime
ENV DISPLAY=:1 \
    XDG_RUNTIME_DIR=/tmp/agentbox-cua-runtime \
    DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/agentbox-cua-runtime/session-bus \
    PATH=/home/vscode/.local/bin:${PATH}

# Preserve Agentbox's entrypoint; start this launcher after the desktop is up.
COPY --chmod=755 scripts/agentbox-cua-serve /usr/local/bin/agentbox-cua-serve

USER vscode

ARG CUA_DRIVER_VERSION=0.34.0
RUN curl -fsSL https://cua.ai/driver/install.sh -o /tmp/cua-driver-install.sh \
    && CUA_DRIVER_RS_VERSION="${CUA_DRIVER_VERSION}" \
       bash /tmp/cua-driver-install.sh --no-modify-path \
    && rm /tmp/cua-driver-install.sh \
    && cua-driver --version

# Fetch the release-matched skill. Agentbox mounts over ~/.agents and ~/.pi/agent;
# use the host installation script to export skills into Pi's synced global dir.
RUN mkdir -p /home/vscode/.agents/skills \
    && cua-driver skills install \
    && cua-driver skills status \
    && test -f /home/vscode/.agents/skills/cua-driver/SKILL.md

# Keep local policy separate from upstream skills and outside mounted directories.
COPY --chown=vscode:vscode skills/agentbox-desktop/ /opt/agentbox/skills/agentbox-desktop/
RUN test -f /opt/agentbox/skills/agentbox-desktop/SKILL.md
