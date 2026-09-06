#!/bin/sh
set -eu

DATA_ROOT=${PLOOS_DATA_ROOT:-/data}
RUNTIME=${PLOOS_RUNTIME_CHOICE:-podman}
SKIP_PACKAGES=${PLOOS_SKIP_PACKAGES:-0}
MANIFEST_SOURCE=${PLOOS_MANIFEST_SOURCE:-}
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

log() {
    printf '%s\n' "ploos-appliance: $*"
}

if [ "$(id -u)" -ne 0 ]; then
    log "bootstrap must run as root"
    exit 1
fi

if [ ! -r /etc/os-release ]; then
    log "cannot identify host: /etc/os-release missing"
    exit 1
fi

# DietPi identifies itself through /boot/dietpi and/or DietPi-specific
# os-release metadata. Allow CI/derived Debian hosts when explicitly requested.
if [ "${PLOOS_ALLOW_NON_DIETPI:-0}" != 1 ]; then
    if [ ! -d /boot/dietpi ] && ! grep -qi 'dietpi' /etc/os-release; then
        log "unsupported host: DietPi required"
        exit 1
    fi
fi

case "$RUNTIME" in
    podman) runtime_package=podman ;;
    docker) runtime_package=docker.io ;;
    *)
        log "unsupported runtime choice: $RUNTIME"
        exit 1
        ;;
esac

if [ "$SKIP_PACKAGES" != 1 ]; then
    export DEBIAN_FRONTEND=noninteractive
    log "installing platform dependencies and ${RUNTIME} runtime"
    apt-get update
    apt-get install -y --no-install-recommends python3 python3-yaml python3-jsonschema "$runtime_package"
else
    log "package installation skipped"
fi

install -d -m 0750 "$DATA_ROOT"

log "installing Ploos Appliance platform"
PLOOS_DATA_ROOT="$DATA_ROOT" \
PLOOS_MANIFEST_SOURCE="$MANIFEST_SOURCE" \
PLOOS_RUNTIME_CHOICE="$RUNTIME" \
sh "$SCRIPT_DIR/install.sh"

if [ -f /etc/ploos-appliance/appliance.yaml ]; then
    log "validating installed appliance profile"
    /usr/local/bin/ploos-appliance validate
    log "bootstrap complete; appliance profile configured"
else
    log "bootstrap complete; no appliance profile selected"
fi
