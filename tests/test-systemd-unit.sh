#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
UNIT="$ROOT/systemd/ploos-appliance-agent.service"

grep -q '^Type=oneshot$' "$UNIT"
grep -q '^ExecStart=/usr/local/lib/ploos-appliance/agent$' "$UNIT"
grep -q '^ExecStop=/usr/local/bin/ploos-appliance stop$' "$UNIT"
grep -q '^RemainAfterExit=yes$' "$UNIT"
grep -q '^NoNewPrivileges=yes$' "$UNIT"
grep -q '^ProtectSystem=strict$' "$UNIT"
grep -q '^ProtectHome=yes$' "$UNIT"
grep -q '^PrivateTmp=yes$' "$UNIT"
grep -q '^ReadWritePaths=/data$' "$UNIT"
grep -q '^ReadWritePaths=-/var/lib/containers$' "$UNIT"
grep -q '^ReadWritePaths=-/run/containers$' "$UNIT"
grep -q '^ReadWritePaths=-/run/libpod$' "$UNIT"

if command -v systemd-analyze >/dev/null 2>&1; then
    systemd-analyze verify "$UNIT"
fi

echo "systemd unit qualification: PASS"
