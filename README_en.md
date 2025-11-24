# Automatic LUKS/NTFS/FAT32 Volume Mounting

Systemd service for automatic mounting of encrypted (LUKS) and unencrypted (NTFS, FAT32, EXT4) volumes at system boot.

## 📋 Features

- **Automatic mounting at boot** via systemd service
- **Multi-format support**: LUKS, NTFS, FAT32, EXT4, Encrypted Swap
- **Automatic machine detection** (OptiPlex 7020 / Swift SF514-51)
- **Parallel USB volume mounting** for optimal performance
- **Automatic permission management** (nox:nox)
- **Detailed logging** of all operations
- **One-command installation**

## 🚀 Quick Installation

```bash
# Clone the repository
git clone https://github.com/bdelnoz/mount-all-data.git
cd mount-all-data

# Run installation (requires root)
sudo ./install_mounting.sh
```

The installation script will:
1. Copy the main script to `/usr/local/sbin/`
2. Install the systemd service
3. Enable and start the service automatically

## 📦 Prerequisites

### Required packages
```bash
sudo apt install cryptsetup ntfs-3g
```

### LUKS key file
You must have a key file to unlock LUKS volumes:
```bash
# The file must be present at this location
/root/dataencrypted.key
```

### Permissions
- Installation requires **root** privileges
- Scripts must be executable

## 🔧 Configuration

### Supported machines

The script automatically detects your machine via `/sys/class/dmi/id/product_name`:

#### **OptiPlex 7020** (Complete configuration)
- 3 LUKS volumes: `data1_100g`, `data2_78g`, `data3_81g`
- 2 EXT4 volumes: `pocrun_72g`, `pocdoc_1g`
- 1 FAT32 volume: `IsoHirenBCD`
- Local and USB NTFS volumes

#### **Swift SF514-51** (To be configured)
Section to be completed manually in `mount_all_data.sh`

### Customization

To modify the mounting configuration:

1. Edit the main script:
```bash
sudo nano /usr/local/sbin/mount_all_data.sh
```

2. Modify the section corresponding to your machine in the `case` statement

3. Reload the service:
```bash
sudo systemctl daemon-reload
sudo systemctl restart mount-all-data.service
```

## 📊 Usage

### Service commands

```bash
# Check status
sudo systemctl status mount-all-data.service

# Restart service
sudo systemctl restart mount-all-data.service

# Stop service
sudo systemctl stop mount-all-data.service

# Disable at boot
sudo systemctl disable mount-all-data.service

# Re-enable at boot
sudo systemctl enable mount-all-data.service
```

### Logs

```bash
# Systemd logs
journalctl -u mount-all-data.service -f

# Script log
sudo tail -f /var/log/mount_all_data.sh.v7.1.log

# View all mount points
df -h | grep /mnt
```

## 🗂️ Project Structure

```
.
├── install_mounting.sh          # Installation script
├── mount_all_data.sh           # Main mounting script
├── mount-all-data.service      # Systemd service
├── README.md                   # Documentation (FR)
├── README_en.md               # Documentation (EN)
├── CHANGELOG.md               # Changelog (FR)
├── CHANGELOG_en.md           # Changelog (EN)
└── .gitignore                # Git ignored files
```

## 🔐 Security

- **LUKS key file**: Protected in `/root/` (accessible only by root)
- **Script permissions**: 700 (root only)
- **Systemd service**: Executed with root privileges
- **Verifications**: Device existence checked before mounting

## 🐛 Troubleshooting

### Service won't start

```bash
# Check detailed logs
sudo journalctl -u mount-all-data.service -n 100

# Check script log
sudo cat /var/log/mount_all_data.sh.v7.1.log

# Test script manually
sudo /usr/local/sbin/mount_all_data.sh
```

### Volumes not mounted

```bash
# Verify UUIDs exist
sudo blkid

# Verify cryptsetup works
sudo cryptsetup status data1

# Check mount points
mount | grep /mnt
```

### Missing key file

```bash
# Verify file presence
ls -l /root/dataencrypted.key

# If missing, service will fail at startup
```

## 📝 Versions

See [CHANGELOG_en.md](CHANGELOG_en.md) for complete version history.

**Current version**: 1.0.0

## 👤 Author

**Bruno DELNOZ**
- Email: bruno.delnoz@protonmail.com
- GitHub: [@bdelnoz](https://github.com/bdelnoz)

## 📄 License

This project follows contextualization rules V105.

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Open an issue to report a bug
- Propose improvements
- Submit a pull request

## 🔗 Useful Links

- [systemd documentation](https://www.freedesktop.org/software/systemd/man/)
- [LUKS/cryptsetup](https://gitlab.com/cryptsetup/cryptsetup)
- [NTFS-3G](https://www.tuxera.com/community/open-source-ntfs-3g/)

---

**Note**: This script is designed for personal use and requires adaptation according to your specific hardware configuration.
