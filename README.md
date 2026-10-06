# Agentbox images

Small, layered images for local Agentbox:

```text
agentbox/box:dev → agentbox/base:dev → agentbox/cua:dev
```

- [Base](images/base/README.md): Bun, ripgrep, fd, and Pi.
- [Cua](images/cua/README.md): desktop automation and global Pi skills.

## Build and use

Requires Docker with Buildx and Make. For local parent images, use a **Docker-driver
builder** (inspect the selected builder with `docker buildx inspect`). A
`docker-container` builder cannot resolve parent images available only in the local
Docker image store. Builds use the currently selected builder and `--load`.

Make sure `agentbox/box:dev` is available before building the base. If your
upstream image uses another tag, supply `BOX_IMAGE=agentbox/box:v1` or another
image reference.

Run from this repository, building each image separately:

```bash
make build base
make build cua
```

Available images are discovered from `images/*/Dockerfile`. Each invocation builds
exactly one image; building Cua does **not** build its base automatically.
Run `make help` for usage.

Every build tags its output as `dev`. An optional version adds a second tag to
the same image:

```bash
make build base VERSION=v1  # base:dev and base:v1
make build cua VERSION=v1   # cua:dev and cua:v1
agentbox config set --project box.imageDocker agentbox/cua:v1
agentbox pi --provider docker --name cua-v1
```

Use a new version tag when deploying changed images: Agentbox may otherwise reuse
an old derived `-pi` image. Builds do not change host configuration or install
skills on the host.

### Overrides

- `VERSION`: optional additional output tag; defaults to empty. `VERSION=dev`
  produces only the dev tag.
- `IMAGE_PREFIX`: output repository prefix; defaults to `agentbox`.
- `PLATFORM`: optional target platform; omitted by default so Docker chooses it.
  Cua supports only `linux/amd64`; on arm64 hosts, set `PLATFORM=linux/amd64`.
- `BOX_IMAGE`: base image's parent; defaults to `agentbox/box:dev`.
- `BASE_IMAGE`: Cua image's parent; defaults to `<IMAGE_PREFIX>/base:dev`.

`VERSION` controls output tags only, not parent selection. For example:

```bash
make build cua VERSION=v2 BASE_IMAGE=agentbox/base:v1 PLATFORM=linux/amd64
make build base IMAGE_PREFIX=my-team BOX_IMAGE=agentbox/box:v1
```
