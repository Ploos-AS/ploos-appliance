#!/bin/sh
set -eu

# DietPi executes /boot/Automation_Custom_Script.sh at the end of its
# automated first-boot installation when AUTO_SETUP_CUSTOM_SCRIPT_EXEC=1.
# Copy this file to /boot/Automation_Custom_Script.sh together with a checkout
# or release bundle at /boot/ploos-appliance.

SOURCE=${PLOOS_BOOTSTRAP_SOURCE:-/boot/ploos-appliance}

if [ ! -x "$SOURCE/scripts/bootstrap.sh" ]; then
    echo "ploos-appliance: bootstrap not found at $SOURCE" >&2
    exit 1
fi

exec "$SOURCE/scripts/bootstrap.sh"
