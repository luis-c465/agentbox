# Base image

Extends `agentbox/box:dev` with **Bun 1.4.2**, **ripgrep**, and **Pi 1.0.4**.
Preserves Agentbox's startup behavior and ends as user `vscode`.

From the repository root:

```bash
make build-base VERSION=v1
agentbox config set --project box.imageDocker agentbox/base:v1
agentbox pi --provider docker --name base-v1
```

Other images inherit this toolbox using `FROM agentbox/base:<version>`.
Pi credentials remain runtime-managed by Agentbox; no credentials are baked in.
