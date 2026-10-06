# Cua image

Extends our base with **cua-driver 0.34.0**, X11/AT-SPI dependencies, a shared
D-Bus launcher, and the official Cua plus Agentbox companion skills. Linux amd64.

From the repository root:

```bash
make build-cua VERSION=v1
make check VERSION=v1
make install-cua-skills VERSION=v1
agentbox config set --project box.imageDocker agentbox/cua:v1
agentbox pi --provider docker --name cua-v1
```

Skills are installed on the host at `~/.pi/agent/skills` and synced into new Pi
boxes. Agentbox mounts over both `~/.agents` and `~/.pi/agent`, so image-baked
links alone are insufficient. Existing Pi sessions may need `/reload` after sync.
The installation script refuses to overwrite unmanaged skills and backs up its
own previous installations.

In Pi, use `/skill:agentbox-desktop` for desktop/browser tasks. It explains how to
start `agentbox-cua-serve` when no daemon exists. The launcher is not automatic;
start it after Agentbox's VNC desktop is ready and before new GUI apps.

Watch with `agentbox screen <box>`. Trusted Linux background browser clicks can
refuse; explicit foreground delivery is allowed on this dedicated desktop.
Native Chrome accessibility remains partially qualified. `make check` covers
image contents, not live browser behavior or stop/start recovery.
