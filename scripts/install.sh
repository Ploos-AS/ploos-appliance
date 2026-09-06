#!/bin/sh
set -eu

PREFIX=${PLOOS_PREFIX:-/usr/local}
CONFIG_DIR=${PLOOS_CONFIG_DIR:-/etc/ploos-appliance}
DATA_ROOT=${PLOOS_DATA_ROOT:-/data}
MANIFEST_SOURCE=${PLOOS_MANIFEST_SOURCE:-}
RUNTIME_CHOICE=${PLOOS_RUNTIME_CHOICE:-}
SKIP_SYSTEMD=${PLOOS_SKIP_SYSTEMD:-0}
SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ "$(id -u)" -ne 0 ]; then
    echo "install.sh must run as root" >&2
    exit 1
fi

case "$RUNTIME_CHOICE" in
    ""|podman|docker) ;;
    *)
        echo "unsupported runtime choice: $RUNTIME_CHOICE" >&2
        exit 1
        ;;
esac

install -d -m 0755 "$PREFIX/bin" "$PREFIX/lib/ploos-appliance" "$CONFIG_DIR"
install -d -m 0750 "$DATA_ROOT"
install -m 0755 "$SOURCE_DIR/bin/ploos-appliance" "$PREFIX/bin/ploos-appliance"
install -m 0755 "$SOURCE_DIR/lib/validate-manifest.py" "$PREFIX/lib/ploos-appliance/validate-manifest.py"
install -m 0644 "$SOURCE_DIR/schema/appliance.schema.json" "$PREFIX/lib/ploos-appliance/appliance.schema.json"
install -m 0755 "$SOURCE_DIR/lib/agent" "$PREFIX/lib/ploos-appliance/agent"

if [ -n "$RUNTIME_CHOICE" ]; then
    printf 'PLOOS_RUNTIME=%s\n' "$RUNTIME_CHOICE" >"$CONFIG_DIR/runtime.env"
    chmod 0640 "$CONFIG_DIR/runtime.env"
fi

if [ -n "$MANIFEST_SOURCE" ] && [ ! -f "$CONFIG_DIR/appliance.yaml" ]; then
    if [ ! -f "$MANIFEST_SOURCE" ]; then
        echo "manifest source not found: $MANIFEST_SOURCE" >&2
        exit 1
    fi
    install -m 0640 "$MANIFEST_SOURCE" "$CONFIG_DIR/appliance.yaml"
fi

if [ "$SKIP_SYSTEMD" != 1 ] && command -v systemctl >/dev/null 2>&1; then
    install -m 0644 "$SOURCE_DIR/systemd/ploos-appliance-agent.service" /etc/systemd/system/ploos-appliance-agent.service
    systemctl daemon-reload
    if [ -f "$CONFIG_DIR/appliance.yaml" ]; then
        systemctl enable ploos-appliance-agent.service >/dev/null
    else
        systemctl disable ploos-appliance-agent.service >/dev/null 2>&1 || true
    fi
fi

echo "Ploos Appliance platform installed"
if [ -n "$RUNTIME_CHOICE" ]; then
    echo "OCI runtime: $RUNTIME_CHOICE"
fi
if [ -f "$CONFIG_DIR/appliance.yaml" ]; then
    echo "Active manifest: $CONFIG_DIR/appliance.yaml"
    echo "Run: ploos-appliance validate"
else
    echo "No appliance profile selected; workload service remains disabled"
fi
