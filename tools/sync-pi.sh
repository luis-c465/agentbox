#!/usr/bin/env bash
# Explicit host Pi configuration transfer for Agentbox remote-Docker boxes.
# Credentials travel over Docker's SSH transport, never into an image/build context.
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  printf 'Usage: %s <box-name> [docker-context]\n' "$0" >&2
  exit 2
fi
name=$1
context=${2:-agentbox-devbox}
container="agentbox-${name}"
source_dir="$HOME/.pi/agent"
unset DOCKER_HOST DOCKER_CONTEXT BUILDX_BUILDER

[[ -d "$source_dir" ]] || { printf 'Pi configuration not found: %s\n' "$source_dir" >&2; exit 1; }
docker --context "$context" inspect --type container "$container" >/dev/null

# Deliberate allowlist: no transcripts, trust decisions, runtime state, or
# host-native Pi binaries. npm contains the packages referenced by settings.
items=()
for item in settings.json models.json extensions skills agents prompts themes npm; do
  if [[ -e "$source_dir/$item" ]]; then items+=("$item"); fi
done

docker --context "$context" exec --user root "$container" bash -c '
  install -d -m 700 -o vscode -g vscode /home/vscode/.pi /home/vscode/.pi/agent \
    /home/vscode/.agentbox-creds /home/vscode/.agentbox-creds/pi
  chown vscode:vscode /home/vscode/.pi/agent /home/vscode/.agentbox-creds/pi
'
if (( ${#items[@]} )); then
  # Dereference host symlinks so links to host-only directories remain usable.
  tar --dereference -C "$source_dir" -cf - -- "${items[@]}" |
    docker --context "$context" exec -i --user vscode "$container" \
      tar --no-same-owner -xf - -C /home/vscode/.pi/agent
fi

# Prefer the host's current login over Agentbox's possibly stale cached backup.
auth="$source_dir/auth.json"
if [[ ! -s "$auth" && -s "$HOME/.agentbox/pi-credentials.json" ]]; then
  auth="$HOME/.agentbox/pi-credentials.json"
fi
if [[ -s "$auth" ]]; then
  docker --context "$context" exec -i --user vscode "$container" bash -c '
    umask 077
    tmp=$(mktemp /home/vscode/.agentbox-creds/pi/auth.XXXXXX)
    trap '\''rm -f "$tmp"'\'' EXIT
    cat > "$tmp"
    chmod 600 "$tmp"
    mv -f "$tmp" /home/vscode/.agentbox-creds/pi/auth.json
    ln -sfn /home/vscode/.agentbox-creds/pi/auth.json /home/vscode/.pi/agent/auth.json
  ' < "$auth"
else
  printf 'Warning: no host Pi credentials found; existing box credentials retained\n' >&2
fi
printf 'Pi configuration synced to %s on %s (sessions excluded)\n' "$name" "$context"
