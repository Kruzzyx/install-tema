#!/bin/bash
# Pterodactyl Theme Uninstaller / Restore Toolkit

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

PANEL_DIR="/var/www/pterodactyl"
SNAPSHOT_DIR="/var/www/pterodactyl_pre_uninstall_$(date +%F_%H-%M)"
UA="Mozilla/5.0"

[ "$EUID" -ne 0 ] && { echo -e "${RED}Jalankan sebagai root (sudo su)${NC}"; exit 1; }
[ -d "$PANEL_DIR" ] || { echo -e "${RED}[!] Panel tidak ditemukan di $PANEL_DIR${NC}"; exit 1; }

ask_yes() { read -rp "$1 (y/N): " A </dev/tty; [[ "$A" =~ ^[Yy]$ ]]; }

snapshot_panel() {
    echo -e "${YELLOW}[+] Snapshot kondisi sekarang (jaga-jaga)...${NC}"
    mkdir -p "$SNAPSHOT_DIR"
    rsync -a --exclude 'storage/logs' --exclude 'node_modules' --exclude '.git' "$PANEL_DIR/" "$SNAPSHOT_DIR/" \
        || { echo -e "${RED}[!] Snapshot gagal, dibatalkan.${NC}"; exit 1; }
    echo -e "${GREEN}[✓] Snapshot: $SNAPSHOT_DIR${NC}"
}

fix_permissions() {
    chown -R www-data:www-data "$PANEL_DIR"
    chmod -R 755 "$PANEL_DIR/storage" "$PANEL_DIR/bootstrap/cache"
}

finalize() {
    cd "$PANEL_DIR" || exit 1
    chmod -R 755 storage/* bootstrap/cache/
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader
    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    fix_permissions
    php artisan queue:restart
    php artisan up
}

echo -e "${BLUE}=================================================${NC}"
echo -e "${YELLOW}        PTERODACTYL THEME UNINSTALLER            ${NC}"
echo -e "${BLUE}=================================================${NC}"
echo "1. Restore dari backup (paling aman)"
echo "2. Hapus ekstensi Blueprint (mis. recolor)"
echo "3. Hapus Blueprint Framework sepenuhnya"
echo "4. Kembali ke Pterodactyl original (download ulang)"
echo "0. Keluar"
read -rp "Pilih menu (0-4): " CHOICE </dev/tty

case "$CHOICE" in
1)
    mapfile -t BACKUPS < <(ls -d /var/www/pterodactyl_backup_* 2>/dev/null | sort -r)
    [ ${#BACKUPS[@]} -eq 0 ] && { echo -e "${RED}[!] Tidak ada backup (/var/www/pterodactyl_backup_*).${NC}"; exit 1; }
    echo -e "\nBackup tersedia:"
    for i in "${!BACKUPS[@]}"; do echo "$((i+1)). ${BACKUPS[$i]}"; done
    read -rp "Pilih nomor backup: " N </dev/tty
    [[ "$N" =~ ^[0-9]+$ ]] && [ "$N" -ge 1 ] && [ "$N" -le ${#BACKUPS[@]} ] \
        || { echo -e "${RED}Pilihan tidak valid.${NC}"; exit 1; }
    SRC="${BACKUPS[$((N-1))]}"
    echo -e "${YELLOW}[!] File panel akan ditimpa dengan isi $SRC.${NC}"
    echo -e "${YELLOW}    storage/ dan .env tidak diubah. Database tidak di-restore.${NC}"
    ask_yes "Lanjut?" || exit 0
    snapshot_panel
    cd "$PANEL_DIR" || exit 1
    php artisan down
    rsync -a --delete --exclude 'storage' --exclude '.env' --exclude 'node_modules' --exclude '.git' "$SRC/" "$PANEL_DIR/"
    finalize
    echo -e "${GREEN}[✓] Restore dari backup selesai.${NC}"
    ;;
2)
    [ -f "$PANEL_DIR/blueprint.sh" ] || { echo -e "${RED}[!] Blueprint tidak terinstall.${NC}"; exit 1; }
    command -v blueprint &>/dev/null || { echo -e "${RED}[!] Command 'blueprint' tidak ada.${NC}"; exit 1; }
    cd "$PANEL_DIR" || exit 1
    echo -e "Ekstensi terinstall:"
    blueprint -info 2>/dev/null | head -n 5
    ls "$PANEL_DIR/.blueprint/extensions" 2>/dev/null
    read -rp "Masukkan ID ekstensi yang dihapus (mis. recolor): " EXT </dev/tty
    [[ "$EXT" =~ ^[a-z0-9_-]+$ ]] || { echo -e "${RED}ID tidak valid.${NC}"; exit 1; }
    unset NODE_OPTIONS
    snapshot_panel
    blueprint -remove "$EXT" && echo -e "${GREEN}[✓] $EXT dihapus.${NC}" \
        || echo -e "${RED}[!] Gagal menghapus $EXT.${NC}"
    fix_permissions
    ;;
3)
    echo -e "${YELLOW}[!] Ini menghapus Blueprint dan semua ekstensinya, lalu mengembalikan panel ke original.${NC}"
    ask_yes "Lanjut?" || exit 0
    snapshot_panel
    cd "$PANEL_DIR" || exit 1
    unset NODE_OPTIONS
    # Hapus ekstensi dulu supaya bersih
    if command -v blueprint &>/dev/null && [ -d "$PANEL_DIR/.blueprint/extensions" ]; then
        for E in $(ls "$PANEL_DIR/.blueprint/extensions" 2>/dev/null); do
            echo -e "${YELLOW}[+] Menghapus ekstensi: $E${NC}"
            blueprint -remove "$E" || true
        done
    fi
    php artisan down
    curl -fsSL -H "User-Agent: $UA" -o panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz \
        || { echo -e "${RED}[!] Download gagal.${NC}"; php artisan up; exit 1; }
    tar -xzf panel.tar.gz && rm -f panel.tar.gz
    rm -rf "$PANEL_DIR/.blueprint" "$PANEL_DIR/blueprint.sh" "$PANEL_DIR/.blueprintrc"
    rm -f /usr/local/bin/blueprint
    finalize
    echo -e "${GREEN}[✓] Blueprint dihapus, panel kembali ke original.${NC}"
    ;;
4)
    echo -e "${YELLOW}[!] Panel akan ditimpa dengan Pterodactyl original terbaru.${NC}"
    echo -e "${YELLOW}    Jika sebelumnya memakai Reviactyl, skema database bisa tidak cocok.${NC}"
    echo -e "${YELLOW}    Lebih aman restore backup (menu 1) bersama dump database.${NC}"
    ask_yes "Tetap lanjut?" || exit 0
    snapshot_panel
    cd "$PANEL_DIR" || exit 1
    php artisan down
    curl -fsSL -H "User-Agent: $UA" -o panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz \
        || { echo -e "${RED}[!] Download gagal.${NC}"; php artisan up; exit 1; }
    tar -xzf panel.tar.gz && rm -f panel.tar.gz
    finalize
    echo -e "${GREEN}[✓] Pterodactyl original dipulihkan.${NC}"
    ;;
0) exit 0 ;;
*) echo -e "${RED}Pilihan tidak valid.${NC}"; exit 1 ;;
esac

echo -e "\n${GREEN}SELESAI — hard refresh browser (Ctrl+Shift+R) untuk lihat hasilnya.${NC}"
