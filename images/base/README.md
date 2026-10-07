# Base image

Extends `ghcr.io/madarco/agentbox/box:0.33.0` with **Bun 1.4.2**, **ripgrep**, **fd**, and **Pi 1.0.4**.
Installs fd from the `fd-find` package and exposes it as `fd` via
`/usr/local/bin/fd`, a symlink to `/usr/bin/fdfind`.
Preserves Agentbox's startup behavior and ends as user `vscode`.

From the repository root:

```bash
make build base VERSION=v1
agentbox config set --project box.imageDocker agentbox/base:v1
agentbox pi --provider docker --name base-v1
```

To build and use the image on remote Docker over SSH instead:

```bash
docker context create agentbox-devbox --docker host=ssh://devbox
docker --context agentbox-devbox buildx inspect agentbox-devbox
make build base DOCKER_CONTEXT=agentbox-devbox
agentbox config set --project box.imageRemoteDocker agentbox/base:latest
agentbox pi --provider docker:devbox --name base-latest
```

Create the context only once. Use a Docker-driver builder attached to that remote
context (inspection should report driver `docker` and the devbox endpoint). Make
explicitly selects the context-named builder, overriding `BUILDX_BUILDER` without
changing Docker's default context. `--load` stores
the image on devbox. Omit `DOCKER_CONTEXT` to retain local usage. See the
[root README](../../README.md#remote-docker-on-devbox) for the base-to-Cua sequence.

Builds always tag `agentbox/base:latest`; `VERSION=v1` also tags the same image
as `agentbox/base:v1`. Omit `VERSION` to tag only `latest`.

Override the upstream parent with `BOX_IMAGE=<image>`. It must be available to the
selected builder; use a Docker-driver builder for local parent images.
Other images inherit this toolbox using `FROM agentbox/base:latest` by default.
Pi credentials remain runtime-managed by Agentbox; no credentials are baked in.
Preinstalling Pi supplies the executable, not authentication or custom models.
Create Pi boxes with `agentbox pi` so Agentbox mounts and syncs the host Pi
configuration at container creation. In Agentbox 0.33.0, a plain `agentbox create`
followed by `agentbox pi start` does not add that missing config mount to the
existing container and can leave Pi with no available models.

After updating this image, rebuild downstream images (for example, Cua and any
project image) and recreate boxes to pick up the new tools.
