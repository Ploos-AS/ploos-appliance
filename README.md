# Ploos Appliance Platform

Reusable appliance foundation for Ploos projects, built on upstream DietPi.

## M0 scope

M0 defines the platform contract before hardware qualification or production images.

- Base OS: DietPi
- Reference hardware: Orange Pi Zero 3
- Primary architecture: ARM64
- Host supervision: systemd
- Application packaging: OCI/container-first where practical
- Persistent application state: `/data`
- Initial reference roles: Amiga Antivirus Appliance and Atari Antivirus Appliance

DietPi remains upstream. This project adds a Ploos-owned provisioning, lifecycle and appliance contract layer; it is not a DietPi fork.

See `docs/M0_FOUNDATION.md` and `docs/ARCHITECTURE.md`.

## License

MIT. See `LICENSE`.
