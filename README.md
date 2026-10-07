# Agentbox images

Small, layered images for local or remote Docker Agentbox:

```text
ghcr.io/madarco/agentbox/box:0.33.0 → agentbox/base:latest → agentbox/cua:latest
```

- [Base](images/base/README.md): Bun, ripgrep, fd, and Pi.
- [Cua](images/cua/README.md): desktop automation and global Pi skills.

## Build and use

Requires Docker with Buildx and Make. For local parent images, use a **Docker-driver
builder** (inspect the selected builder with `docker buildx inspect`). A
`docker-container` builder cannot resolve parent images available only in the local
Docker image store. Builds use the currently selected builder and `--load`.

The base defaults to `ghcr.io/madarco/agentbox/box:0.33.0`, which Docker can pull
from the registry. If your upstream image uses another tag, supply
`BOX_IMAGE=agentbox/box:v1` or another image reference.

Run from this repository, building each image separately:

```bash
make build base
make build cua
```

Available images are discovered from `images/*/Dockerfile`. Each invocation builds
exactly one image; building Cua does **not** build its base automatically.
Run `make help` for usage.

Every build tags its output as `latest`. An optional version adds a second tag to
the same image:

```bash
make build base VERSION=v1  # base:latest and base:v1
make build cua VERSION=v1   # cua:latest and cua:v1
agentbox config set --project box.imageDocker agentbox/cua:v1
agentbox pi --provider docker --name cua-v1
```

Use a new version tag when deploying changed images: Agentbox may otherwise reuse
an old derived `-pi` image. Builds do not change host configuration or install
skills on the host.

### Remote Docker on devbox

Create an SSH-backed context (requires working SSH access to `devbox` and Docker
with Buildx on the client):

```bash
docker context create agentbox-devbox --docker host=ssh://devbox
docker --context agentbox-devbox buildx inspect agentbox-devbox
make build base DOCKER_CONTEXT=agentbox-devbox
make build cua DOCKER_CONTEXT=agentbox-devbox
agentbox config set --project box.imageRemoteDocker agentbox/cua:latest
agentbox pi --provider docker:devbox --name cua-latest
```

Use a **Docker-driver builder attached to the remote context**. Check that the
inspection reports driver `docker` and the devbox endpoint. Make explicitly selects
the builder named after `DOCKER_CONTEXT` with `--builder`, overriding ambient
`BUILDX_BUILDER` without changing Docker's default context. A
`docker-container` builder cannot use the base image stored only in devbox's Docker
image store. `--load` loads each build into that remote daemon, not the client's
local image store. Build the base first; Cua uses `agentbox/base:latest` by
default. These commands update only the `latest` tags. Rebuild project images and
recreate boxes to pick up changes. For an arm64 client targeting Cua, pass
`PLATFORM=linux/amd64` to both builds.

The Docker context name `agentbox-devbox` is for Make/Docker; Agentbox's
`docker:devbox` provider uses the SSH host `devbox`. Local usage above remains
unchanged when `DOCKER_CONTEXT` is omitted.

### Pi configuration on remote Docker

Agentbox 0.33.0's remote-Docker path may omit host Pi configuration. Explicitly
sync a box before using Pi (the host `abox()` helper does this automatically):

```bash
bash ~/dev/agentbox/tools/sync-pi.sh <box-name> agentbox-devbox
```

The script copies settings, models, extensions, skills, agents, prompts, themes,
and installed npm packages. It streams the host's current Pi credentials into the
box's private credential directory over SSH, falling back to Agentbox's cached
credentials only when the host file is absent. No credentials enter an image.
Sessions, trust decisions, and runtime state are not copied. Existing box files
are overlaid, not deleted. Only sync to an engine you trust.

For an already running Pi session, use `/reload` after syncing; restart Pi if
needed to refresh authentication. The script itself never stops a session.
New boxes created by `abox()` restart their initial Pi session after syncing so
all configuration is loaded before attachment.

### Overrides

- `VERSION`: optional additional output tag; defaults to empty. `VERSION=latest`
  produces only the latest tag.
- `IMAGE_PREFIX`: output repository prefix; defaults to `agentbox`.
- `PLATFORM`: optional target platform; omitted by default so Docker chooses it.
  Cua supports only `linux/amd64`; on arm64 hosts, set `PLATFORM=linux/amd64`.
- `DOCKER_CONTEXT`: optional Docker context passed via `docker --context` and
  selected as the Buildx builder via `--builder`; empty preserves the existing
  Docker context/environment behavior.
- `BOX_IMAGE`: base image's parent; defaults to `ghcr.io/madarco/agentbox/box:0.33.0`.
- `BASE_IMAGE`: Cua image's parent; defaults to `<IMAGE_PREFIX>/base:latest`.

`VERSION` controls output tags only, not parent selection. For example:

```bash
make build cua VERSION=v2 BASE_IMAGE=agentbox/base:v1 PLATFORM=linux/amd64
make build base IMAGE_PREFIX=my-team BOX_IMAGE=agentbox/box:v1
```
