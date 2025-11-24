# Montage Automatique de Volumes LUKS/NTFS/FAT32

Service systemd pour le montage automatique de volumes chiffrés (LUKS) et non chiffrés (NTFS, FAT32, EXT4) au démarrage du système.

## 📋 Caractéristiques

- **Montage automatique au boot** via service systemd
- **Support multi-formats** : LUKS, NTFS, FAT32, EXT4, Swap chiffré
- **Détection automatique de machine** (OptiPlex 7020 / Swift SF514-51)
- **Montage parallèle** des volumes USB pour performance optimale
- **Gestion automatique des permissions** (nox:nox)
- **Logging détaillé** de toutes les opérations
- **Installation en une commande**

## 🚀 Installation Rapide

```bash
# Cloner le dépôt
git clone https://github.com/bdelnoz/mount-all-data.git
cd mount-all-data

# Exécuter l'installation (nécessite root)
sudo ./install_mounting.sh
```

Le script d'installation va :
1. Copier le script principal vers `/usr/local/sbin/`
2. Installer le service systemd
3. Activer et démarrer le service automatiquement

## 📦 Prérequis

### Paquets requis
```bash
sudo apt install cryptsetup ntfs-3g
```

### Fichier de clé LUKS
Vous devez avoir un fichier de clé pour déverrouiller les volumes LUKS :
```bash
# Le fichier doit être présent à cet emplacement
/root/dataencrypted.key
```

### Permissions
- L'installation nécessite les droits **root**
- Les scripts doivent être exécutables

## 🔧 Configuration

### Machines supportées

Le script détecte automatiquement votre machine via `/sys/class/dmi/id/product_name` :

#### **OptiPlex 7020** (Configuration complète)
- 3 volumes LUKS : `data1_100g`, `data2_78g`, `data3_81g`
- 2 volumes EXT4 : `pocrun_72g`, `pocdoc_1g`
- 1 volume FAT32 : `IsoHirenBCD`
- Volumes NTFS locaux et USB

#### **Swift SF514-51** (À configurer)
Section à compléter manuellement dans `mount_all_data.sh`

### Personnalisation

Pour modifier la configuration de montage :

1. Éditez le script principal :
```bash
sudo nano /usr/local/sbin/mount_all_data.sh
```

2. Modifiez la section correspondant à votre machine dans le `case` statement

3. Rechargez le service :
```bash
sudo systemctl daemon-reload
sudo systemctl restart mount-all-data.service
```

## 📊 Utilisation

### Commandes du service

```bash
# Vérifier le statut
sudo systemctl status mount-all-data.service

# Redémarrer le service
sudo systemctl restart mount-all-data.service

# Arrêter le service
sudo systemctl stop mount-all-data.service

# Désactiver au démarrage
sudo systemctl disable mount-all-data.service

# Réactiver au démarrage
sudo systemctl enable mount-all-data.service
```

### Logs

```bash
# Logs systemd
journalctl -u mount-all-data.service -f

# Log du script
sudo tail -f /var/log/mount_all_data.sh.v7.1.log

# Voir tous les points de montage
df -h | grep /mnt
```

## 🗂️ Structure du projet

```
.
├── install_mounting.sh          # Script d'installation
├── mount_all_data.sh           # Script principal de montage
├── mount-all-data.service      # Service systemd
├── README.md                   # Documentation (FR)
├── README_en.md               # Documentation (EN)
├── CHANGELOG.md               # Journal des modifications (FR)
├── CHANGELOG_en.md           # Changelog (EN)
└── .gitignore                # Fichiers ignorés par Git
```

## 🔐 Sécurité

- **Fichier de clé LUKS** : Protégé dans `/root/` (accessible uniquement par root)
- **Permissions scripts** : 700 (root uniquement)
- **Service systemd** : Exécuté avec privilèges root
- **Vérifications** : Existence des périphériques avant montage

## 🐛 Dépannage

### Le service ne démarre pas

```bash
# Vérifier les logs détaillés
sudo journalctl -u mount-all-data.service -n 100

# Vérifier le log du script
sudo cat /var/log/mount_all_data.sh.v7.1.log

# Tester le script manuellement
sudo /usr/local/sbin/mount_all_data.sh
```

### Volumes non montés

```bash
# Vérifier que les UUID existent
sudo blkid

# Vérifier que cryptsetup fonctionne
sudo cryptsetup status data1

# Vérifier les points de montage
mount | grep /mnt
```

### Fichier de clé manquant

```bash
# Vérifier la présence du fichier
ls -l /root/dataencrypted.key

# Si absent, le service échouera au démarrage
```

## 📝 Versions

Voir [CHANGELOG.md](CHANGELOG.md) pour l'historique complet des versions.

**Version actuelle** : 1.0.0

## 👤 Auteur

**Bruno DELNOZ**
- Email : bruno.delnoz@protonmail.com
- GitHub : [@bdelnoz](https://github.com/bdelnoz)

## 📄 Licence

Ce projet suit les règles de contextualisation V105.

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
- Ouvrir une issue pour signaler un bug
- Proposer des améliorations
- Soumettre une pull request

## 🔗 Liens utiles

- [Documentation systemd](https://www.freedesktop.org/software/systemd/man/)
- [LUKS/cryptsetup](https://gitlab.com/cryptsetup/cryptsetup)
- [NTFS-3G](https://www.tuxera.com/community/open-source-ntfs-3g/)

---

**Note** : Ce script est conçu pour un usage personnel et nécessite une adaptation selon votre configuration matérielle spécifique.
