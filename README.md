# Agentbox images

Small, layered images for local Agentbox:

```text
agentbox/box:dev → agentbox/base:<version> → agentbox/cua:<version>
```

- [Base](images/base/README.md): Bun, ripgrep, and Pi.
- [Cua](images/cua/README.md): desktop automation and global Pi skills.

## Build and use

Requires Docker and Make. Run from this repository:

```bash
make build-cua VERSION=v1
make check VERSION=v1
make install-cua-skills VERSION=v1
agentbox config set --project box.imageDocker agentbox/cua:v1
agentbox pi --provider docker --name cua-v1
```

Use a new version tag when deploying changed images: Agentbox may otherwise reuse
an old derived `-pi` image. Builds do not change host configuration; skill
installation and the Agentbox config command above are explicit opt-ins.

`make build-base` builds only the base. The default version is `dev`; image tags
can also be overridden with `BASE_IMAGE` and `CUA_IMAGE`.
