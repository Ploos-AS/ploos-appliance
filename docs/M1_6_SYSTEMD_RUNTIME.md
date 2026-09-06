# M1.6 — systemd-managed Podman runtime qualification

M1.6 qualifies the Ploos Appliance workload lifecycle when Podman is invoked by the hardened platform systemd unit.

## Qualified path

The CI integration test installs the production platform paths on an ephemeral Ubuntu 24.04 runner, builds the deterministic test workload with rootful Podman, installs the test appliance manifest, and exercises the real systemd service.

The qualification covers:

- manifest validation before workload start
- systemd service enablement
- rootful Podman container creation and start
- workload health becoming ready
- persistent `/data` across lifecycle operations
- systemd restart causing a second workload boot
- explicit service stop causing workload stop
- hardened service execution with `ProtectSystem=strict`

During qualification, the hardened systemd sandbox exposed required Podman runtime paths incrementally from observed failures. The final unit grants write access only to the required storage/runtime locations, including `/run/lock`, `/run/netns`, and `/run/crun`; systemd creates the latter runtime directories before entering the service sandbox.

## Evidence

GitHub Actions CI run #45 (`34029825930`) completed successfully on commit `e22847558d429065320d3e716c7aad3cb2070f57`.

At that point the host lifecycle, systemd unit, Docker lifecycle, Podman lifecycle, and systemd-managed Podman lifecycle gates all passed.

## Remaining hardware qualification

M1.6 does not replace target-hardware qualification. M1 still requires validation on a clean current DietPi image on Orange Pi Zero 3, including first-boot provisioning, reboot recovery, service recovery, and persistence of `/data`.
