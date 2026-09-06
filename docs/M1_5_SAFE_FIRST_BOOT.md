# M1.5 — Safe first boot and explicit appliance selection

## Purpose

M1.5 removes the implicit appliance workload from a fresh platform installation. The Ploos Appliance Platform may be installed without selecting a role, and no appliance workload is enabled until a manifest is explicitly supplied.

## First-boot contract

The provisioning sequence is:

1. DietPi boots and runs the Ploos bootstrap.
2. The platform and selected OCI runtime are installed.
3. If no appliance manifest was supplied, `/etc/ploos-appliance/appliance.yaml` is not created and `ploos-appliance-agent.service` remains disabled.
4. If `PLOOS_MANIFEST_SOURCE` points to a manifest, that manifest becomes the active `/etc/ploos-appliance/appliance.yaml` on a fresh installation.
5. Existing active configuration is preserved on subsequent installer runs and is never replaced merely because a different `PLOOS_MANIFEST_SOURCE` is supplied.
6. When an active manifest exists, bootstrap validates it before reporting the appliance as configured.

This makes appliance selection explicit. `amiga-antivirus` is an example/reference role, not the default role of every Ploos appliance.

## Host qualification

`tests/test-host.sh` qualifies the hardware-independent M1.5 behavior:

- fresh install without a profile leaves the platform unconfigured;
- platform binaries and `/data` are still installed in the unconfigured state;
- explicit profile selection installs the requested manifest unchanged;
- rerunning the installer with another requested profile does not overwrite existing configuration;
- existing lifecycle, manifest, bootstrap-guard, and DietPi-hook tests remain in place.

`PLOOS_SKIP_SYSTEMD=1` exists for host-side installer qualification so tests can exercise installer behavior without modifying the runner's systemd configuration. Production bootstrap does not set it.

## Systemd behavior

On a production host where systemd is available:

- an active appliance manifest causes `ploos-appliance-agent.service` to be enabled;
- an installation without an active manifest leaves the service disabled;
- the unit itself remains subject to the M1.4 systemd qualification.

## Remaining qualification

M1.5 does not yet prove the complete physical first-boot path on Orange Pi Zero 3. Remaining M1 hardware work includes:

- current DietPi first-boot mechanism verification;
- clean-image provisioning on Orange Pi Zero 3;
- real service start through systemd with the selected runtime;
- reboot recovery and `/data` persistence;
- hardware-visible status/health verification.

Until those gates pass, M1.5 should be described as host/CI qualified, not hardware qualified.
