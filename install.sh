#!/bin/bash
# ============================================================
#  Kruzzy Neo-Brutalism Theme untuk Pterodactyl (v2)
#  Pakai : bash nb-install.sh                 (menu interaktif)
#          bash nb-install.sh gambar.png biru (langsung install)
#          bash nb-install.sh --reset         (hapus tema)
#  Edit  : PANEL=/path/ke/panel bash nb-install.sh
# ============================================================
set -e
ORIG="$PWD"
PANEL="${PANEL:-/var/www/pterodactyl}"
TS=$(date +%s)

[ -d "$PANEL" ] || { echo "Folder panel tidak ditemukan: $PANEL"; exit 1; }
cd "$PANEL"
mkdir -p public/themes

WRAP=$(find resources/views/templates -maxdepth 1 -name "wrapper.blade.php" | head -n 1)
ADMIN=$(find resources/views/layouts -maxdepth 1 -name "admin.blade.php" | head -n 1)

unlink_theme() {
  [ -n "$WRAP" ]  && sed -i '/themes\/nb\.css/d; /themes\/nb-stars\.js/d' "$WRAP"
  [ -n "$ADMIN" ] && sed -i '/themes\/nb\.css/d; /themes\/nb-stars\.js/d; /neobrutalism-admin\.css/d; /nb-falling-stars-layer/d' "$ADMIN"
}

do_uninstall() {
  unlink_theme
  rm -f public/themes/nb.css public/themes/nb-stars.js
  php artisan view:clear
  echo "Tema dihapus. Panel kembali ke tampilan default."
}

do_install() {
  local IMG="$1" COLOR="$2"
  if [ -z "$IMG" ]; then
    echo "Icon login: kosongkan (Enter) = pakai logo burung bawaan."
    echo "            Atau tempel link gambar (GitHub / ImgBB / dll) / nama file lokal."
    read -rp "Link gambar (Enter = burung bawaan): " IMG
  fi
  if [ -z "$COLOR" ]; then
    echo "Warna: biru, putih, merah, hijau, ungu, kuning, orange, pink, atau hex (#ff8800)"
    read -rp "Masukkan warna (default biru): " COLOR
  fi
  COLOR=$(echo "${COLOR:-biru}" | tr 'A-Z' 'a-z' | xargs)

  case "$COLOR" in
    biru|blue)     HEX=2bb6ff ;;
    putih|white)   HEX=ffffff ;;
    merah|red)     HEX=ff4d6d ;;
    hijau|green)   HEX=35f2a0 ;;
    ungu|purple)   HEX=b57bff ;;
    kuning|yellow) HEX=ffd93d ;;
    orange|oranye) HEX=ff9f43 ;;
    pink)          HEX=ff6bcb ;;
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
  if [ "$HEX" = "2bb6ff" ]; then
    DEEP="#1448c8"; SOFT="#bfe9ff"; BG="#02050f"; CARD="#071029"; FIELD="#030a1c"
    MUTED="#7fa8d8"; LINK="#6fd6ff"; GRAD1="#1f6bff"; INK="#ffffff"
  fi

  # ---------------- GAMBAR ----------------
  IMG_SRC=""
  case "$IMG" in
    "") ;;   # kosong: logo burung bawaan
    http://*|https://*)
      URL=$(echo "$IMG" | sed -E 's#https://github\.com/([^/]+)/([^/]+)/(blob|raw)/#https://raw.githubusercontent.com/\1/\2/#')
      is_img() { [ -s "$1" ] && file -b --mime-type "$1" 2>/dev/null | grep -q '^image/'; }
      TMP=public/themes/icon.tmp; rm -f "$TMP"; GOT=0
      if curl -fsSL "$URL" -o "$TMP" 2>/dev/null; then
        if is_img "$TMP"; then
          GOT=1
        else
          # kalau link berupa halaman web, coba ambil link gambarnya (og:image)
          OG=$(grep -oE 'property="og:image" content="[^"]+' "$TMP" 2>/dev/null | head -1 | sed 's/.*content="//')
          if [ -n "$OG" ]; then
            echo "Link ini halaman web, memakai gambar langsung: $OG"
            curl -fsSL "$OG" -o "$TMP" 2>/dev/null && is_img "$TMP" && GOT=1
          fi
        fi
      fi
      if [ "$GOT" = "1" ]; then
        mv -f "$TMP" public/themes/icon.png
        echo "Icon berhasil diunduh dari: $URL"
        IMG_SRC="/themes/icon.png?v=$TS"
      else
        rm -f "$TMP"
        echo "PERINGATAN: $URL bukan gambar valid / tidak bisa diunduh."
        if is_img public/themes/icon.png; then
          echo "            Memakai icon.png yang sudah ada di $PANEL/public/themes/"
          IMG_SRC="/themes/icon.png?v=$TS"
        else
          rm -f public/themes/icon.png
          echo "            Logo bawaan dipakai. Cek link, atau taruh icon.png manual."
        fi
      fi ;;
    *)
      FILE=""
      [ -f "$IMG" ] && FILE="$IMG"
      [ -z "$FILE" ] && [ -f "$ORIG/$IMG" ] && FILE="$ORIG/$IMG"
      if [ -n "$FILE" ]; then
        BASE=$(basename "$FILE")
        [ "$(realpath "$FILE")" != "$(realpath "public/themes/$BASE" 2>/dev/null || echo x)" ] && cp "$FILE" "public/themes/$BASE"
        IMG_SRC="/themes/$BASE?v=$TS"
      elif [ -f "public/themes/$(basename "$IMG")" ]; then
        IMG_SRC="/themes/$(basename "$IMG")?v=$TS"
      else
        echo "PERINGATAN: gambar '$IMG' tidak ditemukan. Logo bawaan dipakai."
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

  # ---------------- BINTANG JATUH + BERKEDIP (JS canvas) ----------------
  cat <<'EOF' > public/themes/nb-stars.js
(function(){
  if(document.getElementById('nb-stars'))return;
  var c=document.createElement('canvas');c.id='nb-stars';
  c.style.cssText='position:fixed;left:0;top:0;width:100%;height:100%;z-index:-1;pointer-events:none';
  document.body.insertBefore(c,document.body.firstChild);
  var x=c.getContext('2d'),W=0,H=0,stars=[],shoots=[],rgb='43,182,255',t=0;
  try{var v=getComputedStyle(document.documentElement).getPropertyValue('--nb-rgb').trim();if(v)rgb=v}catch(e){}
  function size(){
    var d=window.devicePixelRatio||1;W=window.innerWidth;H=window.innerHeight;
    c.width=W*d;c.height=H*d;x.setTransform(d,0,0,d,0,0);
    var n=Math.min(220,Math.floor(W*H/7000));stars=[];
    for(var i=0;i<n;i++)stars.push({x:Math.random()*W,y:Math.random()*H,r:Math.random()*1.3+.3,p:Math.random()*6.28,s:Math.random()*.04+.01,w:Math.random()<.25});
  }
  function spawn(){
    var a=Math.PI*(.6+Math.random()*.15),sp=6+Math.random()*6;
    shoots.push({x:Math.random()*W*1.2,y:-20,vx:Math.cos(a)*sp,vy:Math.sin(a)*sp,l:80+Math.random()*100});
  }
  function frame(){
    t++;x.clearRect(0,0,W,H);
    for(var i=0;i<stars.length;i++){
      var s=stars[i],o=.25+.75*Math.abs(Math.sin(s.p+t*s.s));
      x.beginPath();x.arc(s.x,s.y,s.r,0,6.283);
      x.fillStyle=s.w?'rgba(255,255,255,'+o+')':'rgba('+rgb+','+o+')';
      x.shadowColor='rgba('+rgb+',.9)';x.shadowBlur=s.r*4;x.fill();
    }
    x.shadowBlur=0;
    if(Math.random()<.025&&shoots.length<5)spawn();
    for(var j=shoots.length-1;j>=0;j--){
      var m=shoots[j];m.x+=m.vx;m.y+=m.vy;
      var n=Math.sqrt(m.vx*m.vx+m.vy*m.vy),tx=m.x-m.vx/n*m.l,ty=m.y-m.vy/n*m.l;
      var g=x.createLinearGradient(m.x,m.y,tx,ty);
      g.addColorStop(0,'rgba(255,255,255,.95)');g.addColorStop(.3,'rgba('+rgb+',.5)');g.addColorStop(1,'rgba('+rgb+',0)');
      x.strokeStyle=g;x.lineWidth=2;x.lineCap='round';x.beginPath();x.moveTo(m.x,m.y);x.lineTo(tx,ty);x.stroke();
      x.beginPath();x.arc(m.x,m.y,2,0,6.283);x.fillStyle='#fff';x.fill();
      if(m.y>H+m.l||m.x<-m.l||m.x>W+m.l)shoots.splice(j,1);
    }
    requestAnimationFrame(frame);
  }
  window.addEventListener('resize',size);size();frame();
})();
EOF

  # ---------------- TULIS CSS ----------------
  cat <<EOF > public/themes/nb.css
/* Kruzzy Neo-Brutalism | warna: $COLOR ($LINE) */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Space+Grotesk:wght@500;700&family=JetBrains+Mono:wght@500&display=swap');
:root{
  --nb-line:$LINE; --nb-deep:$DEEP; --nb-soft:$SOFT; --nb-bg:$BG; --nb-card:$CARD; --nb-field:$FIELD;
  --nb-muted:$MUTED; --nb-link:$LINK; --nb-grad1:$GRAD1; --nb-rgb:$RGB; --nb-ink:$INK;
  --nb-red:#ff4d6d; --nb-green:#35f2a0;
}
EOF

  cat <<'EOF' >> public/themes/nb.css
/* ===== GLOBAL (latar bersih, tanpa pola ubin; bintang digambar canvas) ===== */
html{background-color:var(--nb-bg)!important;
  background-image:radial-gradient(ellipse at 50% 0%,rgba(var(--nb-rgb),.18),transparent 60%)!important;
  background-repeat:no-repeat!important;background-attachment:fixed!important;background-size:100% 100%!important}
body{background:transparent!important;color:#fff}
#app{background:transparent!important}
::selection{background:var(--nb-line);color:#02050f}
@keyframes nbflow{from{background-position:0 0}to{background-position:200% 0}}

/* ===== PANEL : NAVBAR (garis bawah bergerak) ===== */
div[class*="NavigationBar"]{position:relative;background:var(--nb-card)!important;border:0!important;
  border-radius:0!important;box-shadow:0 6px 18px -6px rgba(var(--nb-rgb),.55)!important}
div[class*="NavigationBar"]::after{content:"";position:absolute;left:0;right:0;bottom:0;height:3px;pointer-events:none;
  background:linear-gradient(90deg,var(--nb-deep),var(--nb-line),var(--nb-soft),var(--nb-line),var(--nb-deep));
  background-size:200% 100%;animation:nbflow 3s linear infinite}
div[class*="NavigationBar"] div[class*="NavigationBar"]{border:0!important;box-shadow:none!important;background:transparent!important}
div[class*="NavigationBar"] div[class*="NavigationBar"]::after{display:none}
#logo,#logo a{background:transparent!important;color:#fff!important;font-weight:800;text-shadow:0 0 12px rgba(var(--nb-rgb),.8)}
div[class*="NavigationBar"] a,div[class*="NavigationBar"] button{color:#fff!important;background:transparent!important;
  border:3px solid transparent!important;border-radius:6px!important;box-shadow:none!important}
div[class*="NavigationBar"] a:hover,div[class*="NavigationBar"] button:hover{background:var(--nb-field)!important;border-color:var(--nb-line)!important}
div[class*="NavigationBar"] a.active,div[class*="NavigationBar"] a[aria-current="page"]{background:var(--nb-line)!important;color:#02050f!important;
  border-color:var(--nb-soft)!important;box-shadow:3px 3px 0 var(--nb-deep)!important}

/* ===== PANEL : TAB SERVER (SubNavigation) ===== */
div[class*="SubNavigation"]{background:transparent!important;box-shadow:none!important;border:0!important}
div[class*="SubNavigation"] > div{display:flex;gap:.5rem;padding:.8rem .75rem .3rem;overflow-x:auto;scrollbar-width:none}
div[class*="SubNavigation"] a{flex:none;padding:.5rem .9rem!important;margin:0!important;background:var(--nb-card)!important;color:var(--nb-soft)!important;
  font-weight:700;border:3px solid var(--nb-line)!important;border-radius:6px!important;box-shadow:none!important}
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

/* ===== LOGIN (agak ke tengah) ===== */
div:has(> h2):has(form){background:var(--nb-card)!important;border:3px solid var(--nb-line)!important;border-radius:10px!important;
  box-shadow:7px 7px 0 var(--nb-deep),0 0 28px rgba(var(--nb-rgb),.35)!important;width:calc(100% - 2.5rem)!important;max-width:30rem!important;
  margin:max(14vh,2rem) auto 2rem!important;padding:1.5rem 1.25rem!important}
div:has(> h2):has(form) > h2{color:#fff!important;font-weight:800!important;text-transform:uppercase;letter-spacing:.06em;text-align:center;
  padding:0 0 1rem!important;margin-bottom:1.25rem;border-bottom:3px solid var(--nb-line);text-shadow:0 0 14px rgba(var(--nb-rgb),.8)}
div:has(> h2):has(form) form > div{background:transparent!important;border:0!important;box-shadow:none!important;padding:0!important;margin:0!important}
div:has(> h2):has(form) form img{display:block;width:100%!important;max-width:100%!important;height:auto!important;aspect-ratio:16/9;margin:0 0 1.25rem;border:3px solid var(--nb-line);
  border-radius:6px;box-shadow:4px 4px 0 var(--nb-deep),0 0 18px rgba(var(--nb-rgb),.45)}
div:has(> h2):has(form) label{color:var(--nb-muted)!important;font-size:.72rem!important;font-weight:800!important;letter-spacing:.08em;text-transform:uppercase}
div:has(> h2):has(form) form a{color:var(--nb-link)!important;font-weight:700}
div:has(> h2):has(form) > p{border-top:3px solid var(--nb-line);padding-top:1rem;margin-top:1.25rem!important;color:var(--nb-muted)!important}

/* ===== ADMIN (AdminLTE) ===== */
.main-header .logo{display:none!important}
.main-header .navbar,.skin-blue .main-header .navbar{margin-left:0!important;background:var(--nb-card)!important;border-bottom:3px solid var(--nb-line)!important;box-shadow:0 6px 18px -6px rgba(var(--nb-rgb),.55)!important}
.skin-blue .main-header .navbar .nav > li > a,.skin-blue .main-header .navbar .sidebar-toggle{color:#fff!important}
.skin-blue .main-header .navbar .nav > li > a:hover,.skin-blue .main-header .navbar .sidebar-toggle:hover{background:var(--nb-field)!important}
.wrapper,.skin-blue .wrapper,.content-wrapper,.right-side{background:transparent!important;color:#fff!important;border:0!important}
.main-footer{background:var(--nb-card)!important;border:0!important;border-top:3px solid var(--nb-line)!important;color:var(--nb-muted)!important}
.main-sidebar,.skin-blue .main-sidebar{background:var(--nb-card)!important;border-right:3px solid var(--nb-line)!important}
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

/* ===== TIPOGRAFI ===== */
body,input,select,textarea,button,.form-control{font-family:'Inter',system-ui,-apple-system,'Segoe UI',Roboto,sans-serif!important;-webkit-font-smoothing:antialiased}
h1,h2,h3,h4,h5,h6,.box-title,#logo,#logo a,.btn,button[type="submit"],.skin-blue .sidebar-menu > li > a,.table > thead > tr > th,
div:has(> h2):has(form) > h2{font-family:'Space Grotesk','Inter',system-ui,sans-serif!important;letter-spacing:.01em}
code,pre,kbd,samp{font-family:'JetBrains Mono',ui-monospace,Menlo,Consolas,monospace!important}

/* ===== ADMIN : LAYOUT & SPASI ===== */
.content-header{padding:1.25rem 1rem .25rem!important}
.content-header > h1{font-size:1.75rem;line-height:1.2;margin:0}
.content-header > h1 > small{display:block;margin:.35rem 0 0;font-size:.85rem;font-weight:500;line-height:1.4}
.content-wrapper .content-header > .breadcrumb{position:static!important;float:none!important;display:inline-flex;align-items:center;
  margin:.9rem 0 0!important;padding:.35rem .75rem!important;font-size:.78rem;background:var(--nb-card)!important;border-width:2px!important;
  box-shadow:3px 3px 0 var(--nb-deep)!important}
.content-wrapper .content-header > .breadcrumb > li + li:before{content:"\203A";padding:0 .45rem;color:var(--nb-muted)}
.content{padding:1rem!important}
.box{margin-bottom:1.25rem}
.box-header,.box-header.with-border{position:relative;padding:1rem!important}
.box-header .box-title{display:block;font-size:1.05rem;margin:0}
.box-header > .box-tools{position:static!important;float:none!important;display:flex;width:100%;margin:.75rem 0 0!important}
.box-tools form,.box-tools .input-group{display:flex!important;flex:1 1 auto;width:100%!important;float:none!important;gap:.5rem;align-items:stretch}
.box-tools .input-group .form-control{display:block;flex:1 1 auto;min-width:0;width:auto!important;float:none!important;height:auto;padding:.5rem .75rem}
.box-tools .input-group-btn{display:flex!important;width:auto!important;gap:.5rem;white-space:nowrap}
.box-tools .input-group-btn > .btn,.box-tools > .btn{float:none;margin:0!important;border-radius:5px!important;padding:.5rem .85rem}
.table-responsive{border:0!important;box-shadow:none!important;margin:0!important;-webkit-overflow-scrolling:touch}
.table > thead > tr > th,.table > tbody > tr > td{padding:.75rem .85rem!important;vertical-align:middle!important;white-space:nowrap;font-size:.9rem}
.table > thead > tr > th{font-size:.72rem!important;letter-spacing:.08em}
.table > tbody > tr:nth-child(even) > td{background:rgba(var(--nb-rgb),.05)!important}
.table-hover > tbody > tr:hover > td{background:var(--nb-field)!important}
.table code{padding:.15rem .5rem;font-size:.8rem}
.main-footer{padding:1rem 1.25rem!important;font-size:.8rem}
.main-footer a{color:var(--nb-link)!important;font-weight:600}
@media (min-width:768px){
  .content-header{padding:1.5rem 1.5rem .25rem!important}
  .content{padding:1.25rem 1.5rem!important}
  .box-header > .box-tools{position:absolute!important;right:1rem;top:.75rem;width:auto;max-width:440px;margin:0!important}
}
EOF

  if [ -n "$IMG_SRC" ]; then
    SAFE=${IMG_SRC//\"/}
    printf '\n/* GAMBAR LOGIN */\ndiv:has(> h2):has(form) form img{content:url("%s");object-fit:contain}\n' "$SAFE" >> public/themes/nb.css
  fi

  # ---------------- PASANG ----------------
  unlink_theme
  [ -n "$WRAP" ]  && sed -i "/<\/head>/i <link rel=\"stylesheet\" href=\"/themes/nb.css?v=$TS\">" "$WRAP" \
                  && sed -i "/<\/body>/i <script src=\"/themes/nb-stars.js?v=$TS\"></script>" "$WRAP"
  [ -n "$ADMIN" ] && sed -i "/<\/head>/i <link rel=\"stylesheet\" href=\"/themes/nb.css?v=$TS\">" "$ADMIN" \
                  && sed -i "/<\/body>/i <script src=\"/themes/nb-stars.js?v=$TS\"></script>" "$ADMIN"

  if [ "$NEED_BUILD" = "1" ]; then
    echo "Membersihkan tema lama dari bundle (build sekali, tunggu sebentar)..."
    unset NODE_OPTIONS
    yarn run build:production
  fi

  php artisan view:clear
  php artisan cache:clear
  chown -R www-data:www-data public/themes resources/views 2>/dev/null || true
  echo
  echo "SELESAI. Warna: $COLOR ($LINE) | Gambar: ${IMG_SRC:-bawaan}"
  echo "Hard refresh browser. Ganti warna/gambar: pilih [1] lagi."
}

# ---------------- ENTRY ----------------
if [ "$1" = "--reset" ]; then do_uninstall; exit 0; fi
if [ -n "$1" ]; then do_install "$1" "$2"; exit 0; fi

while true; do
  echo
  echo "=== Kruzzy Neo-Brutalism ==="
  echo "[1] Install Theme Neo Brutalism"
  echo "[2] Uninstall tema"
  echo "[3] Kembali"
  read -rp "Pilih [1-3]: " PIL
  case "$PIL" in
    1) do_install "" "" ;;
    2) do_uninstall ;;
    3) echo "Kembali."; exit 0 ;;
    *) echo "Pilihan tidak valid." ;;
  esac
done
