---
name: agentbox-desktop
description: Operate or test the dedicated Linux desktop and Chrome browser inside Agentbox using cua-driver. Use for browser interaction, desktop screenshots, native GUI input, or diagnosing Agentbox computer-use failures.
compatibility: Linux x86_64 Agentbox with cua-driver, agentbox-cua-serve, Xvnc, and the official cua-driver skill installed.
---

# Agentbox desktop

Read the official `cua-driver` skill at `../cua-driver/SKILL.md` before operating the desktop. Follow its safety, targeting, session, and snapshot requirements. This companion adds environment-specific guidance; it does not replace the official skill.

## Environment and startup

- Run as `vscode` inside the box, not on the host or as root.
- The desktop is X11 on `DISPLAY=:1`; noVNC is a viewer of that same desktop, not an automation transport.
- The shared session bus is configured by `DBUS_SESSION_BUS_ADDRESS`; `XDG_RUNTIME_DIR` is `/tmp/agentbox-cua-runtime`. Preserve these inherited values.
- Check `cua-driver status` first. Reuse an existing daemon. If none is running, start `agentbox-cua-serve` in a persistent background process, capture logs, and wait for readiness. For example:

```bash
mkdir -p /tmp/cua-driver
nohup agentbox-cua-serve > /tmp/cua-driver/daemon.log 2>&1 < /latest/null &
```

- If startup fails, inspect the log and check `xdpyinfo -display "$DISPLAY"`. Do not repeatedly launch duplicate daemons. Do not replace Agentbox's desktop startup or silently install packages.
- Start new GUI apps after the shared bus exists. Prefer `browser_prepare` with a driver-owned isolated profile; do not attach to a logged-in profile without explicit authorization.

## Input policy for this dedicated desktop

This box's desktop is dedicated to the agent. Foreground delivery is allowed for task-related input unless the user specifically asks to preserve focus or avoid activation. Warn before concurrent manual noVNC interaction, which can interfere with focus and input.

- Prefer trusted browser clicks with `delivery_mode: "foreground"` when activation is acceptable. Inspect `cua-driver describe browser_click` for the installed schema. Omit `input_route: "dom_event"` when requesting the default trusted route.
- Linux trusted background clicks may refuse with `browser_input_trust_unavailable`. This is a backend limitation, not a reason to abandon the task. Explicitly select an appropriate supported route; do not silently claim the original route worked.
- Use `input_route: "dom_event"` only when synthetic input is acceptable and background operation matters. It is not equivalent to trusted input or user activation. Verify the resulting page state even when the call reports dispatch success.
- Native raw input may also require `delivery_mode: "foreground"`. Do not assume all toolkits accept background synthetic events.

## Grounding and verification

- Inspect installed CLI help and `cua-driver describe <tool>` rather than inventing arguments.
- Use a consistent named session, exact discovered PID/window targets, and current browser target/tab IDs.
- Take fresh snapshots and use returned refs/tokens. Refresh after navigation, stale-ref refusals, or actions that invalidate the snapshot.
- Verify app-owned state after each meaningful action using a fresh semantic snapshot, native tree, or screenshot. A successful tool response alone is not proof.
- Save screenshots as viewable files and use Pi's image-capable read tool when visual verification is needed.
- When explicitly testing cua-driver, do not substitute Playwright, agent-browser, xdotool, or direct CDP for its actions.

## Diagnose routes independently

Distinguish X11 capture/input, native AT-SPI accessibility, and CDP browser semantics. Failure of one does not automatically invalidate the others.

If `doctor` warns that AT-SPI is unreachable:

```bash
command -v gdbus
gdbus introspect --session --dest org.a11y.Bus --object-path /org/a11y/bus
```

In cua-driver 0.34.0, a missing `gdbus` executable produces the same warning as a failed bus connection. The image installs `libglib2.0-bin` to supply it. Record actual probe output rather than treating the warning as an expected Linux limitation.

A frame-only native Chrome tree does not prove page-content accessibility. CDP semantic snapshots are a separate capability. For native Chrome accessibility testing, confirm renderer accessibility is enabled for the launched browser.

Report PASS, FAIL, PARTIAL, EXPECTED LIMIT, or NOT TESTED based on observed results. Continue independent checks after a diagnostic failure where safe. Do not stop the daemon, terminate unrelated apps, destroy the box, change versions, or install dependencies without user approval.
