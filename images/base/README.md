# Base image

Extends `agentbox/box:dev` with **Bun 1.4.2**, **ripgrep**, **fd**, and **Pi 1.0.4**.
Installs fd from the `fd-find` package and exposes it as `fd` via
`/usr/local/bin/fd`, a symlink to `/usr/bin/fdfind`.
Preserves Agentbox's startup behavior and ends as user `vscode`.

From the repository root:

```bash
make build base VERSION=v1
agentbox config set --project box.imageDocker agentbox/base:v1
agentbox pi --provider docker --name base-v1
```

Builds always tag `agentbox/base:dev`; `VERSION=v1` also tags the same image
as `agentbox/base:v1`. Omit `VERSION` to tag only `dev`.

Override the upstream parent with `BOX_IMAGE=<image>`. It must be available to the
selected builder; use a Docker-driver builder for local parent images.
Other images inherit this toolbox using `FROM agentbox/base:dev` by default.
Pi credentials remain runtime-managed by Agentbox; no credentials are baked in.
Preinstalling Pi supplies the executable, not authentication or custom models.
Create Pi boxes with `agentbox pi` so Agentbox mounts and syncs the host Pi
configuration at container creation. In Agentbox 0.33.0, a plain `agentbox create`
followed by `agentbox pi start` does not add that missing config mount to the
existing container and can leave Pi with no available models.

After updating this image, rebuild downstream images (for example, Cua and any
project image) and recreate boxes to pick up the new tools.
