# Ploos Appliance Platform

Reusable appliance foundation for Ploos projects, built on upstream DietPi.

## Platform

- Base OS: DietPi
- Reference hardware: Orange Pi Zero 3
- Primary architecture: ARM64
- Host supervision: systemd
- Application packaging: OCI/container-first where practical
- OCI runtime: Podman first, Docker fallback
- Persistent application state: `/data`
- Initial reference roles: Amiga Antivirus Appliance and Atari Antivirus Appliance

DietPi remains upstream. This project adds a Ploos-owned provisioning, lifecycle and appliance contract layer; it is not a DietPi fork.

## M1 host prototype

The hardware-independent M1.1 prototype provides manifest validation and workload lifecycle commands:

```sh
ploos-appliance validate
ploos-appliance start
ploos-appliance status
ploos-appliance restart
ploos-appliance stop
```

See `docs/M1_1_HOST_PROTOTYPE.md` for qualification scope and limitations.

## Documentation

- `docs/M0_FOUNDATION.md`
- `docs/ARCHITECTURE.md`
- `docs/SECURITY.md`
- `docs/UPDATE_MODEL.md`
- `docs/M1_1_HOST_PROTOTYPE.md`

## License

MIT. See `LICENSE`.
