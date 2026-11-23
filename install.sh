#!/bin/bash
# Neumorphism Theme Installer (Blueprint extension)
# Pakai:  bash install.sh            -> install (auto-install Blueprint & deps dengan konfirmasi)
#         bash install.sh --remove   -> uninstall

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PANEL_DIR="${PANEL_DIR:-/var/www/pterodactyl}"
EXT_ID="neumorphism"

prompt_yn() {
    local msg="$1"
    local ans=""
    if [ -r /dev/tty ]; then
        read -rp "$msg" ans </dev/tty
    else
        read -rp "$msg" ans
    fi
    case "$ans" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Jalankan sebagai root (sudo su)${NC}"
    exit 1
fi

if [ ! -d "$PANEL_DIR" ]; then
    echo -e "${RED}[!] Panel tidak ditemukan di $PANEL_DIR${NC}"
    exit 1
fi

# Bersihkan --openssl-legacy-provider dari NODE_OPTIONS agar tidak error di Node modern
if [[ "${NODE_OPTIONS:-}" == *"--openssl-legacy-provider"* ]]; then
    export NODE_OPTIONS="${NODE_OPTIONS//--openssl-legacy-provider/}"
    export NODE_OPTIONS="$(echo "$NODE_OPTIONS" | xargs)"
    if [ -z "$NODE_OPTIONS" ]; then
        unset NODE_OPTIONS
    fi
fi

if ! cd "$PANEL_DIR"; then
    echo -e "${RED}[!] Gagal masuk ke direktori $PANEL_DIR${NC}"
    exit 1
fi

if [ "$1" == "--remove" ]; then
    if ! command -v blueprint >/dev/null 2>&1; then
        echo -e "${RED}[!] Blueprint tidak ditemukan, ekstensi tidak bisa dihapus lewat Blueprint.${NC}"
        exit 1
    fi
    if prompt_yn "Yakin ingin menghapus tema Neumorphism? [y/N]: "; then
        if blueprint -remove "$EXT_ID"; then
            echo -e "${GREEN}[✓] Neumorphism dihapus.${NC}"
        else
            echo -e "${RED}[!] Gagal menghapus.${NC}"
        fi
    else
        echo -e "${YELLOW}Penghapusan dibatalkan.${NC}"
    fi
    exit 0
fi

install_node_22_and_yarn() {
    echo -e "${YELLOW}[+] Mempersiapkan Node.js v22.x & Yarn...${NC}"
    apt-get update -y && apt-get install -y curl ca-certificates gnupg || return 1
    rm -f /etc/apt/sources.list.d/nodesource* /etc/apt/keyrings/nodesource*
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - || return 1
    apt-get install -y --allow-downgrades nodejs || return 1

    if ! command -v yarn >/dev/null 2>&1; then
        npm install -g yarn || return 1
    fi

    hash -r
    echo -e "${GREEN}[✓] Node versi aktif: $(node -v 2>/dev/null)${NC}"
    return 0
}

ensure_node_22() {
    local cur_major
    cur_major=$(node -v 2>/dev/null | sed -E 's/^v([0-9]+).*/\1/')

    if [ -z "$cur_major" ] || [ "$cur_major" -lt 22 ]; then
        echo -e "${RED}[!] Node.js saat ini: $(node -v 2>/dev/null || echo 'belum terinstall'). Blueprint membutuhkan Node.js v22.x+.${NC}"
        if prompt_yn "Install/upgrade Node.js ke v22.x dan pastikan Yarn terinstall sekarang? [y/N]: "; then
            install_node_22_and_yarn || return 1
        else
            echo -e "${YELLOW}Instalasi dibatalkan karena Node.js belum memenuhi syarat (>= v22.x).${NC}"
            return 1
        fi
    else
        if ! command -v yarn >/dev/null 2>&1; then
            if prompt_yn "Yarn belum terinstall. Install Yarn global via npm sekarang? [y/N]: "; then
                npm install -g yarn || return 1
            else
                echo -e "${RED}[!] Yarn dibutuhkan oleh Blueprint.${NC}"
                return 1
            fi
        fi
    fi
    return 0
}

install_blueprint_auto() {
    echo -e "${YELLOW}[+] Mempersiapkan instalasi Blueprint...${NC}"
    apt-get update -y && apt-get install -y curl unzip git gnupg ca-certificates || return 1

    ensure_node_22 || return 1

    echo -e "${YELLOW}[+] Mengambil informasi rilis terbaru Blueprint...${NC}"
    LATEST_URL=$(curl -fsSL https://api.github.com/repos/BlueprintFramework/framework/releases/latest \
        | grep -oE "https://[^\"]*/release\.zip" | head -n 1)

    if [ -z "$LATEST_URL" ]; then
        echo -e "${RED}[!] Gagal mengambil URL rilis terbaru Blueprint.${NC}"
        echo -e "${YELLOW}Panduan instalasi manual: https://blueprint.zip/guides/admin/install${NC}"
        return 1
    fi

    TMP_BP=$(mktemp -d)
    echo -e "${YELLOW}[+] Mengunduh paket Blueprint...${NC}"
    if ! curl -fsSL "$LATEST_URL" -o "$TMP_BP/release.zip"; then
        rm -rf "$TMP_BP"
        echo -e "${RED}[!] Gagal mengunduh release.zip.${NC}"
        return 1
    fi

    if ! unzip -qo "$TMP_BP/release.zip" -d "$TMP_BP"; then
        rm -rf "$TMP_BP"
        echo -e "${RED}[!] Gagal mengekstrak release.zip.${NC}"
        return 1
    fi

    if ! cd "$PANEL_DIR"; then
        rm -rf "$TMP_BP"
        return 1
    fi

    if [ -f "$TMP_BP/blueprint.sh" ]; then
        echo -e "${YELLOW}[+] Menjalankan installer Blueprint...${NC}"
        if ! bash "$TMP_BP/blueprint.sh"; then
            rm -rf "$TMP_BP"
            echo -e "${RED}[!] Proses installer Blueprint mengalami error.${NC}"
            return 1
        fi
    else
        rm -rf "$TMP_BP"
        echo -e "${RED}[!] File blueprint.sh tidak ditemukan di arsip rilis.${NC}"
        return 1
    fi

    rm -rf "$TMP_BP"

    if command -v blueprint >/dev/null 2>&1 && blueprint -v >/dev/null 2>&1; then
        echo -e "${GREEN}[✓] Blueprint berhasil terinstall.${NC}"
        return 0
    else
        echo -e "${RED}[!] Perintah 'blueprint' belum tersedia setelah instalasi.${NC}"
        return 1
    fi
}

if ! command -v blueprint >/dev/null 2>&1; then
    echo -e "${RED}[!] Blueprint belum terinstall.${NC}"
    echo -e "${YELLOW}Auto-install akan mengunduh paket dari GitHub, menginstall dependensi (Node.js v22.x, Yarn, curl, unzip, git), dan memodifikasi folder panel di $PANEL_DIR.${NC}"
    if prompt_yn "Lanjutkan auto-install Blueprint sekarang? [y/N]: "; then
        install_blueprint_auto || exit 1
    else
        echo -e "${YELLOW}Install Blueprint secara manual: https://blueprint.zip/guides/admin/install${NC}"
        exit 1
    fi
else
    ensure_node_22 || exit 1
fi

# Cek dependensi frontend panel (webpack & react / node_modules)
if [ -f "$PANEL_DIR/package.json" ]; then
    if [ ! -d "$PANEL_DIR/node_modules/webpack" ] || [ ! -d "$PANEL_DIR/node_modules/react" ]; then
        echo -e "${RED}[!] Dependensi panel (webpack/react) belum lengkap di $PANEL_DIR.${NC}"
        if prompt_yn "Jalankan 'yarn install' di '$PANEL_DIR' sekarang? [y/N]: "; then
            if ! (cd "$PANEL_DIR" && yarn install); then
                echo -e "${RED}[!] 'yarn install' gagal.${NC}"
                exit 1
            fi
        else
            echo -e "${YELLOW}Instalasi dibatalkan karena dependensi panel (webpack/react) belum terinstall.${NC}"
            exit 1
        fi
    fi
fi

if ! command -v zip >/dev/null 2>&1; then
    if prompt_yn "Paket 'zip' belum terinstall. Install 'zip' sekarang? [y/N]: "; then
        apt-get update -y && apt-get install -y zip || exit 1
    else
        echo -e "${RED}[!] Paket 'zip' dibutuhkan untuk membuat ekstensi.${NC}"
        exit 1
    fi
fi

if ! prompt_yn "Lanjutkan install tema Neumorphism ke '$PANEL_DIR'? [y/N]: "; then
    echo -e "${YELLOW}Instalasi tema Neumorphism dibatalkan.${NC}"
    exit 0
fi

# Cek proses blueprint yang menggantung
if pgrep -f "blueprint" >/dev/null 2>&1; then
    echo -e "${RED}[!] Proses 'blueprint' terdeteksi sedang berjalan.${NC}"
    if prompt_yn "Hentikan proses 'blueprint' yang berjalan sekarang? [y/N]: "; then
        pkill -f "blueprint" >/dev/null 2>&1 || true
        sleep 1
    else
        echo -e "${YELLOW}Dibatalkan. Tunggu proses selesai lalu coba lagi.${NC}"
        exit 1
    fi
fi

# Cek dan bersihkan lockfile sisa di direktori panel
LOCK_FILES=$(find "$PANEL_DIR" -maxdepth 2 \( -name "*lock*" -o -name ".blueprint*" \) 2>/dev/null | grep -v "node_modules" | grep -v "vendor")
if [ -n "$LOCK_FILES" ]; then
    echo -e "${YELLOW}[!] Ditemukan file lock/state di $PANEL_DIR:${NC}"
    echo "$LOCK_FILES"
    if prompt_yn "Jalankan 'blueprint -unlock' dan bersihkan lockfile sisa? [y/N]: "; then
        blueprint -unlock >/dev/null 2>&1 || true
        while IFS= read -r lf; do
            if [ -n "$lf" ] && [ -f "$lf" ]; then
                rm -f "$lf" && echo -e "${GREEN}[-] Dihapus: $lf${NC}"
            fi
        done <<< "$LOCK_FILES"
    else
        echo -e "${YELLOW}Melewati pembersihan lockfile.${NC}"
    fi
fi

# Deteksi versi Blueprint untuk field "target"
BP_VER=$(blueprint -v 2>/dev/null | grep -oE '(beta|alpha)-[0-9]{4}-[0-9]{2}' | head -n 1)
BP_VER="${BP_VER:-beta-2026-08}"
echo -e "${YELLOW}[+] Versi Blueprint terdeteksi: $BP_VER${NC}"

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

cat > "$WORK/conf.yml" <<'EOF_CONF'
info:
  name: "Neumorphism"
  identifier: "neumorphism"
  description: "Soft UI (neumorphism) theme for the dashboard and admin panel."
  flags: ""
  version: "1.0.0"
  target: "__BP_VER__"
  author: "custom"
  icon: ""
  website: ""

admin:
  view: "view.blade.php"
  controller: ""
  css: "admin.css"
  wrapper: ""

dashboard:
  css: "dashboard.css"
  wrapper: ""
  components: ""

data:
  directory: ""
  public: ""
  console: ""

requests:
  views: ""
  app: ""
  routers:
    application: ""
    client: ""
    web: ""
EOF_CONF

sed -i "s/__BP_VER__/$BP_VER/" "$WORK/conf.yml"

cat > "$WORK/view.blade.php" <<'EOF_VIEW_BLADE_PHP'
<p>Neumorphism theme aktif. Ubah warna lewat variabel <code>:root</code> di <code>dashboard.css</code> dan <code>admin.css</code>.</p>
EOF_VIEW_BLADE_PHP

cat > "$WORK/dashboard.css" <<'EOF_DASHBOARD_CSS'
/* Neumorphism - dashboard
   Ubah warna di sini. Dark soft UI: satu warna dasar, dua bayangan (terang & gelap). */
:root {
  --neu-bg: #2b2f38;
  --neu-light: #373d49;
  --neu-dark: #1e2128;
  --neu-text: #c9d0dc;
  --neu-muted: #8b94a5;
  --neu-accent: #8ab4ff;
  --neu-radius: 16px;
  --neu-raised: 6px 6px 14px var(--neu-dark), -6px -6px 14px var(--neu-light);
  --neu-raised-sm: 3px 3px 7px var(--neu-dark), -3px -3px 7px var(--neu-light);
  --neu-inset: inset 4px 4px 9px var(--neu-dark), inset -4px -4px 9px var(--neu-light);
}

html, body, #app { background: var(--neu-bg) !important; color: var(--neu-text); }
::selection { background: var(--neu-accent); color: var(--neu-bg); }

/* Kartu / panel (kelas tailwind bawaan panel; bisa beda per versi) */
.bg-neutral-700, .bg-neutral-800, .bg-neutral-900,
.bg-gray-700, .bg-gray-800, .bg-gray-900 {
  background: var(--neu-bg) !important;
  border: 0 !important;
  border-radius: var(--neu-radius);
  box-shadow: var(--neu-raised);
}

/* Navigasi atas */
#NavigationBar, nav {
  background: var(--neu-bg) !important;
  box-shadow: 0 8px 16px var(--neu-dark) !important;
}

/* Input: tenggelam (inset) */
input:not([type="checkbox"]):not([type="radio"]):not([type="range"]),
select, textarea {
  background: var(--neu-bg) !important;
  color: var(--neu-text) !important;
  border: 0 !important;
  border-radius: 12px !important;
  box-shadow: var(--neu-inset) !important;
  transition: box-shadow .15s ease;
}
input:focus, select:focus, textarea:focus {
  outline: 2px solid var(--neu-accent) !important;
  outline-offset: 2px;
}
::placeholder { color: var(--neu-muted) !important; }

/* Tombol: timbul, ditekan jadi tenggelam. Warna tombol (merah/hijau) tetap. */
button, a[class*="button"], [role="button"] {
  border: 0 !important;
  border-radius: 12px !important;
  box-shadow: var(--neu-raised-sm);
  transition: box-shadow .15s ease, transform .15s ease;
}
button:hover:not(:disabled) { transform: translateY(-1px); }
button:active:not(:disabled) { box-shadow: var(--neu-inset) !important; transform: none; }
button:focus-visible { outline: 2px solid var(--neu-accent); outline-offset: 2px; }
button:disabled { box-shadow: none; opacity: .55; }

/* Tabel */
table { border-collapse: separate; border-spacing: 0 6px; }
tr { background: transparent !important; }

/* Scrollbar */
* { scrollbar-width: thin; scrollbar-color: var(--neu-light) var(--neu-bg); }
::-webkit-scrollbar { width: 10px; height: 10px; }
::-webkit-scrollbar-track { background: var(--neu-bg); }
::-webkit-scrollbar-thumb { background: var(--neu-light); border-radius: 10px; box-shadow: var(--neu-raised-sm); }

@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; }
  button:hover:not(:disabled) { transform: none; }
}
EOF_DASHBOARD_CSS

cat > "$WORK/admin.css" <<'EOF_ADMIN_CSS'
/* Neumorphism - admin (AdminLTE) */
:root {
  --neu-bg: #2b2f38;
  --neu-light: #373d49;
  --neu-dark: #1e2128;
  --neu-text: #c9d0dc;
  --neu-muted: #8b94a5;
  --neu-accent: #8ab4ff;
  --neu-radius: 16px;
  --neu-raised: 6px 6px 14px var(--neu-dark), -6px -6px 14px var(--neu-light);
  --neu-raised-sm: 3px 3px 7px var(--neu-dark), -3px -3px 7px var(--neu-light);
  --neu-inset: inset 4px 4px 9px var(--neu-dark), inset -4px -4px 9px var(--neu-light);
}

body, .wrapper, .content-wrapper, .right-side, .main-footer {
  background: var(--neu-bg) !important;
  color: var(--neu-text) !important;
  border: 0 !important;
}
h1, h2, h3, h4, h5, h6, .box-title, .content-header > h1 { color: var(--neu-text) !important; }
small, .text-muted, .content-header > h1 > small { color: var(--neu-muted) !important; }
a { color: var(--neu-accent); }

.main-header .navbar, .skin-blue .main-header .navbar, .skin-blue .main-header .logo {
  background: var(--neu-bg) !important;
  box-shadow: 0 6px 14px var(--neu-dark);
}
.main-sidebar, .skin-blue .main-sidebar, .skin-blue .wrapper {
  background: var(--neu-bg) !important;
  box-shadow: 6px 0 14px var(--neu-dark);
}
.skin-blue .sidebar-menu > li > a { color: var(--neu-muted); border: 0; }
.skin-blue .sidebar-menu > li.active > a,
.skin-blue .sidebar-menu > li:hover > a {
  background: var(--neu-bg) !important;
  color: var(--neu-accent) !important;
  box-shadow: var(--neu-inset);
  border-radius: 12px;
}
.skin-blue .sidebar-menu > li.header { background: transparent; color: var(--neu-muted); }

.box, .info-box, .small-box, .nav-tabs-custom, .modal-content {
  background: var(--neu-bg) !important;
  border: 0 !important;
  border-radius: var(--neu-radius);
  box-shadow: var(--neu-raised);
  color: var(--neu-text);
}
.box-header, .box-footer, .modal-header, .modal-footer {
  background: transparent !important;
  border-color: var(--neu-dark) !important;
}
.box.box-primary, .box.box-info, .box.box-danger, .box.box-warning, .box.box-success { border-top: 0 !important; }

.table > thead > tr > th,
.table > tbody > tr > td { border-color: var(--neu-dark) !important; color: var(--neu-text); }
.table-hover > tbody > tr:hover, .table-striped > tbody > tr:nth-of-type(odd) { background: var(--neu-light) !important; }

.form-control, select.form-control, textarea.form-control, .input-group-addon, .select2-selection {
  background: var(--neu-bg) !important;
  color: var(--neu-text) !important;
  border: 0 !important;
  border-radius: 12px !important;
  box-shadow: var(--neu-inset) !important;
}
.form-control:focus { outline: 2px solid var(--neu-accent); outline-offset: 2px; }

.btn {
  border: 0 !important;
  border-radius: 12px !important;
  box-shadow: var(--neu-raised-sm);
  transition: box-shadow .15s ease;
}
.btn:active, .btn.active { box-shadow: var(--neu-inset) !important; }
.btn-default { background: var(--neu-bg); color: var(--neu-text); }

.nav-tabs-custom > .nav-tabs > li.active > a { background: var(--neu-bg); color: var(--neu-accent); }
.callout { border-radius: var(--neu-radius); border: 0 !important; box-shadow: var(--neu-raised-sm); }

@media (prefers-reduced-motion: reduce) { * { transition: none !important; } }
EOF_ADMIN_CSS

PKG_PATH="$PANEL_DIR/$EXT_ID.blueprint"
echo -e "${YELLOW}[+] Membuat paket ekstensi...${NC}"
if ! (cd "$WORK" && zip -qr "$PKG_PATH" conf.yml view.blade.php dashboard.css admin.css); then
    echo -e "${RED}[!] Gagal membuat paket.${NC}"
    exit 1
fi

echo -e "${YELLOW}[+] Menginstall via Blueprint...${NC}"
if blueprint -install "$EXT_ID"; then
    rm -f "$PKG_PATH"
    php artisan view:clear >/dev/null 2>&1 || true
    php artisan cache:clear >/dev/null 2>&1 || true
    systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null || true
    echo -e "${GREEN}[✓] Neumorphism terinstall. Hard refresh browser (Ctrl+Shift+R).${NC}"
else
    echo -e "${RED}[!] Install gagal. Cek pesan error di atas (paket tersimpan di $PKG_PATH).${NC}"
fi
