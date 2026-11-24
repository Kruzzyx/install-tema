#!/bin/bash
# ============================================================
#  Kruzzy Neo-Brutalism Theme untuk Pterodactyl
#  Pakai : bash <(curl -fsSL https://raw.githubusercontent.com/Kruzzyx/install-tema/refs/heads/main/install.sh)
#          bash nb-install.sh gambar.png biru   (langsung)
#          bash nb-install.sh --reset           (kembalikan ke default)
#  Edit  : PANEL=/path/ke/panel bash nb-install.sh
# ============================================================
set -e
ORIG="$PWD"
PANEL="${PANEL:-/var/www/pterodactyl}"
TS=$(date +%s)
GITHUB_ICON_URL="${GITHUB_ICON_URL:-https://raw.githubusercontent.com/Kruzzyx/install-tema/refs/heads/main/icon.png}"

[ -d "$PANEL" ] || { echo "Folder panel tidak ditemukan: $PANEL"; exit 1; }
cd "$PANEL"
mkdir -p public/themes

WRAP=$(find resources/views/templates -maxdepth 1 -name "wrapper.blade.php" | head -n 1)
ADMIN=$(find resources/views/layouts -maxdepth 1 -name "admin.blade.php" | head -n 1)

unlink_theme() {
  [ -n "$WRAP" ]  && sed -i '/themes\/nb\.css/d; /themes\/nb-stars\.js/d' "$WRAP"
  [ -n "$ADMIN" ] && sed -i '/themes\/nb\.css/d; /themes\/nb-stars\.js/d; /neobrutalism-admin\.css/d; /nb-falling-stars-layer/d' "$ADMIN"
}

reset_theme() {
  unlink_theme
  rm -f public/themes/nb.css public/themes/nb-stars.js
  php artisan view:clear
  php artisan cache:clear
  chown -R www-data:www-data public/themes resources/views 2>/dev/null || true
  echo "Tema dihapus. Panel kembali ke tampilan default."
}

if [ "$1" = "--reset" ]; then
  reset_theme
  exit 0
fi

# ---------------- MENU PILIHAN (JIKA TANPA ARGUMEN) ----------------
if [ "$#" -eq 0 ]; then
  echo "[1] install theme neobrutalism"
  echo "[2] uninstall theme"
  echo "3 keluar"
  if [ -r /dev/tty ]; then
    read -rp "pilih salah satu output : " MENU_CHOICE < /dev/tty
  else
    read -rp "pilih salah satu output : " MENU_CHOICE
  fi
  MENU_CHOICE=$(echo "$MENU_CHOICE" | xargs)

  case "$MENU_CHOICE" in
    1)
      ;;
    2)
      reset_theme
      exit 0
      ;;
    3)
      echo "Keluar."
      exit 0
      ;;
    *)
      echo "Pilihan '$MENU_CHOICE' tidak valid. Keluar."
      exit 1
      ;;
  esac
fi

# ---------------- INPUT ----------------
IMG="$1"; COLOR="$2"
if [ -z "$IMG" ]; then
  if [ -r /dev/tty ]; then
    read -rp "Masukkan gambar (default icon.png): " IMG < /dev/tty
  else
    read -rp "Masukkan gambar (default icon.png): " IMG
  fi
fi
IMG="${IMG:-icon.png}"

if [ -z "$COLOR" ]; then
  echo "Warna: biru, putih, merah, hijau, ungu, kuning, orange, pink, atau kode hex (contoh #ff8800)"
  if [ -r /dev/tty ]; then
    read -rp "Masukkan warna (default biru): " COLOR < /dev/tty
  else
    read -rp "Masukkan warna (default biru): " COLOR
  fi
fi
COLOR=$(echo "${COLOR:-biru}" | tr 'A-Z' 'a-z' | xargs)

case "$COLOR" in
  biru|blue)          HEX=2bb6ff ;;
  putih|white)        HEX=ffffff ;;
  merah|red)          HEX=ff4d6d ;;
  hijau|green)        HEX=35f2a0 ;;
  ungu|purple)        HEX=b57bff ;;
  kuning|yellow)      HEX=ffd93d ;;
  orange|oranye)      HEX=ff9f43 ;;
  pink)               HEX=ff6bcb ;;
  \#[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]) HEX="${COLOR#\#}" ;;
  [0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f])   HEX="$COLOR" ;;
  *) echo "Warna '$COLOR' tidak dikenal, pakai biru."; COLOR=biru; HEX=2bb6ff ;;
esac

# ---------------- PALET ----------------
hx() { printf '#%02x%02x%02x' "$(( $1 > 255 ? 255 : $1 ))" "$(( $2 > 255 ? 255 : $2 ))" "$(( $3 > 255 ? 255 : $3 ))"; }
r=$((16#${HEX:0:2})); g=$((16#${HEX:2:2})); b=$((16#${HEX:4:2}))
LINE="#$HEX"
DEEP=$(hx $((r*45/100)) $((g*45/100)) $((b*45/100)))
SOFT=$(hx $((r+(255-r)*75/100)) $((g+(255-g)*75/100)) $((b+(255-b)*75/100)))
BG=$(hx $((r*3/100+2)) $((g*3/100+2)) $((b*3/100+3)))
CARD=$(hx $((r*9/100+7)) $((g*9/100+7)) $((b*9/100+9)))
FIELD=$(hx $((r*4/100+3)) $((g*4/100+3)) $((b*4/100+5)))
MUTED=$(hx $(((r*35+150*65)/100)) $(((g*35+150*65)/100)) $(((b*35+150*65)/100)))
LINK=$(hx $((r+(255-r)*35/100)) $((g+(255-g)*35/100)) $((b+(255-b)*35/100)))
GRAD1=$(hx $((r*70/100)) $((g*70/100)) $((b*70/100)))
RGB="$r,$g,$b"
LUM=$(( (299*r + 587*g + 114*b) / 1000 ))
if [ "$LUM" -gt 150 ]; then INK="#02050f"; else INK="#ffffff"; fi
if [ "$HEX" = "2bb6ff" ]; then   # biru: palet pilihan
  DEEP="#1448c8"; SOFT="#bfe9ff"; BG="#02050f"; CARD="#071029"; FIELD="#030a1c"
  MUTED="#7fa8d8"; LINK="#6fd6ff"; GRAD1="#1f6bff"; INK="#ffffff"
fi

# ---------------- GAMBAR ----------------
IMG_SRC=""
case "$IMG" in
  http://*|https://*) IMG_SRC="$IMG" ;;
  *)
    FILE=""
    [ -f "$IMG" ] && FILE="$IMG"
    [ -z "$FILE" ] && [ -f "$ORIG/$IMG" ] && FILE="$ORIG/$IMG"
    BASE=$(basename "$IMG")
    if [ -n "$FILE" ]; then
      [ "$(realpath "$FILE")" != "$(realpath "public/themes/$BASE" 2>/dev/null || echo x)" ] && cp "$FILE" "public/themes/$BASE"
      IMG_SRC="/themes/$BASE?v=$TS"
    elif [ -f "public/themes/$BASE" ]; then
      IMG_SRC="/themes/$BASE?v=$TS"
    else
      DL_URL="$GITHUB_ICON_URL"
      if [ "$BASE" != "icon.png" ]; then
        DL_URL="https://raw.githubusercontent.com/Kruzzyx/install-tema/refs/heads/main/$BASE"
      fi
      if command -v curl >/dev/null 2>&1 && curl -fsSL "$DL_URL" -o "public/themes/$BASE" && [ -s "public/themes/$BASE" ]; then
        IMG_SRC="/themes/$BASE?v=$TS"
      else
        rm -f "public/themes/$BASE"
        echo "PERINGATAN: gambar '$IMG' tidak ditemukan (lokal maupun GitHub)."
        echo "            Taruh di $PANEL/public/themes/ lalu jalankan ulang. Sementara logo bawaan dipakai."
      fi
    fi ;;
esac

# ---------------- BERSIHKAN TEMA LAMA ----------------
NEED_BUILD=0
INDEX=resources/scripts/index.tsx
if [ -f "$INDEX" ] && grep -qE "neobrutalism|falling-stars|blackpurpleblue|neumorphism" "$INDEX"; then
  sed -i "/blackpurpleblue\.css/d; /neumorphism\.css/d; /neobrutalism\.css/d; /falling-stars/d" "$INDEX"
  rm -f resources/scripts/neobrutalism.css resources/scripts/falling-stars.ts
  NEED_BUILD=1
fi
rm -f public/themes/neobrutalism-admin.css

# ---------------- TULIS CSS ----------------
cat <<EOF > public/themes/nb.css
/* Kruzzy Neo-Brutalism | warna: $COLOR ($LINE) */
:root{
  --nb-line:$LINE; --nb-deep:$DEEP; --nb-soft:$SOFT; --nb-bg:$BG; --nb-card:$CARD; --nb-field:$FIELD;
  --nb-muted:$MUTED; --nb-link:$LINK; --nb-grad1:$GRAD1; --nb-rgb:$RGB; --nb-ink:$INK;
  --nb-red:#ff4d6d; --nb-green:#35f2a0;
}
EOF

cat <<'EOF' >> public/themes/nb.css
/* ===== GLOBAL & BINTANG JATUH ===== */
html,body{background-color:var(--nb-bg)!important;color:#fff;overflow-x:hidden;
  background-image:radial-gradient(rgba(var(--nb-rgb),.14) 1px,transparent 1px),radial-gradient(ellipse at 50% 0%,rgba(var(--nb-rgb),.22),transparent 55%);
  background-size:22px 22px,100% 100%}
#app{position:relative;z-index:1;background:transparent!important}
::selection{background:var(--nb-line);color:#02050f}

#nb-starfield{position:fixed;inset:0;z-index:0;pointer-events:none;overflow:hidden}
.nb-meteor{position:absolute;top:-12%;left:var(--x,50%);width:2.5px;height:85px;
  background:linear-gradient(180deg,rgba(255,255,255,0),var(--nb-soft),var(--nb-line));
  border-radius:999px;filter:drop-shadow(0 0 8px rgba(var(--nb-rgb),.85));
  opacity:0;transform:rotate(-35deg) translate3d(0,0,0);
  animation:nb-meteor-fall var(--dur,3.6s) linear var(--delay,0s) infinite}
.nb-meteor::after{content:"";position:absolute;bottom:-2px;left:50%;transform:translateX(-50%);
  width:6px;height:6px;border-radius:50%;background:#fff;box-shadow:0 0 10px var(--nb-line),0 0 18px var(--nb-soft)}
@keyframes nb-meteor-fall{
  0%{opacity:0;transform:rotate(-35deg) translate3d(0,0,0)}
  10%{opacity:.95}
  75%{opacity:.85}
  100%{opacity:0;transform:rotate(-35deg) translate3d(0,115vh,0)}
}

/* ===== PANEL : NAVBAR & GESER KIRI-KANAN RESPONSIF ===== */
div[class*="NavigationBar"]{background:var(--nb-card)!important;border:0!important;border-bottom:3px solid var(--nb-line)!important;
  border-radius:0!important;box-shadow:0 4px 0 var(--nb-deep)!important;position:relative;z-index:20}
div[class*="NavigationBar"] div[class*="NavigationBar"]{border:0!important;box-shadow:none!important;background:transparent!important}
#logo,#logo a{background:transparent!important;color:#fff!important;font-weight:800;text-shadow:0 0 12px rgba(var(--nb-rgb),.8);white-space:nowrap;flex-shrink:0}
div[class*="NavigationBar"] a,div[class*="NavigationBar"] button{color:#fff!important;background:transparent!important;
  border:3px solid transparent!important;border-radius:6px!important;box-shadow:none!important;flex-shrink:0;white-space:nowrap}
div[class*="NavigationBar"] a:hover,div[class*="NavigationBar"] button:hover{background:var(--nb-field)!important;border-color:var(--nb-line)!important}
div[class*="NavigationBar"] a.active,div[class*="NavigationBar"] a[aria-current="page"]{background:var(--nb-line)!important;color:#02050f!important;
  border-color:var(--nb-soft)!important;box-shadow:3px 3px 0 var(--nb-deep)!important}

@media (max-width:767px){
  div[class*="NavigationBar"] > div{display:flex!important;flex-direction:row!important;flex-wrap:nowrap!important;
    align-items:center!important;gap:.45rem!important;overflow-x:auto!important;overflow-y:visible!important;
    -webkit-overflow-scrolling:touch;scroll-snap-type:x proximity;padding:.45rem .6rem .55rem!important;scrollbar-width:none}
  div[class*="NavigationBar"] > div::-webkit-scrollbar{display:none}
  div[class*="NavigationBar"] a,div[class*="NavigationBar"] button{min-width:2.65rem;height:2.5rem;
    display:inline-flex!important;align-items:center!important;justify-content:center!important;
    padding:0 .65rem!important;scroll-snap-align:start}
}

/* ===== PANEL : TAB SERVER (SubNavigation) ===== */
div[class*="SubNavigation"]{background:transparent!important;box-shadow:none!important;border:0!important}
div[class*="SubNavigation"] > div{display:flex;gap:.5rem;padding:.8rem .75rem .3rem;overflow-x:auto;
  -webkit-overflow-scrolling:touch;scroll-snap-type:x proximity;scrollbar-width:none}
div[class*="SubNavigation"] > div::-webkit-scrollbar{display:none}
div[class*="SubNavigation"] a{flex:none;padding:.5rem .9rem!important;margin:0!important;background:var(--nb-card)!important;color:var(--nb-soft)!important;
  font-weight:700;border:3px solid var(--nb-line)!important;border-radius:6px!important;box-shadow:none!important;scroll-snap-align:start}
div[class*="SubNavigation"] a.active,div[class*="SubNavigation"] a[aria-current="page"]{background:var(--nb-line)!important;color:#02050f!important;
  border-color:var(--nb-soft)!important;box-shadow:3px 3px 0 var(--nb-deep)!important;font-weight:800}

/* ===== PANEL : KARTU ===== */
:is([class*="TitledGreyBox"],[class*="ContentBox"],[class*="ChartBlock"],[class*="StatBlock"],[class*="GreyRowBox"],[class*="ServerRow"]):not(:is([class*="TitledGreyBox"],[class*="ContentBox"],[class*="ChartBlock"],[class*="StatBlock"],[class*="GreyRowBox"],[class*="ServerRow"]) *){
  background:var(--nb-card)!important;color:#fff!important;border:3px solid var(--nb-line)!important;border-radius:8px!important;
  box-shadow:5px 5px 0 var(--nb-deep),0 0 20px rgba(var(--nb-rgb),.2)!important}
:is([class*="TitledGreyBox"],[class*="ContentBox"],[class*="ChartBlock"],[class*="StatBlock"],[class*="GreyRowBox"],[class*="ServerRow"]) *{
  border-color:transparent;box-shadow:none!important}
[class*="StatBlock"]:not([class*="StatBlock"] *){border-left-width:8px!important}
a[class*="ServerRow"]{transition:transform .12s,box-shadow .12s}
a[class*="ServerRow"]:hover{transform:translate(-2px,-2px);box-shadow:8px 8px 0 var(--nb-deep),0 0 26px rgba(var(--nb-rgb),.4)!important}
[class*="ServerRow"] div:has(> svg[data-icon="server"]){background:var(--nb-line)!important;color:#02050f!important;
  border:3px solid var(--nb-soft)!important;border-radius:6px!important;box-shadow:3px 3px 0 var(--nb-deep)!important}
[class*="ServerRow"] div:has(> svg[data-icon="server"]) svg{color:#02050f!important}

/* ===== PANEL : CONSOLE ===== */
[class*="Console"][class*="container"]{background:#01030a!important;border:3px solid var(--nb-line)!important;border-bottom:0!important;
  border-radius:8px 8px 0 0!important;box-shadow:0 0 22px rgba(var(--nb-rgb),.25)!important}
#app input[class*="command_input"]{background:var(--nb-field)!important;color:#fff!important;border:3px solid var(--nb-line)!important;
  border-radius:0 0 8px 8px!important;box-shadow:5px 5px 0 var(--nb-deep)!important}
#app input[class*="command_input"]:focus{border-color:var(--nb-soft)!important}
[class*="command_icon"]{color:var(--nb-line)!important}

/* ===== PANEL : FORM & TOMBOL ===== */
#app input:not([type="checkbox"]):not([type="radio"]):not([type="range"]):not([class*="command_input"]),#app select,#app textarea{
  background:var(--nb-field)!important;color:#fff!important;border:3px solid var(--nb-line)!important;border-radius:4px!important;box-shadow:none!important}
#app input:not([type="checkbox"]):not([type="radio"]):not([type="range"]):not([class*="command_input"]):focus,#app select:focus,#app textarea:focus{
  outline:none!important;border-color:var(--nb-soft)!important;box-shadow:4px 4px 0 var(--nb-deep),0 0 14px rgba(var(--nb-rgb),.5)!important}
#app ::placeholder{color:var(--nb-muted)!important}
#app button[type="submit"],#app button[class*="Button___"],#app a[class*="Button___"]{
  background:linear-gradient(90deg,var(--nb-grad1),var(--nb-line))!important;color:var(--nb-ink)!important;font-weight:800!important;
  text-transform:uppercase;letter-spacing:.05em;border:3px solid var(--nb-soft)!important;border-radius:5px!important;
  box-shadow:3px 3px 0 var(--nb-deep)!important;transition:transform .1s,box-shadow .1s}
#app button[type="submit"]:active,#app button[class*="Button___"]:active{transform:translate(3px,3px);box-shadow:none!important}

/* ===== LOGIN ===== */
div:has(> h2):has(form){background:var(--nb-card)!important;border:3px solid var(--nb-line)!important;border-radius:10px!important;
  box-shadow:7px 7px 0 var(--nb-deep),0 0 28px rgba(var(--nb-rgb),.35)!important;width:calc(100% - 2.5rem)!important;max-width:30rem!important;
  margin:1.5rem auto!important;padding:1.5rem 1.25rem!important}
div:has(> h2):has(form) > h2{color:#fff!important;font-weight:800!important;text-transform:uppercase;letter-spacing:.06em;text-align:center;
  padding:0 0 1rem!important;margin-bottom:1.25rem;border-bottom:3px solid var(--nb-line);text-shadow:0 0 14px rgba(var(--nb-rgb),.8)}
div:has(> h2):has(form) form > div{background:transparent!important;border:0!important;box-shadow:none!important;padding:0!important;margin:0!important}
div:has(> h2):has(form) form img{display:block;width:100%;max-width:100%;height:auto;margin:0 0 1.25rem;border:3px solid var(--nb-line);
  border-radius:6px;box-shadow:4px 4px 0 var(--nb-deep),0 0 18px rgba(var(--nb-rgb),.45)}
div:has(> h2):has(form) label{color:var(--nb-muted)!important;font-size:.72rem!important;font-weight:800!important;letter-spacing:.08em;text-transform:uppercase}
div:has(> h2):has(form) form a{color:var(--nb-link)!important;font-weight:700}
div:has(> h2):has(form) > p{border-top:3px solid var(--nb-line);padding-top:1rem;margin-top:1.25rem!important;color:var(--nb-muted)!important}

/* ===== ADMIN (AdminLTE) ===== */
.main-header .logo{display:none!important}
.main-header .navbar,.skin-blue .main-header .navbar{margin-left:0!important;background:var(--nb-card)!important;border-bottom:3px solid var(--nb-line)!important;box-shadow:0 4px 0 var(--nb-deep)!important}
.skin-blue .main-header .navbar .nav > li > a,.skin-blue .main-header .navbar .sidebar-toggle{color:#fff!important}
.skin-blue .main-header .navbar .nav > li > a:hover,.skin-blue .main-header .navbar .sidebar-toggle:hover{background:var(--nb-field)!important}
.wrapper,.content-wrapper,.right-side,.main-footer{background:transparent!important;color:#fff!important;border:0!important}
.main-footer{border-top:3px solid var(--nb-line)!important;background:var(--nb-card)!important;color:var(--nb-muted)!important}
.main-sidebar,.skin-blue .main-sidebar,.skin-blue .wrapper{background:var(--nb-card)!important;border-right:3px solid var(--nb-line)!important}
.skin-blue .sidebar-menu > li.header{background:var(--nb-bg)!important;color:var(--nb-muted)!important;font-weight:800;letter-spacing:.1em;
  border-top:2px solid rgba(var(--nb-rgb),.4);border-bottom:2px solid rgba(var(--nb-rgb),.4)}
.skin-blue .sidebar-menu > li > a{color:#fff!important;font-weight:600;border-left:5px solid transparent!important;background:transparent!important}
.skin-blue .sidebar-menu > li:hover > a{background:var(--nb-field)!important;border-left-color:var(--nb-line)!important}
.skin-blue .sidebar-menu > li.active > a{background:var(--nb-line)!important;color:#02050f!important;border-left-color:var(--nb-soft)!important;font-weight:800}
.content-header > h1{color:#fff!important;font-weight:800;text-shadow:0 0 12px rgba(var(--nb-rgb),.6)}
.content-header > h1 > small{color:var(--nb-muted)!important;text-shadow:none}
.content-wrapper a:not(.btn){color:var(--nb-link)}
.breadcrumb{background:var(--nb-card)!important;border:3px solid var(--nb-line)!important;border-radius:6px!important;box-shadow:3px 3px 0 var(--nb-deep)!important;color:var(--nb-soft)!important}
.box,.info-box,.small-box,.nav-tabs-custom,.modal-content,.callout{background:var(--nb-card)!important;color:#fff!important;border:3px solid var(--nb-line)!important;
  border-radius:8px!important;box-shadow:6px 6px 0 var(--nb-deep),0 0 22px rgba(var(--nb-rgb),.2)!important}
.box-header,.box-footer,.modal-header,.modal-footer{background:transparent!important;border-color:var(--nb-line)!important;border-width:3px!important}
.box-title{color:#fff!important;font-weight:800!important;text-transform:uppercase;letter-spacing:.04em}
.nav-tabs-custom > .nav-tabs{background:var(--nb-bg)!important;border-bottom:3px solid var(--nb-line)!important}
.nav-tabs-custom > .nav-tabs > li > a{color:#fff!important;font-weight:700}
.nav-tabs-custom > .nav-tabs > li.active{border-top-color:var(--nb-line)!important}
.nav-tabs-custom > .nav-tabs > li.active > a{background:var(--nb-line)!important;color:#02050f!important}
.box-body{overflow-x:auto}
.table,.table > thead > tr > th,.table > tbody > tr > td{color:#fff!important;background:transparent!important;border-color:rgba(var(--nb-rgb),.3)!important}
.table > thead > tr > th{border-bottom:3px solid var(--nb-line)!important;font-weight:800;text-transform:uppercase;font-size:12px;letter-spacing:.05em;color:var(--nb-soft)!important}
.table-hover > tbody > tr:hover > td{background:var(--nb-field)!important}
code,pre{background:var(--nb-field)!important;color:var(--nb-line)!important;border:2px solid var(--nb-line)!important;border-radius:3px!important}
.label,.badge{border:2px solid #fff!important;border-radius:3px!important;color:#02050f!important;font-weight:800}
.label-success,.bg-green{background:var(--nb-green)!important}.label-danger,.bg-red{background:var(--nb-red)!important}
.label-warning,.bg-yellow{background:#ffd93d!important}.label-default,.label-info,.label-primary,.bg-aqua,.bg-blue{background:var(--nb-line)!important}
.content-wrapper .btn{background:linear-gradient(90deg,var(--nb-grad1),var(--nb-line))!important;color:var(--nb-ink)!important;border:3px solid var(--nb-soft)!important;
  border-radius:5px!important;box-shadow:3px 3px 0 var(--nb-deep)!important;font-weight:800!important;transition:transform .1s,box-shadow .1s}
.content-wrapper .btn:hover{transform:translate(-1px,-1px);box-shadow:4px 4px 0 var(--nb-deep)!important}
.content-wrapper .btn:active{transform:translate(3px,3px);box-shadow:none!important}
.content-wrapper .btn-success{background:var(--nb-green)!important;color:#02050f!important}
.content-wrapper .btn-danger{background:var(--nb-red)!important;color:#02050f!important}
.content-wrapper .btn-warning{background:#ffb347!important;color:#02050f!important}
.content-wrapper .btn-default{background:var(--nb-field)!important;color:#fff!important;border-color:var(--nb-line)!important}
.form-control,select.form-control,textarea.form-control,.input-group-addon,.select2-selection{background:var(--nb-field)!important;color:#fff!important;
  border:3px solid var(--nb-line)!important;border-radius:4px!important;box-shadow:none!important}
.form-control:focus{border-color:var(--nb-soft)!important;box-shadow:4px 4px 0 var(--nb-deep)!important}
.form-control::placeholder{color:var(--nb-muted)!important}
.help-block,.text-muted{color:var(--nb-muted)!important}
@media (min-width:768px) and (max-width:1100px){
  .content-wrapper,.right-side,.main-footer{margin-left:0!important}
  .main-sidebar{transform:translate(-230px,0)!important;transition:transform .2s}
  body.sidebar-collapse .main-sidebar{transform:translate(0,0)!important;box-shadow:6px 0 0 var(--nb-deep)}
}
EOF

# gambar login
if [ -n "$IMG_SRC" ]; then
  SAFE=${IMG_SRC//\"/}
  printf '\n/* GAMBAR LOGIN */\ndiv:has(> h2):has(form) form img{content:url("%s");object-fit:contain}\n' "$SAFE" >> public/themes/nb.css
fi

# ---------------- SCRIPT BINTANG JATUH ----------------
cat <<'EOF' > public/themes/nb-stars.js
(function(){
  if (document.getElementById('nb-starfield')) return;
  const layer = document.createElement('div');
  layer.id = 'nb-starfield';
  layer.setAttribute('aria-hidden', 'true');
  const count = window.innerWidth < 768 ? 7 : 12;
  for (let i = 0; i < count; i++) {
    const m = document.createElement('span');
    m.className = 'nb-meteor';
    m.style.setProperty('--x', (8 + ((i * 83) % 86)) + '%');
    m.style.setProperty('--dur', (2.8 + (i % 4) * 0.75) + 's');
    m.style.setProperty('--delay', ((i * 0.65) % 4.2).toFixed(2) + 's');
    layer.appendChild(m);
  }
  document.body.prepend(layer);
})();
EOF

# ---------------- PASANG LINK ----------------
unlink_theme
[ -n "$WRAP" ]  && sed -i "/<\/head>/i <link rel=\"stylesheet\" href=\"/themes/nb.css?v=$TS\">" "$WRAP"
[ -n "$WRAP" ]  && sed -i "/<\/body>/i <script src=\"/themes/nb-stars.js?v=$TS\" defer></script>" "$WRAP"
[ -n "$ADMIN" ] && sed -i "/<\/head>/i <link rel=\"stylesheet\" href=\"/themes/nb.css?v=$TS\">" "$ADMIN"

if [ "$NEED_BUILD" = "1" ]; then
  echo "Membersihkan tema lama dari bundle (build sekali, tunggu sebentar)..."
  unset NODE_OPTIONS
  yarn run build:production
fi

php artisan view:clear
php artisan cache:clear
chown -R www-data:www-data public/themes resources/views 2>/dev/null || true
echo
echo "SELESAI. Warna: $COLOR ($LINE) | Gambar: ${IMG_SRC:-bawaan} | Bintang jatuh: aktif"
echo "Hard refresh browser (tarik ulang halaman). Ganti warna/gambar: jalankan script ini lagi."
