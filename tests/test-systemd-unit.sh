#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
UNIT="$ROOT/systemd/ploos-appliance-agent.service"

grep -q '^Type=oneshot$' "$UNIT"
grep -q '^RuntimeDirectory=netns crun$' "$UNIT"
grep -q '^RuntimeDirectoryMode=0755$' "$UNIT"
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
grep -q '^ReadWritePaths=/run/lock$' "$UNIT"
grep -q '^ReadWritePaths=/run/netns$' "$UNIT"
grep -q '^ReadWritePaths=/run/crun$' "$UNIT"

if command -v systemd-analyze >/dev/null 2>&1; then
    created_agent=0
    created_cli=0

    cleanup() {
        if [ "$created_agent" -eq 1 ]; then
            sudo rm -f /usr/local/lib/ploos-appliance/agent
            sudo rmdir /usr/local/lib/ploos-appliance 2>/dev/null || true
        fi
        if [ "$created_cli" -eq 1 ]; then
            sudo rm -f /usr/local/bin/ploos-appliance
        fi
    }
    trap cleanup EXIT HUP INT TERM

    if [ ! -x /usr/local/lib/ploos-appliance/agent ]; then
        sudo mkdir -p /usr/local/lib/ploos-appliance
        printf '#!/bin/sh\nexit 0\n' | sudo tee /usr/local/lib/ploos-appliance/agent >/dev/null
        sudo chmod 0755 /usr/local/lib/ploos-appliance/agent
        created_agent=1
    fi

    if [ ! -x /usr/local/bin/ploos-appliance ]; then
        sudo mkdir -p /usr/local/bin
        printf '#!/bin/sh\nexit 0\n' | sudo tee /usr/local/bin/ploos-appliance >/dev/null
        sudo chmod 0755 /usr/local/bin/ploos-appliance
        created_cli=1
    fi

    systemd-analyze verify "$UNIT"
fi

echo "systemd unit qualification: PASS"
