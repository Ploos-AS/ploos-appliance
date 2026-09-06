#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
IMAGE=localhost/ploos-appliance-test:0.1.0
SERVICE=ploos-appliance-agent.service
CONTAINER=ploos-appliance-workload

if [ "$(id -u)" -ne 0 ]; then
    echo "test-systemd-runtime.sh must run as root" >&2
    exit 1
fi

command -v systemctl >/dev/null 2>&1 || {
    echo "systemctl is required" >&2
    exit 1
}
command -v podman >/dev/null 2>&1 || {
    echo "podman is required" >&2
    exit 1
}

cleanup() {
    systemctl stop "$SERVICE" >/dev/null 2>&1 || true
    systemctl disable "$SERVICE" >/dev/null 2>&1 || true
    podman rm -f "$CONTAINER" >/dev/null 2>&1 || true
    podman rmi -f "$IMAGE" >/dev/null 2>&1 || true
    rm -f /etc/systemd/system/ploos-appliance-agent.service
    rm -rf /etc/ploos-appliance
    rm -f /usr/local/bin/ploos-appliance
    rm -rf /usr/local/lib/ploos-appliance
    if [ -f /data/workload.identity ] && grep -qx 'ploos-appliance-test-workload' /data/workload.identity; then
        rm -rf /data
    fi
    systemctl daemon-reload >/dev/null 2>&1 || true
}
trap cleanup EXIT HUP INT TERM

# Start from a clean ephemeral-host state.
cleanup
trap cleanup EXIT HUP INT TERM
install -d -m 0750 /data

podman build \
    -f "$ROOT/test-workload/Containerfile" \
    -t "$IMAGE" \
    "$ROOT/test-workload" >/dev/null

PLOOS_MANIFEST_SOURCE="$ROOT/examples/manifests/test-workload.yaml" \
    sh "$ROOT/scripts/install.sh" >/dev/null

systemctl is-enabled --quiet "$SERVICE"
/usr/local/bin/ploos-appliance validate >/dev/null

systemctl start "$SERVICE"
systemctl is-active --quiet "$SERVICE"

ready=0
i=0
while [ "$i" -lt 20 ]; do
    if [ -f /data/health ] && grep -qx 'ready' /data/health; then
        ready=1
        break
    fi
    i=$((i + 1))
    sleep 1
done
[ "$ready" -eq 1 ] || {
    systemctl status "$SERVICE" --no-pager || true
    podman ps -a || true
    echo "workload did not become ready" >&2
    exit 1
}

grep -qx 'ploos-appliance-test-workload' /data/workload.identity
[ "$(cat /data/boot-count)" = 1 ]
podman inspect "$CONTAINER" >/dev/null

systemctl restart "$SERVICE"
systemctl is-active --quiet "$SERVICE"

restarted=0
i=0
while [ "$i" -lt 20 ]; do
    if [ -f /data/health ] && grep -qx 'ready' /data/health && [ "$(cat /data/boot-count 2>/dev/null || true)" = 2 ]; then
        restarted=1
        break
    fi
    i=$((i + 1))
    sleep 1
done
[ "$restarted" -eq 1 ] || {
    systemctl status "$SERVICE" --no-pager || true
    podman ps -a || true
    echo "workload did not recover after systemd restart" >&2
    exit 1
}

systemctl stop "$SERVICE"
! systemctl is-active --quiet "$SERVICE"

grep -qx 'stopped' /data/health
state=$(podman inspect --format '{{.State.Status}}' "$CONTAINER")
[ "$state" = exited ] || [ "$state" = stopped ]

# Persistence survives service lifecycle operations.
[ "$(cat /data/boot-count)" = 2 ]
grep -qx 'ploos-appliance-test-workload' /data/workload.identity

echo "systemd Podman integration qualification: PASS"
