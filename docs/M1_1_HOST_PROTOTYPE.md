# M1.1 Host Prototype

## Scope

M1.1 establishes the hardware-independent host-side prototype for the Ploos Appliance Platform.

## Implemented

- `bin/ploos-appliance` lifecycle CLI with `validate`, `start`, `stop`, `restart` and `status`.
- YAML manifest validation against the M0 JSON Schema.
- Podman-first OCI runtime detection with Docker fallback and an explicit `PLOOS_RUNTIME` override for testing.
- Stable `/data` bind mount for workload persistence.
- Idempotent workload start behavior: create when absent, start when already present.
- Minimal host installer for `/usr/local` and `/etc/ploos-appliance`.
- systemd agent entry point.
- Hardware-independent fake-runtime lifecycle tests.

## Dependencies

The manifest validator currently requires Python 3, PyYAML and jsonschema. DietPi installation/provisioning of these dependencies is intentionally deferred to the DietPi integration step rather than hidden inside the validator.

## Qualification

GitHub Actions CI passes:

- POSIX shell syntax checks
- Python syntax compilation
- JSON Schema parse check
- manifest validation
- fake OCI runtime lifecycle
- `/data` creation/persistence contract
- repeat start/idempotency path
- status path for absent and present workload
- whitespace hygiene

CI run 9 on commit `ce78fcfb90764c7296204c067a5db636f7627fb6` passed.

## Not yet qualified

M1.1 does not claim:

- DietPi unattended first-boot integration
- automatic installation/configuration of Podman or Docker
- production rootless runtime policy
- real OCI image execution
- Orange Pi Zero 3 hardware operation
- reboot persistence on hardware
- watchdog recovery

These remain M1 work.
