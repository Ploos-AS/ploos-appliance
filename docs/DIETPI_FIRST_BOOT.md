# DietPi unattended first boot

M1.2 defines the first-boot integration used to turn an upstream DietPi installation into a Ploos Appliance host. DietPi remains upstream and is not forked.

## Runtime choice

Podman is the default OCI runtime for the platform. Set `PLOOS_RUNTIME_CHOICE=docker` before bootstrap to install Docker instead. The workload CLI still detects Podman first and Docker second unless `PLOOS_RUNTIME` explicitly overrides it.

## Image preparation

1. Flash a supported upstream DietPi image for the target board.
2. Configure DietPi unattended setup in `/boot/dietpi.txt` as normal for site-specific networking, locale, credentials and SSH policy.
3. Enable DietPi's custom automation script with `AUTO_SETUP_CUSTOM_SCRIPT_EXEC=1`.
4. Place this repository or a release bundle at `/boot/ploos-appliance`.
5. Copy `dietpi/Automation_Custom_Script.sh` to `/boot/Automation_Custom_Script.sh` and make it executable.
6. Boot the board.

The custom script invokes `scripts/bootstrap.sh` after DietPi's automated first-boot work.

## Bootstrap behavior

The bootstrap:

- refuses non-DietPi hosts by default;
- installs Python, PyYAML, jsonschema and the selected OCI runtime through APT;
- creates `/data` with mode 0750;
- installs the platform through `scripts/install.sh`;
- installs/enables the systemd agent when systemd is available;
- validates the installed appliance manifest before reporting success.

For CI only, `PLOOS_ALLOW_NON_DIETPI=1` bypasses the host identity gate and `PLOOS_SKIP_PACKAGES=1` suppresses APT operations. These are test controls, not production provisioning defaults.

## Idempotence

Re-running bootstrap is supported. Package installation is idempotent, directories are recreated safely, platform files are replaced with the current bundle, and an existing `/etc/ploos-appliance/appliance.yaml` is preserved by `install.sh`.

## Security boundary

The first-boot script does not configure site credentials, expose application ports, or weaken DietPi SSH policy. Those remain explicit site/platform configuration. Appliance workloads are not started until their manifest validates.

## Hardware qualification still required

CI can validate the provisioning logic but cannot prove board support, bootloader/kernel behavior, storage persistence, runtime operation, watchdog behavior or power-loss recovery. Those gates remain for Orange Pi Zero 3 hardware qualification.
