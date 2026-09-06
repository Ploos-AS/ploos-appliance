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

# M1.5: a fresh platform install must not silently select a workload.
SAFE_PREFIX="$TMP/safe-prefix"
SAFE_CONFIG="$TMP/safe-config"
SAFE_DATA="$TMP/safe-data"
sudo env \
    PLOOS_PREFIX="$SAFE_PREFIX" \
    PLOOS_CONFIG_DIR="$SAFE_CONFIG" \
    PLOOS_DATA_ROOT="$SAFE_DATA" \
    PLOOS_SKIP_SYSTEMD=1 \
    sh "$ROOT/scripts/install.sh" >/dev/null
[ ! -e "$SAFE_CONFIG/appliance.yaml" ]
[ -x "$SAFE_PREFIX/bin/ploos-appliance" ]
[ -d "$SAFE_DATA" ]

# An explicitly selected profile must be installed unchanged.
PROFILE_PREFIX="$TMP/profile-prefix"
PROFILE_CONFIG="$TMP/profile-config"
PROFILE_DATA="$TMP/profile-data"
sudo env \
    PLOOS_PREFIX="$PROFILE_PREFIX" \
    PLOOS_CONFIG_DIR="$PROFILE_CONFIG" \
    PLOOS_DATA_ROOT="$PROFILE_DATA" \
    PLOOS_MANIFEST_SOURCE="$ROOT/examples/manifests/test-workload.yaml" \
    PLOOS_SKIP_SYSTEMD=1 \
    sh "$ROOT/scripts/install.sh" >/dev/null
cmp "$ROOT/examples/manifests/test-workload.yaml" "$PROFILE_CONFIG/appliance.yaml"

# Existing configuration must never be replaced by a later profile request.
sudo env \
    PLOOS_PREFIX="$PROFILE_PREFIX" \
    PLOOS_CONFIG_DIR="$PROFILE_CONFIG" \
    PLOOS_DATA_ROOT="$PROFILE_DATA" \
    PLOOS_MANIFEST_SOURCE="$ROOT/examples/manifests/amiga-antivirus.yaml" \
    PLOOS_SKIP_SYSTEMD=1 \
    sh "$ROOT/scripts/install.sh" >/dev/null
cmp "$ROOT/examples/manifests/test-workload.yaml" "$PROFILE_CONFIG/appliance.yaml"

# Bootstrap policy is testable without mutating the CI host: unsupported
# runtime values must fail before package or install operations begin.
if PLOOS_RUNTIME_CHOICE=invalid PLOOS_ALLOW_NON_DIETPI=1 PLOOS_SKIP_PACKAGES=1 \
    PLOOS_DATA_ROOT="$TMP/bootstrap-data" sh "$ROOT/scripts/bootstrap.sh" >/dev/null 2>&1; then
    echo "bootstrap accepted invalid runtime" >&2
    exit 1
fi

# The DietPi hook must fail clearly when its release bundle is absent.
if PLOOS_BOOTSTRAP_SOURCE="$TMP/missing" sh "$ROOT/dietpi/Automation_Custom_Script.sh" >/dev/null 2>&1; then
    echo "DietPi hook accepted missing bootstrap source" >&2
    exit 1
fi

echo "host lifecycle tests: PASS"
