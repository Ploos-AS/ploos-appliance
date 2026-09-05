# Update Model

Ploos Appliance separates three update domains so a workload release does not require rebuilding the base OS.

## 1. Base OS

DietPi/Debian packages and board support are updated through the supported upstream mechanisms. Ploos does not fork or replace DietPi's package lifecycle.

## 2. Platform layer

Ploos bootstrap, systemd integration, schema and platform policy are versioned by this repository. Platform updates must preserve the `/data` contract and remain backward-compatible with supported manifest versions or fail safely.

## 3. Appliance workload

Role-specific OCI images are released independently. Production profiles should use explicit release tags rather than `latest`; deployments may additionally pin a digest.

## Rollback principle

Workload rollback must not destroy `/data`. Platform changes that alter persistent formats require an explicit migration and rollback plan. Base-OS rollback is hardware/image-specific and is outside the M0 implementation scope.
