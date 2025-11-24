# Changelog

Tous les changements notables de ce projet seront documentés dans ce fichier.

Le format est basé sur [Keep a Changelog](https://keepachangelog.com/fr/1.0.0/),
et ce projet adhère au [Semantic Versioning](https://semver.org/lang/fr/).

## [Non publié]

### À venir
- Configuration automatique pour Swift SF514-51
- Support de plusieurs profils de montage
- Interface de gestion graphique

---

## [1.0.0] - 2025-11-24

### Ajouté
- Script d'installation automatique `install_mounting.sh`
- Service systemd `mount-all-data.service` pour montage au démarrage
- Script principal `mount_all_data.sh` v7.1
- Détection automatique de la machine (OptiPlex 7020 / Swift SF514-51)
- Support montage LUKS chiffré avec fichier de clé
- Support montage NTFS via ntfs-3g
- Support montage FAT32
- Support montage EXT4 non chiffré
- Support montage swap LUKS chiffré
- Gestion automatique des permissions (nox:nox)
- Logging détaillé dans `/var/log/mount_all_data.sh.v7.1.log`
- Montage parallèle des volumes USB pour performance optimale
- Vérification des prérequis système (cryptsetup, ntfs-3g, mount)
- Gestion robuste pour systemd avec vérification utilisateur
- Documentation complète (README.md, CHANGELOG.md)

### Sécurité
- Fichier de clé LUKS protégé dans `/root/dataencrypted.key`
- Permissions strictes sur les scripts (root uniquement)
- Vérification de l'existence des périphériques avant montage

---

## Notes de version

### Configuration supportée

**OptiPlex 7020** (Configuration complète)
- 3 volumes LUKS chiffrés (data1, data2, data3)
- 2 volumes EXT4 non chiffrés (pocrun, pocdoc)
- 1 volume FAT32 (IsoHirenBCD)
- 2 volumes NTFS locaux
- 3 volumes NTFS USB externes (manhattan1, manhattan2, TOSHIBA)

**Swift SF514-51** (À configurer)
- Configuration à définir par l'utilisateur

### Prérequis système
- Linux avec systemd
- cryptsetup (pour volumes LUKS)
- ntfs-3g (pour volumes NTFS)
- Fichier de clé LUKS dans `/root/dataencrypted.key`
- Droits root pour l'installation

---

[Non publié]: https://github.com/bdelnoz/iptables/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/bdelnoz/iptables/releases/tag/v1.0.0
