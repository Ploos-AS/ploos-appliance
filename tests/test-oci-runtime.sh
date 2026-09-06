#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
RUNTIME=${1:-podman}
TMP=$(mktemp -d)
NAME="ploos-appliance-m13-$$"
IMAGE=localhost/ploos-appliance-test:0.1.0
trap '"$RUNTIME" rm -f "$NAME" >/dev/null 2>&1 || true; rm -rf "$TMP"' EXIT

command -v "$RUNTIME" >/dev/null 2>&1 || {
    echo "$RUNTIME unavailable" >&2
    exit 77
}

"$RUNTIME" build -t "$IMAGE" "$ROOT/test-workload"
mkdir -p "$TMP/config" "$TMP/data"
cp "$ROOT/examples/manifests/test-workload.yaml" "$TMP/config/appliance.yaml"

export PLOOS_CONFIG_DIR="$TMP/config"
export PLOOS_DATA_ROOT="$TMP/data"
export PLOOS_MANIFEST="$TMP/config/appliance.yaml"
export PLOOS_VALIDATOR="$ROOT/lib/validate-manifest.py"
export PLOOS_SCHEMA="$ROOT/schema/appliance.schema.json"
export PLOOS_RUNTIME="$RUNTIME"
export PLOOS_CONTAINER_NAME="$NAME"

sh "$ROOT/bin/ploos-appliance" validate >/dev/null
sh "$ROOT/bin/ploos-appliance" start

for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ -f "$TMP/data/health" ] && break
    sleep 1
done
[ "$(cat "$TMP/data/health")" = ready ]
[ "$(cat "$TMP/data/boot-count")" = 1 ]

status=$(sh "$ROOT/bin/ploos-appliance" status)
printf '%s\n' "$status" | grep -q '^manifest=valid$'
printf '%s\n' "$status" | grep -q "^runtime=$RUNTIME$"
printf '%s\n' "$status" | grep -q '^workload=present$'

sh "$ROOT/bin/ploos-appliance" restart
for _ in 1 2 3 4 5 6 7 8 9 10; do
    [ "$(cat "$TMP/data/boot-count" 2>/dev/null || true)" = 2 ] && break
    sleep 1
done
[ "$(cat "$TMP/data/boot-count")" = 2 ]
[ "$(cat "$TMP/data/workload.identity")" = ploos-appliance-test-workload ]

sh "$ROOT/bin/ploos-appliance" stop

echo "real OCI runtime qualification ($RUNTIME): PASS"
