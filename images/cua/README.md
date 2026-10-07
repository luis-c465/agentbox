# Cua image

Extends our base with **cua-driver 0.34.0**, X11/AT-SPI dependencies, a shared
D-Bus launcher, Vulkan loader/Mesa drivers/tools, and the official Cua plus
Agentbox companion skills. Linux amd64.

From the repository root:

```bash
make build base VERSION=v1
make build cua VERSION=v1
agentbox config set --project box.imageDocker agentbox/cua:v1
agentbox pi --provider docker --name cua-v1
```

To build both images on remote Docker over SSH instead:

```bash
docker context create agentbox-devbox --docker host=ssh://devbox
docker --context agentbox-devbox buildx inspect agentbox-devbox
make build base DOCKER_CONTEXT=agentbox-devbox
make build cua DOCKER_CONTEXT=agentbox-devbox
agentbox config set --project box.imageRemoteDocker agentbox/cua:latest
agentbox pi --provider docker:devbox --name cua-latest
```

Create the context only once. Use a **Docker-driver builder attached to the remote
context**; inspection must show driver `docker` and the devbox endpoint. Make
explicitly selects the context-named builder, overriding `BUILDX_BUILDER` without
changing Docker's default context.
A `docker-container` builder cannot resolve a parent available only in devbox's
Docker image store. `--load` stores the output on devbox, not locally. Omitting
`DOCKER_CONTEXT` retains local usage; `docker:devbox` is Agentbox's SSH-host provider,
not the Docker context name.

Each command builds only its selected image. Cua defaults to
`agentbox/base:latest`; override it with `BASE_IMAGE=<image>` to use another parent.
Builds always tag `agentbox/cua:latest`, with `VERSION=v1` adding `agentbox/cua:v1`.
On arm64 hosts, pass `PLATFORM=linux/amd64` to both builds. Use a Docker-driver
Buildx builder when the parent images are available only locally.

Skills must be installed on the host at `~/.pi/agent/skills` to be synced into new Pi
boxes; image builds do not perform that installation. Agentbox mounts over both `~/.agents` and `~/.pi/agent`, so image-baked
links alone are insufficient. Existing Pi sessions may need `/reload` after sync.

In Pi, use `/skill:agentbox-desktop` for desktop/browser tasks. It explains how to
start `agentbox-cua-serve` when no daemon exists. The launcher is not automatic;
start it after Agentbox's VNC desktop is ready and before new GUI apps.

Watch with `agentbox screen <box>`. Trusted Linux background browser clicks can
refuse; explicit foreground delivery is allowed on this dedicated desktop.
Native Chrome accessibility remains partially qualified. Building the image does
not verify live browser behavior or stop/start recovery.

## Vulkan verification

The image includes `libvulkan1`, `mesa-vulkan-drivers`, and `vulkan-tools`.
In a fresh box using the rebuilt image, preferably after the desktop is ready, run:

```bash
vulkaninfo --summary
```

Vulkan should initialize and list at least one latestice. Without a compatible GPU
exposed to the container, a Mesa software latestice such as llvmpipe is expected and
acceptable. Installing these packages does not enable GPU passthrough. Run this
check in the live box rather than during the image build. If the desktop is not
running, use `env -u DISPLAY vulkaninfo --summary` to skip X11 surface checks.
