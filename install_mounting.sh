#!/bin/bash
# Auteur : Bruno DELNOZ
# Email : bruno.delnoz@protonmail.com
# Nom du script : install_mounting.sh
# Target usage : Installation du service de montage automatique
# Version : v1.0 – Date : 2025-11-24
# Changelog :
# - v1.0 (2025-11-24) : Création initiale

set -e

# Vérification root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Ce script doit être exécuté en tant que root"
    exit 1
fi

echo "🔧 Installation du service de montage automatique..."
echo ""

# Copie du script
echo "[1/3] Copie du script principal..."
cp -f mount_all_data.sh /usr/local/sbin/mount_all_data.sh
chmod +x /usr/local/sbin/mount_all_data.sh
echo "✅ Script installé"

# Copie du service
echo "[2/3] Installation du service systemd..."
cp -f mount-all-data.service /etc/systemd/system/mount-all-data.service
chmod 644 /etc/systemd/system/mount-all-data.service
systemctl daemon-reload
echo "✅ Service installé"

# Activation
echo "[3/3] Activation du service..."
systemctl enable mount-all-data.service
systemctl restart mount-all-data.service
echo "✅ Service activé"

echo ""
echo "🎉 Installation terminée !"
echo ""
systemctl status mount-all-data.service --no-pager

exit 0
