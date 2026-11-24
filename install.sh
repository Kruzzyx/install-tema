#!/bin/bash
set -e

cd /var/www/pterodactyl
unset NODE_OPTIONS
mkdir -p public/themes

# ============================================================
#  PANEL (React) - Neo-Brutalism Elegant
#  Ganti warna aksen cukup di --nb-accent
# ============================================================
cat <<'EOF' > resources/scripts/neobrutalism.css
:root {
  --nb-bg: #0b0b0f; --nb-surface: #12131a; --nb-card: #181a23; --nb-inner: #1f2230;
  --nb-ink: #ffffff; --nb-muted: #9aa4b5; --nb-accent: #ffd93d;
  --nb-sh: 5px 5px 0 #ffffff; --nb-sh-sm: 3px 3px 0 #ffffff;
}

html, body, #app {
  background-color: var(--nb-bg) !important;
  background-image: radial-gradient(rgba(255,255,255,.07) 1px, transparent 1px);
  background-size: 22px 22px;
  color: var(--nb-ink) !important; min-height: 100vh;
}
::selection { background: var(--nb-accent); color: #000; }
h1, h2, h3, h4 { font-weight: 800 !important; letter-spacing: .01em; }
::-webkit-scrollbar { width: 10px; height: 10px; }
::-webkit-scrollbar-track { background: var(--nb-bg); }
::-webkit-scrollbar-thumb { background: #fff; border: 2px solid var(--nb-bg); }

/* ---------- NAVBAR : hanya wadah terluar ---------- */
div[class*="NavigationBar"] {
  background: var(--nb-surface) !important;
  border: 0 !important; border-bottom: 3px solid #fff !important;
  border-radius: 0 !important; box-shadow: none !important;
}
div[class*="NavigationBar"] div[class*="NavigationBar"] {
  border: 0 !important; box-shadow: none !important; background: transparent !important;
}
div[class*="NavigationBar"] a, div[class*="NavigationBar"] button {
  color: #fff !important; border: 0 !important; border-radius: 4px !important;
  box-shadow: none !important; font-weight: 700;
}
div[class*="NavigationBar"] a:hover, div[class*="NavigationBar"] button:hover {
  background: var(--nb-inner) !important;
}
div[class*="NavigationBar"] a.active, div[class*="NavigationBar"] a[aria-current="page"] {
  background: var(--nb-accent) !important; color: #000 !important; box-shadow: var(--nb-sh-sm) !important;
}

/* ---------- KARTU SERVER ---------- */
[class*="GreyRowBox"], [class*="ServerRow"] {
  background: var(--nb-card) !important; color: #fff !important;
  border: 3px solid #fff !important; border-radius: 6px !important;
  box-shadow: var(--nb-sh) !important; transition: transform .12s, box-shadow .12s;
}
a[class*="ServerRow"]:hover, a[class*="GreyRowBox"]:hover {
  transform: translate(-2px, -2px); box-shadow: 7px 7px 0 var(--nb-accent) !important;
}
/* reset semua anak supaya tidak jadi kotak bertumpuk */
[class*="GreyRowBox"] *, [class*="ServerRow"] *,
[class*="GreyRowBox"] [class*="GreyRowBox"], [class*="ServerRow"] [class*="ServerRow"] {
  border: 0 !important; box-shadow: none !important; border-radius: 0 !important;
}
[class*="ServerRow"] [class*="rounded-full"], [class*="GreyRowBox"] [class*="rounded-full"] {
  background: var(--nb-accent) !important; color: #000 !important;
  border: 2px solid #fff !important; border-radius: 6px !important;
}
[class*="ServerRow"] [class*="rounded-full"] * { color: #000 !important; }

/* ---------- LOGIN ---------- */
form[class*="LoginFormContainer"] > div, [class*="LoginFormContainer"] form > div {
  background: var(--nb-card) !important; color: #fff !important;
  border: 3px solid #fff !important; border-radius: 6px !important; box-shadow: var(--nb-sh) !important;
}
[class*="LoginFormContainer"] h2 {
  background: transparent !important; color: #fff !important; border: 0 !important;
  text-transform: uppercase; letter-spacing: .04em;
}
[class*="LoginFormContainer"] form div, [class*="LoginFormContainer"] form label,
[class*="LoginFormContainer"] form span, [class*="LoginFormContainer"] form p {
  background: transparent !important; border: 0 !important; box-shadow: none !important;
}
[class*="LoginFormContainer"] form label {
  color: var(--nb-muted) !important; font-weight: 800; letter-spacing: .06em; margin-bottom: .35rem; display: block;
}
[class*="LoginFormContainer"] form a { color: var(--nb-accent) !important; font-weight: 700; }
[class*="LoginFormContainer"] form img { background: transparent !important; border: 0 !important; }

/* ---------- FORM & TOMBOL ---------- */
input:not([type="checkbox"]):not([type="radio"]):not([type="range"]), select, textarea {
  background: var(--nb-surface) !important; color: #fff !important;
  border: 3px solid #fff !important; border-radius: 4px !important; box-shadow: none !important;
}
input:not([type="checkbox"]):not([type="radio"]):not([type="range"]):focus, select:focus, textarea:focus {
  outline: none !important; background: #0d0f16 !important; box-shadow: var(--nb-sh-sm) var(--nb-accent) !important;
  box-shadow: 3px 3px 0 var(--nb-accent) !important;
}
::placeholder { color: var(--nb-muted) !important; }

button[type="submit"], button[class*="Button___"], a[class*="Button___"] {
  background: var(--nb-accent) !important; color: #000 !important;
  border: 3px solid #fff !important; border-radius: 4px !important;
  box-shadow: var(--nb-sh-sm) !important; font-weight: 800 !important;
  text-transform: uppercase; letter-spacing: .05em; transition: transform .1s, box-shadow .1s;
}
button[type="submit"]:hover, button[class*="Button___"]:hover { transform: translate(-1px, -1px); box-shadow: 4px 4px 0 #fff !important; }
button[type="submit"]:active, button[class*="Button___"]:active { transform: translate(3px, 3px); box-shadow: none !important; }

/* ---------- MODAL, FLASH, FOOTER ---------- */
[class*="Modal"] > div, [class*="ContentBox"], [class*="TitledGreyBox"] {
  background: var(--nb-card) !important; border: 3px solid #fff !important;
  border-radius: 6px !important; box-shadow: var(--nb-sh) !important;
}
[class*="MessageBox"] { border: 3px solid #fff !important; border-radius: 6px !important; box-shadow: var(--nb-sh-sm) !important; }
p[class*="Footer"], [class*="Footer"] { color: var(--nb-muted) !important; }

/* ---------- BINTANG JATUH ---------- */
.nb-sky-bg { position: fixed; inset: 0; z-index: 0; pointer-events: none; overflow: hidden; }
.nb-star-streak {
  position: absolute; top: -80px; width: 2px; height: 90px;
  background: linear-gradient(180deg, rgba(255,255,255,0), rgba(255,255,255,.6), #fff);
  box-shadow: 0 0 8px rgba(255,255,255,.7);
  transform: rotate(35deg); opacity: 0; animation: nb-falling-star linear infinite;
}
.nb-star-streak:nth-child(1) { left: 10%; animation-duration: 3.3s; animation-delay: .2s; }
.nb-star-streak:nth-child(2) { left: 28%; animation-duration: 4.1s; animation-delay: 1.3s; height: 70px; }
.nb-star-streak:nth-child(3) { left: 48%; animation-duration: 3.1s; animation-delay: .7s; }
.nb-star-streak:nth-child(4) { left: 68%; animation-duration: 4.4s; animation-delay: 1.9s; height: 105px; }
.nb-star-streak:nth-child(5) { left: 86%; animation-duration: 3.7s; animation-delay: 1.1s; }
@keyframes nb-falling-star {
  0% { transform: translate3d(0,-120px,0) rotate(35deg); opacity: 0; }
  12% { opacity: 1; } 85% { opacity: .85; }
  100% { transform: translate3d(-220px,110vh,0) rotate(35deg); opacity: 0; }
}
@media (prefers-reduced-motion: reduce) { .nb-star-streak { animation: none; display: none; } }
#app > div, main, .wrapper { position: relative; z-index: 1; }
EOF

# ============================================================
#  ADMIN (AdminLTE)
# ============================================================
cat <<'EOF' > public/themes/neobrutalism-admin.css
:root {
  --nb-bg: #0b0b0f; --nb-surface: #12131a; --nb-card: #181a23; --nb-inner: #1f2230;
  --nb-muted: #9aa4b5; --nb-accent: #ffd93d;
}
html, body, .wrapper, .content-wrapper, .right-side, .main-footer {
  background-color: var(--nb-bg) !important; color: #fff !important; border: 0 !important;
}
body, .content-wrapper {
  background-image: radial-gradient(rgba(255,255,255,.07) 1px, transparent 1px); background-size: 22px 22px;
}
.content-wrapper { overflow-x: auto; }
.content-header > h1 { font-weight: 800; color: #fff !important; }
.content-header > h1 > small { color: var(--nb-muted) !important; }
a { color: var(--nb-accent); } a:hover { color: #fff; }
.main-footer { border-top: 3px solid #fff !important; color: var(--nb-muted) !important; }

/* header */
.main-header .navbar, .skin-blue .main-header .navbar, .main-header .logo, .skin-blue .main-header .logo {
  background: var(--nb-surface) !important; color: #fff !important; font-weight: 800;
  border-bottom: 3px solid #fff !important; box-shadow: none !important;
}
.skin-blue .main-header .navbar .nav > li > a, .skin-blue .main-header .navbar .sidebar-toggle { color: #fff !important; }
.skin-blue .main-header .navbar .nav > li > a:hover, .skin-blue .main-header .navbar .sidebar-toggle:hover { background: var(--nb-inner) !important; }

/* sidebar */
.main-sidebar, .skin-blue .main-sidebar, .skin-blue .wrapper { background: var(--nb-surface) !important; border-right: 3px solid #fff !important; }
.skin-blue .sidebar-menu > li.header {
  background: var(--nb-bg) !important; color: var(--nb-muted) !important; font-weight: 800; letter-spacing: .08em;
  border-top: 2px solid rgba(255,255,255,.25); border-bottom: 2px solid rgba(255,255,255,.25);
}
.skin-blue .sidebar-menu > li > a { color: #fff !important; border-left: 4px solid transparent !important; font-weight: 600; }
.skin-blue .sidebar-menu > li:hover > a { background: var(--nb-inner) !important; border-left-color: var(--nb-accent) !important; }
.skin-blue .sidebar-menu > li.active > a {
  background: var(--nb-accent) !important; color: #000 !important; border-left-color: #fff !important; font-weight: 800;
}

/* kartu */
.breadcrumb {
  background: var(--nb-card) !important; border: 3px solid #fff !important; border-radius: 4px !important;
  box-shadow: 3px 3px 0 #fff !important; color: #fff !important;
}
.box, .info-box, .small-box, .nav-tabs-custom, .modal-content, .callout {
  background: var(--nb-card) !important; color: #fff !important; border: 3px solid #fff !important;
  border-radius: 6px !important; box-shadow: 5px 5px 0 #fff !important;
}
.box-header, .box-footer, .modal-header, .modal-footer { background: transparent !important; border-color: rgba(255,255,255,.35) !important; border-width: 2px !important; }
.box-header.with-border { border-bottom: 3px solid #fff !important; }
.box-title { color: #fff !important; font-weight: 800 !important; }
.nav-tabs-custom > .nav-tabs { border-bottom: 3px solid #fff !important; background: var(--nb-surface) !important; }
.nav-tabs-custom > .nav-tabs > li > a { color: #fff !important; font-weight: 700; }
.nav-tabs-custom > .nav-tabs > li.active { border-top-color: var(--nb-accent) !important; }
.nav-tabs-custom > .nav-tabs > li.active > a { background: var(--nb-accent) !important; color: #000 !important; }

/* tabel */
.table, .table > thead > tr > th, .table > tbody > tr > td { color: #fff !important; border-color: rgba(255,255,255,.3) !important; background: transparent !important; }
.table > thead > tr > th { border-bottom: 3px solid #fff !important; font-weight: 800; text-transform: uppercase; font-size: 12px; letter-spacing: .05em; }
.table-hover > tbody > tr:hover > td { background: var(--nb-inner) !important; }
code, pre { background: var(--nb-inner) !important; color: var(--nb-accent) !important; border: 2px solid #fff !important; border-radius: 3px !important; }

/* badge */
.label, .badge { border: 2px solid #fff !important; border-radius: 3px !important; color: #000 !important; font-weight: 800; }
.label-success, .bg-green { background: #5dff9d !important; } .label-danger, .bg-red { background: #ff6b6b !important; }
.label-warning, .bg-yellow { background: var(--nb-accent) !important; } .label-default, .label-info, .bg-aqua { background: #fff !important; }

/* tombol */
.btn {
  background: #fff !important; color: #000 !important; border: 3px solid #000 !important; border-radius: 4px !important;
  box-shadow: 3px 3px 0 #fff !important; font-weight: 800 !important; transition: transform .1s, box-shadow .1s;
}
.btn:hover { transform: translate(-1px, -1px); box-shadow: 4px 4px 0 var(--nb-accent) !important; }
.btn:active { transform: translate(3px, 3px); box-shadow: none !important; }
.btn-primary { background: var(--nb-accent) !important; } .btn-success { background: #5dff9d !important; }
.btn-danger { background: #ff6b6b !important; } .btn-warning { background: #ffb347 !important; }

/* form */
.form-control, select.form-control, textarea.form-control, .input-group-addon, .select2-selection {
  background: var(--nb-surface) !important; color: #fff !important; border: 3px solid #fff !important;
  border-radius: 4px !important; box-shadow: none !important;
}
.form-control:focus { box-shadow: 3px 3px 0 var(--nb-accent) !important; }
.form-control::placeholder { color: var(--nb-muted) !important; }
.help-block, .text-muted { color: var(--nb-muted) !important; }

/* bintang jatuh (admin) */
.nb-sky-bg { position: fixed; inset: 0; z-index: 0; pointer-events: none; overflow: hidden; }
.nb-star-streak {
  position: absolute; top: -80px; width: 2px; height: 90px;
  background: linear-gradient(180deg, rgba(255,255,255,0), rgba(255,255,255,.6), #fff);
  box-shadow: 0 0 8px rgba(255,255,255,.7); transform: rotate(35deg); opacity: 0; animation: nb-falling-star linear infinite;
}
.nb-star-streak:nth-child(1) { left: 10%; animation-duration: 3.3s; animation-delay: .2s; }
.nb-star-streak:nth-child(2) { left: 28%; animation-duration: 4.1s; animation-delay: 1.3s; height: 70px; }
.nb-star-streak:nth-child(3) { left: 48%; animation-duration: 3.1s; animation-delay: .7s; }
.nb-star-streak:nth-child(4) { left: 68%; animation-duration: 4.4s; animation-delay: 1.9s; height: 105px; }
.nb-star-streak:nth-child(5) { left: 86%; animation-duration: 3.7s; animation-delay: 1.1s; }
@keyframes nb-falling-star {
  0% { transform: translate3d(0,-120px,0) rotate(35deg); opacity: 0; }
  12% { opacity: 1; } 85% { opacity: .85; }
  100% { transform: translate3d(-220px,110vh,0) rotate(35deg); opacity: 0; }
}
.wrapper { position: relative; z-index: 1; }
@media (prefers-reduced-motion: reduce) { .nb-star-streak { animation: none; display: none; } }
EOF

# ============================================================
#  Falling stars (panel)
# ============================================================
cat <<'EOF' > resources/scripts/falling-stars.ts
(() => {
  if (typeof document === 'undefined') return;
  const mountStars = () => {
    if (document.getElementById('nb-falling-stars-layer')) return;
    const layer = document.createElement('div');
    layer.id = 'nb-falling-stars-layer';
    layer.className = 'nb-sky-bg';
    for (let i = 0; i < 5; i++) {
      const s = document.createElement('span');
      s.className = 'nb-star-streak';
      layer.appendChild(s);
    }
    document.body.prepend(layer);
  };
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', mountStars, { once: true });
  else mountStars();
})();
EOF

sed -i "/blackpurpleblue\.css/d; /neumorphism\.css/d; /neobrutalism\.css/d; /falling-stars/d" resources/scripts/index.tsx
sed -i "1i import './falling-stars';" resources/scripts/index.tsx
sed -i "1i import './neobrutalism.css';" resources/scripts/index.tsx

# ============================================================
#  Admin layout
# ============================================================
ADMIN_LAYOUT=$(find resources/views -maxdepth 3 -name "admin.blade.php" | head -n 1)
if [ -n "$ADMIN_LAYOUT" ]; then
  sed -i '/neobrutalism-admin\.css/d' "$ADMIN_LAYOUT"
  sed -i "/<\/head>/i <link rel=\"stylesheet\" href=\"/themes/neobrutalism-admin.css?v=$(date +%s)\">" "$ADMIN_LAYOUT"
  grep -q "nb-falling-stars-layer" "$ADMIN_LAYOUT" || sed -i '/<\/body>/i <div id="nb-falling-stars-layer" class="nb-sky-bg"><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><\/div>' "$ADMIN_LAYOUT"
fi

yarn run build:production
php artisan view:clear && php artisan cache:clear
chown -R www-data:www-data /var/www/pterodactyl
systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null || true
echo "SELESAI: Tema Neo-Brutalism Elegant aktif. Refresh dengan hard reload (Ctrl+Shift+R)."
