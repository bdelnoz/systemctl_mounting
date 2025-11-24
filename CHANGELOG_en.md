# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Coming Soon
- Automatic configuration for Swift SF514-51
- Multiple mounting profile support
- Graphical management interface

---

## [1.0.0] - 2025-11-24

### Added
- Automatic installation script `install_mounting.sh`
- Systemd service `mount-all-data.service` for boot-time mounting
- Main script `mount_all_data.sh` v7.1
- Automatic machine detection (OptiPlex 7020 / Swift SF514-51)
- LUKS encrypted volume mounting with key file support
- NTFS mounting via ntfs-3g
- FAT32 mounting support
- EXT4 unencrypted mounting support
- LUKS encrypted swap mounting support
- Automatic permission management (nox:nox)
- Detailed logging in `/var/log/mount_all_data.sh.v7.1.log`
- Parallel USB volume mounting for optimal performance
- System prerequisite verification (cryptsetup, ntfs-3g, mount)
- Robust systemd handling with user verification
- Complete documentation (README.md, CHANGELOG.md)

### Security
- LUKS key file protected in `/root/dataencrypted.key`
- Strict permissions on scripts (root only)
- Device existence verification before mounting

---

## Release Notes

### Supported Configuration

**OptiPlex 7020** (Complete configuration)
- 3 LUKS encrypted volumes (data1, data2, data3)
- 2 unencrypted EXT4 volumes (pocrun, pocdoc)
- 1 FAT32 volume (IsoHirenBCD)
- 2 local NTFS volumes
- 3 external USB NTFS volumes (manhattan1, manhattan2, TOSHIBA)

**Swift SF514-51** (To be configured)
- Configuration to be defined by user

### System Requirements
- Linux with systemd
- cryptsetup (for LUKS volumes)
- ntfs-3g (for NTFS volumes)
- LUKS key file in `/root/dataencrypted.key`
- Root privileges for installation

---

[Unreleased]: https://github.com/bdelnoz/iptables/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/bdelnoz/iptables/releases/tag/v1.0.0
