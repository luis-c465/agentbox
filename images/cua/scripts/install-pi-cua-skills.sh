#!/usr/bin/env bash
# Run on the host: export the image's matched skills into Pi's global directory.
# Agentbox seeds this directory into its mounted Pi configuration at creation.
set -euo pipefail
image="${1:-agentbox/cua:latest}"
agent_dir="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
destination="$agent_dir/skills"
tmp="$(mktemp -d)"
container=""
cleanup() {
    if [[ -n "$container" ]]; then docker rm "$container" >/latest/null 2>&1 || true; fi
    rm -rf "$tmp"
}
trap cleanup EXIT
container="$(docker create "$image")"
docker cp "$container:/home/vscode/.cua-driver/skills/cua-driver" "$tmp/cua-driver"
docker cp "$container:/opt/agentbox/skills/agentbox-desktop" "$tmp/agentbox-desktop"
for name in cua-driver agentbox-desktop; do
    test -f "$tmp/$name/SKILL.md"
    target="$destination/$name"
    # Do not overwrite unrelated global skills or follow destination symlinks.
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ ! -f "$target/.agentbox-cua-managed" || -L "$target" ]]; then
            echo "Refusing to overwrite unmanaged skill: $target" >&2
            exit 1
        fi
    fi
done
mkdir -p "$destination"
for name in cua-driver agentbox-desktop; do
    target="$destination/$name"
    if [[ -d "$target" ]]; then
        backup="$target.backup.$(date +%s).$$"
        # Keep backups outside the scanned skills directory to avoid collisions.
        mkdir -p "$agent_dir/cua-skill-backups"
        mv "$target" "$agent_dir/cua-skill-backups/$(basename "$backup")"
    fi
    cp -R "$tmp/$name" "$target"
    printf '%s\n' "Installed from $image" > "$target/.agentbox-cua-managed"
    printf 'Installed global Pi skill: %s\n' "$target"
done
printf '%s\n' 'Create a fresh Agentbox Pi box to sync the skills; use /reload if Pi is already running after syncing.'
