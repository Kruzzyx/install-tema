#!/bin/bash
# Pterodactyl Multi-Theme Installer & Toolkit (fixed)

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

PANEL_DIR="/var/www/pterodactyl"
BACKUP_DIR="/var/www/pterodactyl_backup_$(date +%F_%H-%M)"
UA="Mozilla/5.0"

[ "$EUID" -ne 0 ] && { echo -e "${RED}Jalankan sebagai root (sudo su)${NC}"; exit 1; }

if [ ! -d "$PANEL_DIR" ]; then
    echo -e "${RED}[!] Pterodactyl tidak ditemukan di $PANEL_DIR${NC}"
    exit 1
fi

clear
echo -e "${BLUE}=================================================${NC}"
echo -e "${YELLOW}       PTERODACTYL MULTI-THEME TOOLKIT           ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo -e "${GREEN}[✓] Pterodactyl Panel terdeteksi.${NC}\n"
echo "1. Blueprint Framework"
echo "2. Reviactyl"
echo "3. NookTheme"
echo "4. Nightcore"
echo "5. Enola"
echo "6. Twilight"
echo "7. Stellar (manual upload /root/stellar.zip)"
echo "8. Recolor (Blueprint extension)"
echo "9. Restore Pterodactyl Original"
echo "0. Keluar"
read -rp "Pilih menu (0-9): " THEME_CHOICE

case "$THEME_CHOICE" in
    [1-9]) ;;
    0) exit 0 ;;
    *) echo -e "${RED}Pilihan tidak valid.${NC}"; exit 1 ;;
esac

# ---------- Fungsi ----------
backup_panel() {
    echo -e "${YELLOW}[+] Membuat backup panel...${NC}"
    mkdir -p "$BACKUP_DIR"
    rsync -a --exclude 'storage/logs' --exclude 'node_modules' --exclude '.git' "$PANEL_DIR/" "$BACKUP_DIR/" \
        || { echo -e "${RED}[!] Backup gagal, dibatalkan.${NC}"; exit 1; }
    echo -e "${GREEN}[✓] Backup: $BACKUP_DIR${NC}"
    echo -e "${YELLOW}[i] Database tidak ikut ter-backup. Backup manual: mysqldump -u root -p panel > panel.sql${NC}"
}

install_dependencies() {
    echo -e "${YELLOW}[+] Install dependencies...${NC}"
    apt-get update -y && apt-get install -y zip unzip curl wget tar rsync
}

install_build_tools() {
    echo -e "${YELLOW}[+] Cek NodeJS & Yarn...${NC}"
    unset NODE_OPTIONS
    NODE_MAJOR=0
    command -v node &>/dev/null && NODE_MAJOR=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -lt 20 ]; then
        echo -e "${YELLOW}[+] Install Node.js 20...${NC}"
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs \
            || { echo -e "${RED}[!] Gagal install Node.js${NC}"; exit 1; }
    fi
    command -v yarn &>/dev/null || npm i -g yarn
}

fix_permissions() {
    echo -e "${YELLOW}[+] Memperbaiki permission...${NC}"
    chown -R www-data:www-data "$PANEL_DIR"
    chmod -R 755 "$PANEL_DIR/storage" "$PANEL_DIR/bootstrap/cache"
}

# Install panel dari tar.gz (dipakai Reviactyl, NookTheme, Restore)
update_from_tar() {
    local url="$1"
    cd "$PANEL_DIR" || exit 1
    php artisan down
    if ! curl -fsSL -H "User-Agent: $UA" -o panel.tar.gz "$url"; then
        echo -e "${RED}[!] Download gagal: $url${NC}"
        php artisan up
        return 1
    fi
    tar -xzf panel.tar.gz && rm -f panel.tar.gz
    chmod -R 755 storage/* bootstrap/cache/
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    fix_permissions
    php artisan queue:restart
    php artisan up
}

# Jalankan script eksternal: download dulu, bukan pipe langsung ke bash
run_remote_script() {
    local url="$1" tmp
    tmp=$(mktemp)
    if curl -fsSL -H "User-Agent: $UA" -o "$tmp" "$url"; then
        bash "$tmp"
    else
        echo -e "${RED}[!] Gagal download script: $url${NC}"
    fi
    rm -f "$tmp"
}

# ---------- Eksekusi ----------
install_dependencies

case "$THEME_CHOICE" in
1)  # Blueprint
    backup_panel
    install_build_tools
    cd "$PANEL_DIR" || exit 1
    export PTERODACTYL_DIRECTORY="$PANEL_DIR"
    yarn install

    URL=$(curl -fsSL -H "User-Agent: $UA" https://api.github.com/repos/BlueprintFramework/framework/releases/latest \
        | grep -o '"browser_download_url": *"[^"]*release.zip"' | head -n 1 | cut -d '"' -f 4)
    [ -z "$URL" ] && { echo -e "${RED}[!] URL release Blueprint tidak ditemukan (mungkin rate limit GitHub).${NC}"; exit 1; }

    wget -O release.zip "$URL" || exit 1
    unzip -o release.zip && rm -f release.zip

    cat > "$PANEL_DIR/.blueprintrc" <<'EOF'
WEBUSER="www-data";
OWNERSHIP="www-data:www-data";
USERSHELL="/bin/bash";
EOF
    chmod +x blueprint.sh
    bash blueprint.sh
    fix_permissions
    echo -e "${GREEN}[✓] Blueprint selesai.${NC}"
    ;;
2)
    backup_panel
    update_from_tar "https://github.com/reviactyl/panel/releases/latest/download/panel.tar.gz" \
        && echo -e "${GREEN}[✓] Reviactyl terinstall.${NC}"
    ;;
3)
    backup_panel
    update_from_tar "https://github.com/Nookure/NookTheme/releases/latest/download/panel.tar.gz" \
        && echo -e "${GREEN}[✓] NookTheme terinstall.${NC}"
    ;;
4)
    backup_panel
    run_remote_script "https://raw.githubusercontent.com/NoPro200/Pterodactyl_Nightcore_Theme/main/install.sh"
    fix_permissions
    ;;
5|6)
    backup_panel
    install_build_tools
    NAME="Enola"; [ "$THEME_CHOICE" == "6" ] && NAME="Twilight"
    echo -e "${YELLOW}[!] Pilih '$NAME' di menu yang muncul.${NC}"
    run_remote_script "https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoThemes/main/install.sh"
    ;;
7)
    backup_panel
    echo -e "Upload ${GREEN}stellar.zip${NC} ke /root/ lalu tekan ENTER."
    read -r
    [ -f /root/stellar.zip ] || { echo -e "${RED}[!] /root/stellar.zip tidak ditemukan.${NC}"; exit 1; }
    cd "$PANEL_DIR" || exit 1
    php artisan down
    unzip -o /root/stellar.zip -d "$PANEL_DIR"
    chmod -R 755 storage/* bootstrap/cache/
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    fix_permissions
    php artisan queue:restart
    php artisan up
    echo -e "${GREEN}[✓] Stellar terinstall.${NC}"
    ;;
8)
    backup_panel
    cd "$PANEL_DIR" || exit 1
    [ -f blueprint.sh ] || { echo -e "${RED}[!] Install Blueprint dulu (menu 1).${NC}"; exit 1; }
    unset NODE_OPTIONS
    if [ ! -f /root/recolor.blueprint ]; then
        read -rp "Masukkan URL download recolor.blueprint (atau taruh file di /root/recolor.blueprint): " RURL
        [ -n "$RURL" ] && wget -O /root/recolor.blueprint "$RURL"
    fi
    [ -f /root/recolor.blueprint ] || { echo -e "${RED}[!] File recolor.blueprint tidak ada.${NC}"; exit 1; }
    cp /root/recolor.blueprint "$PANEL_DIR/recolor.blueprint"
    blueprint -i recolor && echo -e "${GREEN}[✓] Recolor terinstall.${NC}" \
        || echo -e "${RED}[!] Gagal install Recolor.${NC}"
    ;;
9)
    backup_panel
    update_from_tar "https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz" \
        && echo -e "${GREEN}[✓] Pterodactyl original direstore.${NC}"
    ;;
esac

echo -e "\n${BLUE}=================================================${NC}"
echo -e "${GREEN}      SELESAI — cek panel di browser            ${NC}"
echo -e "${BLUE}=================================================${NC}"
