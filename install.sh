#!/bin/bash
set -e

cd /var/www/pterodactyl
unset NODE_OPTIONS
mkdir -p public/themes

cat <<'EOF' > resources/scripts/neobrutalism.css
:root {
  --nb-bg: #090a0d; --nb-surface: #12141a; --nb-card: #1a1d26;
  --nb-border: #ffffff; --nb-ink: #000000;
  --nb-text: #ffffff; --nb-muted: #b8c0cc;
  --nb-sh: 5px 5px 0px #ffffff; --nb-sh-lg: 8px 8px 0px #ffffff; --nb-sh-sm: 3px 3px 0px #ffffff;
}
html, body, #app { background: var(--nb-bg) !important; color: var(--nb-text) !important; min-height: 100vh; }
::selection { background: #ffffff; color: #000000; }
[class*="LoginFormContainer"] > div, [class*="login-form-container"] > div, form[class*="LoginForm"],
#app div[class*="bg-white"], #app div[class*="bg-neutral-100"], #app div[class*="bg-gray-100"] {
  background: var(--nb-card) !important; color: var(--nb-text) !important;
  border: 3px solid var(--nb-border) !important; border-radius: 2px !important; box-shadow: var(--nb-sh-lg) !important;
}
#NavigationBar, nav, header, [role="navigation"], [class*="SubNavigation"], [class*="sub-navigation"] {
  background: var(--nb-surface) !important; border-bottom: 3px solid var(--nb-border) !important; box-shadow: 0 5px 0px var(--nb-border) !important;
}
#NavigationBar a, #NavigationBar button, nav a, nav button, header a, header button, [role="tab"], [role="menuitem"] {
  color: var(--nb-text) !important; border: 2px solid transparent !important; border-radius: 2px !important; font-weight: 700;
}
#NavigationBar a:hover, #NavigationBar button:hover, nav a:hover, nav button:hover, [role="tab"]:hover, [role="menuitem"]:hover {
  background: var(--nb-card) !important; border-color: var(--nb-border) !important; box-shadow: var(--nb-sh-sm) !important;
}
#NavigationBar a[aria-current="page"], #NavigationBar a.active, nav a[aria-current="page"], nav a.active,
[role="tab"][aria-selected="true"], a.active[href*="/server/"] {
  background: #ffffff !important; color: #000000 !important; border-color: #ffffff !important; box-shadow: var(--nb-sh-sm) !important;
}
[class*="ServerRow"], [class*="server-row"], [class*="GreyRowBox"], [class*="grey-row-box"],
[class*="ContentBox"], [class*="content-box"], [class*="TitledGreyBox"], [class*="titled-grey-box"],
[class*="StatBlock"], [class*="stat-block"], [role="dialog"], [class*="Modal"],
.bg-neutral-700, .bg-neutral-800, .bg-neutral-900, .bg-gray-700, .bg-gray-800, .bg-gray-900 {
  background: var(--nb-card) !important; color: var(--nb-text) !important;
  border: 3px solid var(--nb-border) !important; border-radius: 2px !important; box-shadow: var(--nb-sh) !important;
}
[class*="ServerRow"] [class*="rounded-full"], [class*="server-row"] [class*="rounded-full"], [class*="GreyRowBox"] [class*="rounded-full"] {
  background: #ffffff !important; color: #000000 !important;
  border: 2px solid #000000 !important; border-radius: 2px !important; box-shadow: 2px 2px 0px #ffffff !important;
}
input:not([type="checkbox"]):not([type="radio"]):not([type="range"]), select, textarea {
  background: var(--nb-bg) !important; color: var(--nb-text) !important;
  border: 2px solid var(--nb-border) !important; border-radius: 2px !important; box-shadow: 3px 3px 0px var(--nb-border) !important;
}
input:not([type="checkbox"]):not([type="radio"]):not([type="range"]):focus, select:focus, textarea:focus {
  outline: none !important; background: #14171f !important; box-shadow: 4px 4px 0px #ffffff !important;
}
::placeholder { color: var(--nb-muted) !important; }
button, a[class*="button"], [role="button"] {
  background: #ffffff !important; color: #000000 !important;
  border: 2px solid #000000 !important; border-radius: 2px !important; box-shadow: 3px 3px 0px #ffffff !important; font-weight: 800;
}
button:hover:not(:disabled), a[class*="button"]:hover, [role="button"]:hover {
  transform: translate(-1px, -1px); box-shadow: 4px 4px 0px #ffffff !important;
}
button:active:not(:disabled), a[class*="button"]:active, [role="button"]:active {
  transform: translate(2px, 2px); box-shadow: 1px 1px 0px #ffffff !important;
}
.nb-sky-bg { position: fixed; inset: 0; z-index: 0; pointer-events: none; overflow: hidden; }
.nb-star-streak {
  position: absolute; top: -80px; width: 2px; height: 95px;
  background: linear-gradient(180deg, rgba(255,255,255,0), rgba(255,255,255,0.65), #ffffff);
  box-shadow: 0 0 8px rgba(255,255,255,0.75);
  transform: rotate(35deg); opacity: 0; animation: nb-falling-star linear infinite;
}
.nb-star-streak:nth-child(1) { left: 8%; animation-duration: 3.2s; animation-delay: 0.1s; }
.nb-star-streak:nth-child(2) { left: 22%; animation-duration: 4.1s; animation-delay: 1.2s; height: 70px; }
.nb-star-streak:nth-child(3) { left: 39%; animation-duration: 3.0s; animation-delay: 0.7s; }
.nb-star-streak:nth-child(4) { left: 57%; animation-duration: 4.5s; animation-delay: 1.9s; height: 110px; }
.nb-star-streak:nth-child(5) { left: 74%; animation-duration: 3.6s; animation-delay: 1.0s; }
.nb-star-streak:nth-child(6) { left: 89%; animation-duration: 3.9s; animation-delay: 2.5s; height: 75px; }
@keyframes nb-falling-star {
  0% { transform: translate3d(0, -120px, 0) rotate(35deg); opacity: 0; }
  12% { opacity: 1; } 85% { opacity: 0.9; }
  100% { transform: translate3d(-240px, 110vh, 0) rotate(35deg); opacity: 0; }
}
#app > div, main, .wrapper { position: relative; z-index: 1; }
EOF

cat <<'EOF' > public/themes/neobrutalism-admin.css
:root { --nb-bg: #090a0d; --nb-surface: #12141a; --nb-card: #1a1d26; --nb-border: #ffffff; --nb-text: #ffffff; --nb-muted: #b8c0cc; }
body, .wrapper, .content-wrapper, .right-side, .main-footer { background: var(--nb-bg) !important; color: var(--nb-text) !important; border: 0 !important; }
.main-header .navbar, .skin-blue .main-header .navbar, .main-header .logo, .skin-blue .main-header .logo { background: var(--nb-surface) !important; color: #ffffff !important; border-bottom: 3px solid #ffffff !important; border-right: 3px solid #ffffff !important; font-weight: 800; }
.main-sidebar, .skin-blue .main-sidebar, .skin-blue .wrapper { background: var(--nb-surface) !important; border-right: 3px solid #ffffff !important; }
.skin-blue .sidebar-menu > li.header { background: var(--nb-bg) !important; color: #ffffff !important; font-weight: 800; border-top: 2px solid #ffffff; border-bottom: 2px solid #ffffff; }
.skin-blue .sidebar-menu > li > a { color: #ffffff !important; border-left: 4px solid transparent !important; font-weight: 700; }
.skin-blue .sidebar-menu > li:hover > a { background: var(--nb-card) !important; color: #ffffff !important; border-left-color: #ffffff !important; }
.skin-blue .sidebar-menu > li.active > a { background: #ffffff !important; color: #000000 !important; border-left-color: #000000 !important; font-weight: 800; }
.breadcrumb { background: var(--nb-card) !important; border: 2px solid #ffffff !important; border-radius: 2px !important; box-shadow: 3px 3px 0px #ffffff !important; color: #ffffff !important; }
.box, .info-box, .small-box, .nav-tabs-custom, .modal-content, .callout { background: var(--nb-card) !important; color: #ffffff !important; border: 3px solid #ffffff !important; border-radius: 2px !important; box-shadow: 6px 6px 0px #ffffff !important; }
.box-title { color: #ffffff !important; font-weight: 800 !important; }
.label, .badge { background: #ffffff !important; color: #000000 !important; border: 2px solid #000000 !important; border-radius: 2px !important; font-weight: 800; }
.btn { background: #ffffff !important; color: #000000 !important; border: 2px solid #000000 !important; border-radius: 2px !important; box-shadow: 4px 4px 0px #ffffff !important; font-weight: 800 !important; }
.form-control, select.form-control, textarea.form-control, .input-group-addon { background: var(--nb-bg) !important; color: #ffffff !important; border: 2px solid #ffffff !important; border-radius: 2px !important; box-shadow: 3px 3px 0px #ffffff !important; }
EOF

cat <<'EOF' > resources/scripts/falling-stars.ts
(() => {
  if (typeof document === 'undefined') return;
  const mountStars = () => {
    if (document.getElementById('nb-falling-stars-layer')) return;
    const layer = document.createElement('div');
    layer.id = 'nb-falling-stars-layer';
    layer.className = 'nb-sky-bg';
    for (let i = 0; i < 6; i++) {
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

ADMIN_LAYOUT=$(find resources/views -maxdepth 3 -name "admin.blade.php" | head -n 1)
if [ -n "$ADMIN_LAYOUT" ]; then
  grep -q "neobrutalism-admin.css" "$ADMIN_LAYOUT" || sed -i '/<\/head>/i <link rel="stylesheet" href="/themes/neobrutalism-admin.css">' "$ADMIN_LAYOUT"
  grep -q "nb-falling-stars-layer" "$ADMIN_LAYOUT" || sed -i '/<\/body>/i <div id="nb-falling-stars-layer" class="nb-sky-bg"><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><\/div>' "$ADMIN_LAYOUT"
fi

yarn run build:production
php artisan view:clear && php artisan cache:clear
chown -R www-data:www-data /var/www/pterodactyl
systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null || true
echo "SELESAI: Tema Neo-Brutalism Black + White aktif."
