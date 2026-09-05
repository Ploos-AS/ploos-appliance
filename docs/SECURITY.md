# Security Baseline

M0 establishes minimum platform expectations; M1 must validate them on hardware.

- No appliance service should require direct root execution unless technically necessary.
- Prefer rootless or otherwise least-privilege OCI workloads.
- Do not expose management services publicly by default.
- SSH remains a host concern and should use key-based administration where practical.
- nftables provides the host firewall baseline.
- Workloads receive only required device mounts, capabilities and network exposure.
- Persistent secrets belong below `/data` with restrictive permissions and must not be baked into images or committed to the repository.
- OCI images should be pinned by release tag for normal use and may additionally be verified by digest.
- OS, platform and workload updates are separate trust/update domains.
- Logs must avoid credentials and secret material.

Security-sensitive appliance roles may impose stricter profiles on top of this baseline.
