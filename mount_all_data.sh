#!/bin/bash
# SCRIPT OFFICIEL RESPECTANT : CONTEXTUALISATION V105
# Auteur : Bruno DELNOZ
# Email : bruno.delnoz@protonmail.com
# Nom du script : /usr/local/sbin/mount_all_data.sh
# Target usage : Monter automatiquement tous les volumes LUKS et NTFS au boot selon la machine détectée (OptiPlex 7020 ou Swift SF514-51)
# Version : v7.1 – Date : 2025-10-21
# Changelog :
# v7.0 – Ajout détection automatique machine via product_name
# v7.1 – CORRECTION CRITIQUE : Vérification owner avant chown (évite opération inutile)
#      – Chown uniquement points de montage (pas récursif dans le contenu)
#      – Gestion robuste pour systemd : vérification existence user nox avant chown

# -------------------------------
# Pré-requis
# -------------------------------
for cmd in cryptsetup mount.ntfs-3g mount; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "$cmd manquant, installez-le via apt install $cmd"
        exit 1
    fi
done

KEYFILE="/root/dataencrypted.key"
if [ ! -f "$KEYFILE" ]; then
    echo "Fichier clé $KEYFILE introuvable !"
    exit 1
fi

LOG_FILE="/var/log/mount_all_data.sh.v7.1.log"
echo "=== Execution du script mount_all_data.sh v7.1 === $(date)" >> "$LOG_FILE"

# -------------------------------
# DÉTECTION DE LA MACHINE
# -------------------------------
PRODUCT_NAME=$(cat /sys/class/dmi/id/product_name 2>/dev/null)

if [ -z "$PRODUCT_NAME" ]; then
    echo "ERREUR: Impossible de détecter le modèle de machine" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Machine détectée: $PRODUCT_NAME" | tee -a "$LOG_FILE"

# -------------------------------
# Fonction de montage LUKS
# -------------------------------
mount_luks() {
    local DEV="$1"
    local NAME="$2"
    local MOUNTPOINT="$3"
    echo "Ouverture LUKS $DEV -> /dev/mapper/$NAME" >> "$LOG_FILE"
    if ! cryptsetup status "$NAME" &>/dev/null; then
        cryptsetup open "$DEV" "$NAME" --key-file "$KEYFILE" || { echo "Erreur cryptsetup $DEV" >> "$LOG_FILE"; exit 1; }
    else
        echo "Le périphérique $NAME est déjà ouvert" >> "$LOG_FILE"
    fi
    mkdir -p "$MOUNTPOINT"
    if ! mountpoint -q "$MOUNTPOINT"; then
        mount /dev/mapper/"$NAME" "$MOUNTPOINT" || { echo "Erreur mount $MOUNTPOINT" >> "$LOG_FILE"; exit 1; }
        echo "$MOUNTPOINT monté" >> "$LOG_FILE"
    else
        echo "$MOUNTPOINT déjà monté" >> "$LOG_FILE"
    fi
}


# -------------------------------
# Fonction de montage Swap LUKS
# -------------------------------
mount_swap_luks() {
    local DEV="$1"
    local NAME="$2"
    echo "Ouverture LUKS swap $DEV -> /dev/mapper/$NAME" >> "$LOG_FILE"
    if ! cryptsetup status "$NAME" &>/dev/null; then
        cryptsetup open "$DEV" "$NAME" --key-file "$KEYFILE" || { echo "Erreur cryptsetup $DEV" >> "$LOG_FILE"; exit 1; }
        sleep 5
    else
        echo "Le périphérique swap $NAME est déjà ouvert" >> "$LOG_FILE"
    fi
    if ! swapon --show=NAME | grep -q "^/dev/mapper/$NAME$"; then
        mkswap /dev/mapper/"$NAME" &>/dev/null || true
        sleep 3
        swapon /dev/mapper/"$NAME" || { echo "Erreur activation swap $NAME" >> "$LOG_FILE"; exit 1; }
        echo "Swap /dev/mapper/$NAME activé" >> "$LOG_FILE"
    else
        echo "Swap /dev/mapper/$NAME déjà actif" >> "$LOG_FILE"
    fi
}



# -------------------------------
# Fonction de montage NTFS
# -------------------------------
mount_ntfs() {
    local DEV="$1"
    local MOUNTPOINT="$2"
    mkdir -p "$MOUNTPOINT"
    if ! mountpoint -q "$MOUNTPOINT"; then
        mount -t ntfs-3g "$DEV" "$MOUNTPOINT" -o rw,uid=1000,gid=1000,allow_other,nonempty || { echo "Erreur mount NTFS $DEV" >> "$LOG_FILE"; exit 1; }
        echo "$MOUNTPOINT monté (NTFS)" >> "$LOG_FILE"
    else
        echo "$MOUNTPOINT déjà monté (NTFS)" >> "$LOG_FILE"
    fi
}

# -------------------------------
# Fonction de montage FAT32 IsoHirenBCD
# -------------------------------
mount_fat32() {
    local DEV="$1"
    local MOUNTPOINT="$2"
    mkdir -p "$MOUNTPOINT"
    if ! mountpoint -q "$MOUNTPOINT"; then
        mount -t vfat "$DEV" "$MOUNTPOINT" -o rw,uid=1000,gid=1000 || { echo "Erreur mount FAT32 $DEV" >> "$LOG_FILE"; exit 1; }
        echo "$MOUNTPOINT monté (FAT32)" >> "$LOG_FILE"
    else
        echo "$MOUNTPOINT déjà monté (FAT32)" >> "$LOG_FILE"
    fi
}

# -------------------------------
# Fonction de montage EXT4 (non chiffré)
# -------------------------------
mount_ext4() {
    local DEV="$1"
    local MOUNTPOINT="$2"
    mkdir -p "$MOUNTPOINT"
    if ! mountpoint -q "$MOUNTPOINT"; then
        mount -t ext4 "$DEV" "$MOUNTPOINT" -o rw,relatime || { echo "Erreur mount EXT4 $DEV" >> "$LOG_FILE"; exit 1; }
        echo "$MOUNTPOINT monté (EXT4)" >> "$LOG_FILE"
    else
        echo "$MOUNTPOINT déjà monté (EXT4)" >> "$LOG_FILE"
    fi
}

# -------------------------------
# Fonction de vérification et correction des permissions
# -------------------------------
fix_permissions() {
    echo "Vérification des permissions sur les points de montage" >> "$LOG_FILE"

    # Vérifier que l'utilisateur nox existe (important pour systemd au boot)
    if ! id nox &>/dev/null; then
        echo "⚠️  AVERTISSEMENT : Utilisateur 'nox' introuvable, permissions non modifiées" >> "$LOG_FILE"
        echo "   (Normal si script exécuté avant création utilisateur au boot)" >> "$LOG_FILE"
        return 0
    fi

    # Récupérer UID/GID de nox pour comparaison robuste
    local NOX_UID=$(id -u nox)
    local NOX_GID=$(id -g nox)

    # Vérifier et corriger /mnt
    if [ -d /mnt ]; then
        local mnt_uid=$(stat -c '%u' /mnt 2>/dev/null)
        local mnt_gid=$(stat -c '%g' /mnt 2>/dev/null)

        if [ "$mnt_uid" != "$NOX_UID" ] || [ "$mnt_gid" != "$NOX_GID" ]; then
            echo "  - /mnt : uid=$mnt_uid gid=$mnt_gid → changement vers nox:nox ($NOX_UID:$NOX_GID)" >> "$LOG_FILE"
            chown nox:nox /mnt || echo "    ⚠️  Erreur chown /mnt" >> "$LOG_FILE"
        else
            echo "  - /mnt : déjà nox:nox (OK)" >> "$LOG_FILE"
        fi
    fi

    # Vérifier chaque point de montage
    for mountpoint in /mnt/*/; do
        if [ -d "$mountpoint" ]; then
            local dir_uid=$(stat -c '%u' "$mountpoint" 2>/dev/null)
            local dir_gid=$(stat -c '%g' "$mountpoint" 2>/dev/null)

            if [ "$dir_uid" != "$NOX_UID" ] || [ "$dir_gid" != "$NOX_GID" ]; then
                echo "  - $mountpoint : uid=$dir_uid gid=$dir_gid → changement vers nox:nox ($NOX_UID:$NOX_GID)" >> "$LOG_FILE"
                chown nox:nox "$mountpoint" || echo "    ⚠️  Erreur chown $mountpoint" >> "$LOG_FILE"
            else
                echo "  - $mountpoint : déjà nox:nox (OK)" >> "$LOG_FILE"
            fi
        fi
    done

    echo "Vérification des permissions terminée" >> "$LOG_FILE"
}

# ═══════════════════════════════════════════════════════════════════════════════
# CHOIX DE LA CONFIGURATION SELON LA MACHINE DÉTECTÉE
# ═══════════════════════════════════════════════════════════════════════════════

case "$PRODUCT_NAME" in
    "OptiPlex 7020")
        # ═══════════════════════════════════════════════════════════════════════
        # CONFIGURATION OPTIPLEX 7020 (DESKTOP PRINCIPAL)
        # ═══════════════════════════════════════════════════════════════════════
        echo "Configuration OptiPlex 7020 appliquée" | tee -a "$LOG_FILE"

        # -------------------------------
        # Montage LUKS (séquentiel)
        # -------------------------------
        mount_luks UUID=9a7ae28a-210c-41fc-808c-ee4872a0431c data1 /mnt/data1_100g
#         mount_luks PARTUUID=07bd92bf-bacb-4491-bcd7-64182242690b data1 /mnt/data1_100g
        mount_luks UUID=7708048b-70ab-4455-aba4-c114ea645c60 data2 /mnt/data2_78g
        mount_luks UUID=b58ce769-e15b-4611-8ae5-9cf8edfcf626 data3 /mnt/data3_81g
#         mount_luks UUID=87b00aeb-3e78-4247-a560-cc0c3b53b5ab crypt_xfs /mnt/xfs
#         mount_luks UUID=74594146-82b2-4494-b3e0-b2439aac36a4 data_1g /mnt/data_1g


        # -------------------------------
        # Montage SWAP LUKS
        # -------------------------------
#         mount_swap_luks UUID=8345abbc-c3dc-49bc-9d0d-90378cd064e8  swap_crypt

        # ------------------------------------
        # Montage EXT4 non chiffrés local
        # ------------------------------------
        mount_ext4 UUID=d2dceadc-9690-45d0-b8cc-e25a96844552 /mnt/pocrun_72g
        mount_ext4 UUID=5e30318d-4698-904f-a0d3-75b4cfe4e6da /mnt/pocdoc_1g
        # -------------------------------------
        # Montage NTFS/FAT32 (parallèle) local
        # -------------------------------------
        mount_fat32 UUID=9EA7-7F8F /mnt/IsoHirenBCD &
        mount_ntfs UUID=1845197741D37E74 /mnt/local_266g
#         mount_ntfs /dev/sdb2 /mnt/local_78g

        # -------------------------------------
        # Montage NTFS/FAT32 (parallèle) USB
        # -------------------------------------

        mount_ntfs UUID=7569251B65AC5AE3 /mnt/manhattan1/ &
        mount_ntfs UUID=092198C054A3DAFF /mnt/manhattan2/ &
#           mount_ntfs /dev/sda1 /mnt/ &
#         mount_ntfs /dev/sdb3 /mnt/wd_3_2t/ &
#         mount_ntfs /dev/sdb2 /mnt/wd_2_2t/ &
#         mount_ntfs /dev/sdb1 /mnt/wd_1_2t/ &
        mount_ntfs UUID=9A48A03248A00F57 /mnt/TOSHIBA/ &

        # Attendre la fin de tous les montages parallèles
        wait

        # -------------------------------
        # Vérification et correction des permissions
        # -------------------------------
        fix_permissions

        echo "=== Fin du montage OptiPlex 7020 ===" >> "$LOG_FILE"
        ;;

    "Swift SF514-51")
        # ═══════════════════════════════════════════════════════════════════════
        # CONFIGURATION SWIFT SF514-51 (PORTABLE)
        # ═══════════════════════════════════════════════════════════════════════
        echo "Configuration Swift SF514-51 appliquée" | tee -a "$LOG_FILE"

        echo "⚠️  Configuration Swift non définie - À compléter manuellement" | tee -a "$LOG_FILE"
        echo "   Éditez ce script et complétez la section Swift SF514-51" | tee -a "$LOG_FILE"

        echo "=== Fin du montage Swift SF514-51 (vide) ===" >> "$LOG_FILE"
        ;;

    *)
        # ═══════════════════════════════════════════════════════════════════════
        # MACHINE INCONNUE - UTILISATION CONFIG PAR DÉFAUT (OPTIPLEX)
        # ═══════════════════════════════════════════════════════════════════════
        echo "⚠️  Machine inconnue: $PRODUCT_NAME" | tee -a "$LOG_FILE"
        echo "   Utilisation configuration par défaut (OptiPlex 7020)" | tee -a "$LOG_FILE"

        # -------------------------------
        # Montage LUKS (séquentiel)
        # -------------------------------
        mount_luks /dev/sda6 data1 /mnt/data1_100g
        mount_luks /dev/sda10 data2 /mnt/data2_78g
        mount_luks /dev/sda9 data3 /mnt/data3_81g

        # -------------------------------
        # Montage EXT4 non chiffrés
        # -------------------------------
        mount_ext4 /dev/sda12 /mnt/pocrun_72g
        mount_ext4 /dev/sda11 /mnt/pocdoc_1g

        # -------------------------------
        # Montage NTFS/FAT32 (parallèle)
        # -------------------------------
        mount_fat32 /dev/sda8 /mnt/IsoHirenBCD &

        # Attendre la fin de tous les montages parallèles
        wait

        # -------------------------------
        # Vérification et correction des permissions
        # -------------------------------
        fix_permissions

        echo "=== Fin du montage (config par défaut) ===" >> "$LOG_FILE"
        ;;
esac

echo "Sortie conforme aux règles de contextualisation V105." >> "$LOG_FILE"
