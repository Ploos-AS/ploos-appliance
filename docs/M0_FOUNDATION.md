# M0 Foundation

## Goal

Establish a minimal, reusable platform contract for Ploos appliances based on DietPi.

## Locked decisions

- DietPi is the upstream base OS; Ploos Appliance does not fork it.
- Orange Pi Zero 3 is the first reference hardware target.
- ARM64 is the first-class architecture for the initial hardware target.
- Host-level responsibilities stay on the host: networking, storage, firewall, watchdog, time sync and appliance supervision.
- Appliance workloads should use OCI containers where practical.
- Persistent appliance state lives under `/data`.
- systemd is the host service manager.
- OS/platform updates are separated from appliance workload updates.
- Source distribution follows Forgejo canonical -> GitHub + Codeberg mirrors.
- OCI publication targets GHCR + Docker Hub.

## Deliverables

- [x] Architecture document
- [x] Repository layout
- [x] Appliance manifest v0 schema and example
- [x] DietPi bootstrap skeleton
- [x] Host/container responsibility boundary
- [x] `/data` persistence contract
- [x] Update model
- [x] Security baseline
- [x] Orange Pi Zero 3 reference target definition
- [x] M1 roadmap
- [x] MIT license
- [x] Basic CI/hygiene checks

## Qualification

M0 qualification completed on 2026-09-06.

- GitHub Actions CI: PASS
- Bootstrap shell syntax: PASS
- JSON schema syntax: PASS
- Whitespace hygiene: PASS
- CI checkout history regression corrected by using `actions/checkout@v5` with `fetch-depth: 2`

Qualified HEAD before this documentation-only qualification record: `4f04fb5f7aa0b0b9b9b2cd3954611b0e9e13dfda`.

## Exit criteria

M0 is complete when the platform contract can be reviewed and consumed without relying on undocumented assumptions, and repository hygiene checks are in place.

**Status: COMPLETE.**

## M1 preview

M1 turns the contract into a runnable prototype on DietPi and qualifies bootstrap, manifest validation, service lifecycle, persistence and reboot behavior on Orange Pi Zero 3.
