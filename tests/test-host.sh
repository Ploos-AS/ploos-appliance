#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/bin" "$TMP/config" "$TMP/data"
cp "$ROOT/examples/manifests/amiga-antivirus.yaml" "$TMP/config/appliance.yaml"

cat >"$TMP/bin/fake-runtime" <<'EOF'
#!/bin/sh
set -eu
STATE=${FAKE_RUNTIME_STATE:?}
cmd=${1:-}
shift || true
case "$cmd" in
  inspect)
    [ -f "$STATE" ]
    ;;
  run)
    : >"$STATE"
    ;;
  start|restart)
    [ -f "$STATE" ]
    ;;
  stop)
    [ -f "$STATE" ]
    ;;
  *)
    echo "unexpected runtime command: $cmd" >&2
    exit 1
    ;;
esac
EOF
chmod +x "$TMP/bin/fake-runtime"

export PLOOS_CONFIG_DIR="$TMP/config"
export PLOOS_DATA_ROOT="$TMP/data"
export PLOOS_MANIFEST="$TMP/config/appliance.yaml"
export PLOOS_VALIDATOR="$ROOT/lib/validate-manifest.py"
export PLOOS_SCHEMA="$ROOT/schema/appliance.schema.json"
export PLOOS_RUNTIME="$TMP/bin/fake-runtime"
export FAKE_RUNTIME_STATE="$TMP/runtime.state"

python3 "$ROOT/lib/validate-manifest.py" --manifest "$PLOOS_MANIFEST" --schema "$PLOOS_SCHEMA" >/dev/null

status=$(sh "$ROOT/bin/ploos-appliance" status)
printf '%s\n' "$status" | grep -q '^manifest=valid$'
printf '%s\n' "$status" | grep -q '^workload=absent$'

sh "$ROOT/bin/ploos-appliance" start
[ -f "$FAKE_RUNTIME_STATE" ]
[ -d "$PLOOS_DATA_ROOT" ]

sh "$ROOT/bin/ploos-appliance" start
status=$(sh "$ROOT/bin/ploos-appliance" status)
printf '%s\n' "$status" | grep -q '^workload=present$'

sh "$ROOT/bin/ploos-appliance" restart
sh "$ROOT/bin/ploos-appliance" stop

echo "host lifecycle tests: PASS"
