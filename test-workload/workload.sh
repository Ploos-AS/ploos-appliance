#!/bin/sh
set -eu

mkdir -p /data
printf '%s\n' "ploos-appliance-test-workload" > /data/workload.identity
if [ ! -f /data/boot-count ]; then
    printf '0\n' > /data/boot-count
fi
count=$(cat /data/boot-count)
count=$((count + 1))
printf '%s\n' "$count" > /data/boot-count
printf '%s\n' "ready" > /data/health

trap 'printf "%s\n" stopped > /data/health; exit 0' TERM INT
while :; do
    sleep 3600 &
    wait $!
done
