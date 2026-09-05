# Architecture

## Layers

1. **Hardware** — Orange Pi Zero 3 is the first reference platform.
2. **Base OS** — upstream DietPi provides board support, kernel, boot, base networking and package management.
3. **Ploos platform layer** — bootstrap, appliance manifest, lifecycle policy, health integration and host defaults.
4. **Appliance workload** — role-specific OCI containers or native services where hardware access or simplicity makes that preferable.

## Host/container boundary

The host owns:

- network configuration
- mounts and storage lifecycle
- `/data` creation and permissions
- nftables/firewall baseline
- watchdog
- time synchronization
- container runtime
- systemd service supervision
- platform bootstrap and update orchestration

The appliance workload owns:

- role-specific application logic
- role-specific HTTP/API/UI services
- application configuration below `/data`
- workload health endpoint/check

## Persistence contract

`/data` is the stable persistent root for appliance state. Workloads must not rely on mutable state inside an OCI image. A role may create subdirectories such as `/data/config`, `/data/state`, `/data/cache`, `/data/log` and `/data/input` as needed.

## Manifest

The appliance manifest is the declarative interface between platform and role. Version 0 intentionally contains only identity, runtime image, persistence and capability declarations. See `schema/appliance.schema.json`.

## Provisioning

DietPi unattended/first-boot facilities invoke the Ploos bootstrap. The bootstrap validates prerequisites, prepares `/data`, installs host integration and enables the selected appliance role. M0 provides a safe skeleton only; M1 makes this executable and qualified.

## Reference target

Orange Pi Zero 3 is the first hardware qualification target. M1 qualification should cover boot, Ethernet, storage, USB access required by the role, reboot persistence, watchdog recovery and clean service restart.
