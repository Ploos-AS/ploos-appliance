#!/bin/sh
set -eu

DATA_ROOT=${PLOOS_DATA_ROOT:-/data}

log() {
    printf '%s\n' "ploos-appliance: $*"
}

if [ "$(id -u)" -ne 0 ]; then
    log "bootstrap must run as root"
    exit 1
fi

log "preparing persistent root at ${DATA_ROOT}"
install -d -m 0750 "${DATA_ROOT}"

log "M0 bootstrap skeleton complete"
log "M1 will add DietPi integration, manifest validation and workload lifecycle management"
