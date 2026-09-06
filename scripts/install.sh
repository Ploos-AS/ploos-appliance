#!/bin/sh
set -eu

PREFIX=${PLOOS_PREFIX:-/usr/local}
CONFIG_DIR=${PLOOS_CONFIG_DIR:-/etc/ploos-appliance}
DATA_ROOT=${PLOOS_DATA_ROOT:-/data}
SOURCE_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ "$(id -u)" -ne 0 ]; then
    echo "install.sh must run as root" >&2
    exit 1
fi

install -d -m 0755 "$PREFIX/bin" "$PREFIX/lib/ploos-appliance" "$CONFIG_DIR"
install -d -m 0750 "$DATA_ROOT"
install -m 0755 "$SOURCE_DIR/bin/ploos-appliance" "$PREFIX/bin/ploos-appliance"
install -m 0755 "$SOURCE_DIR/lib/validate-manifest.py" "$PREFIX/lib/ploos-appliance/validate-manifest.py"
install -m 0644 "$SOURCE_DIR/schema/appliance.schema.json" "$PREFIX/lib/ploos-appliance/appliance.schema.json"
install -m 0755 "$SOURCE_DIR/lib/agent" "$PREFIX/lib/ploos-appliance/agent"

if [ ! -f "$CONFIG_DIR/appliance.yaml" ]; then
    install -m 0640 "$SOURCE_DIR/examples/manifests/amiga-antivirus.yaml" "$CONFIG_DIR/appliance.yaml"
fi

if command -v systemctl >/dev/null 2>&1; then
    install -m 0644 "$SOURCE_DIR/systemd/ploos-appliance-agent.service" /etc/systemd/system/ploos-appliance-agent.service
    systemctl daemon-reload
    systemctl enable ploos-appliance-agent.service >/dev/null
fi

echo "Ploos Appliance platform installed"
echo "Run: ploos-appliance validate"
