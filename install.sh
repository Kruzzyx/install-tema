#!/bin/bash
set -e

cd /var/www/pterodactyl
unset NODE_OPTIONS
mkdir -p public/themes

cat <<'EOF' > resources/scripts/neobrutalism.css
:root {
  --nb-bg: #090a0d; --nb-surface: #11131a; --nb-card: #171a24;
  --nb-border: #ffffff; --nb-text: #ffffff; --nb-muted: #a8b2c2;
  --nb-sh: 4px 4px 0px #ffffff; --nb-sh-sm: 2px 2px 0px #ffffff;
}
html, body, #app { background: var(--nb-bg) !important; color: var(--nb-text) !important; min-height: 100vh; }
::selection { background: #ffffff; color: #000000; }

[class*="LoginFormContainer"] > div > div,
form[class*="LoginForm"] {
  background: var(--nb-card) !important; color: var(--nb-text) !important;
  border: 2px solid var(--nb-border) !important; border-radius: 4px !important; box-shadow: var(--nb-sh) !important;
}
[class*="LoginFormContainer"] label,
[class*="LoginFormContainer"] span,
form[class*="LoginForm"] label,
form[class*="LoginForm"] span {
  background: transparent !important; border: 0 !important; box-shadow: none !important;
}

#NavigationBar, nav, header, [role="navigation"] {
  background: var(--nb-surface) !important; border-bottom: 2px solid var(--nb-border) !important; box-shadow: none !important;
}
#NavigationBar a, #NavigationBar button, nav a, nav button {
  color: var(--nb-text) !important; border: 0 !important; border-radius: 3px !important; box-shadow: none !important; font-weight: 700;
}
#NavigationBar a:hover, #NavigationBar button:hover, nav a:hover, nav button:hover {
  background: var(--nb-card) !important;
}
#NavigationBar a[aria-current="page"], #NavigationBar a.active, nav a[aria-current="page"], nav a.active {
  background: #ffffff !important; color: #000000 !important;
}

[class*="ServerRow"], [class*="server-row"], [class*="GreyRowBox"], [class*="grey-row-box"] {
  background: var(--nb-card) !important; color: var(--nb-text) !important;
  border: 2px solid var(--nb-border) !important; border-radius: 4px !important; box-shadow: var(--nb-sh) !important;
}
[class*="ServerRow"] *, [class*="server-row"] *, [class*="GreyRowBox"] * {
  box-shadow: none !important;
}
[class*="ServerRow"] [class*="rounded-full"], [class*="server-row"] [class*="rounded-full"] {
  background: #232838 !important; color: #ffffff !important; border: 1.5px solid #ffffff !important; border-radius: 4px !important;
}

input:not([type="checkbox"]):not([type="radio"]):not([type="range"]), select, textarea {
  background: var(--nb-surface) !important; color: #ffffff !important;
  border: 2px solid var(--nb-border) !important; border-radius: 3px !important; box-shadow: none !important;
}
input:not([type="checkbox"]):not([type="radio"]):not([type="range"]):focus, select:focus, textarea:focus {
  outline: none !important; background: #0d0f16 !important; box-shadow: var(--nb-sh-sm) !important;
}
::placeholder { color: var(--nb-muted) !important; }
button[type="submit"], a[class*="button"] {
  background: #ffffff !important; color: #000000 !important;
  border: 2px solid #000000 !important; border-radius: 3px !important; box-shadow: var(--nb-sh-sm) !important; font-weight: 800;
}
button[type="submit"]:active, a[class*="button"]:active {
  transform: translate(2px, 2px); box-shadow: none !important;
}

.nb-sky-bg { position: fixed; inset: 0; z-index: 0; pointer-events: none; overflow: hidden; }
.nb-star-streak {
  position: absolute; top: -80px; width: 2px; height: 90px;
  background: linear-gradient(180deg, rgba(255,255,255,0), rgba(255,255,255,0.6), #ffffff);
  box-shadow: 0 0 8px rgba(255,255,255,0.7);
  transform: rotate(35deg); opacity: 0; animation: nb-falling-star linear infinite;
}
.nb-star-streak:nth-child(1) { left: 10%; animation-duration: 3.3s; animation-delay: 0.2s; }
.nb-star-streak:nth-child(2) { left: 28%; animation-duration: 4.1s; animation-delay: 1.3s; height: 70px; }
.nb-star-streak:nth-child(3) { left: 48%; animation-duration: 3.1s; animation-delay: 0.7s; }
.nb-star-streak:nth-child(4) { left: 68%; animation-duration: 4.4s; animation-delay: 1.9s; height: 105px; }
.nb-star-streak:nth-child(5) { left: 86%; animation-duration: 3.7s; animation-delay: 1.1s; }
@keyframes nb-falling-star {
  0% { transform: translate3d(0, -120px, 0) rotate(35deg); opacity: 0; }
  12% { opacity: 1; } 85% { opacity: 0.85; }
  100% { transform: translate3d(-220px, 110vh, 0) rotate(35deg); opacity: 0; }
}
#app > div, main, .wrapper { position: relative; z-index: 1; }
EOF

cat <<'EOF' > public/themes/neobrutalism-admin.css
:root { --nb-bg: #090a0d; --nb-surface: #11131a; --nb-card: #171a24; --nb-border: #ffffff; --nb-text: #ffffff; --nb-muted: #a8b2c2; }
body, .wrapper, .content-wrapper, .right-side, .main-footer { background: var(--nb-bg) !important; color: var(--nb-text) !important; border: 0 !important; }
.main-header .navbar, .skin-blue .main-header .navbar, .main-header .logo, .skin-blue .main-header .logo { background: var(--nb-surface) !important; color: #ffffff !important; border-bottom: 2px solid #ffffff !important; border-right: 2px solid #ffffff !important; font-weight: 800; }
.main-sidebar, .skin-blue .main-sidebar, .skin-blue .wrapper { background: var(--nb-surface) !important; border-right: 2px solid #ffffff !important; }
.skin-blue .sidebar-menu > li.header { background: var(--nb-bg) !important; color: #a8b2c2 !important; font-weight: 700; border-top: 1px solid rgba(255,255,255,0.2); border-bottom: 1px solid rgba(255,255,255,0.2); }
.skin-blue .sidebar-menu > li > a { color: #ffffff !important; border-left: 3px solid transparent !important; font-weight: 600; }
.skin-blue .sidebar-menu > li:hover > a { background: var(--nb-card) !important; }
.skin-blue .sidebar-menu > li.active > a { background: #ffffff !important; color: #000000 !important; border-left-color: #000000 !important; font-weight: 800; }
.breadcrumb { background: var(--nb-card) !important; border: 2px solid #ffffff !important; border-radius: 3px !important; box-shadow: 2px 2px 0px #ffffff !important; color: #ffffff !important; }
.box, .info-box, .small-box, .nav-tabs-custom, .modal-content, .callout { background: var(--nb-card) !important; color: #ffffff !important; border: 2px solid #ffffff !important; border-radius: 4px !important; box-shadow: 4px 4px 0px #ffffff !important; }
.box-title { color: #ffffff !important; font-weight: 800 !important; }
.btn { background: #ffffff !important; color: #000000 !important; border: 2px solid #000000 !important; border-radius: 3px !important; box-shadow: 2px 2px 0px #ffffff !important; font-weight: 800 !important; }
.btn:active { transform: translate(2px, 2px); box-shadow: none !important; }
.form-control, select.form-control, textarea.form-control, .input-group-addon { background: var(--nb-surface) !important; color: #ffffff !important; border: 2px solid #ffffff !important; border-radius: 3px !important; box-shadow: none !important; }
EOF

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

ADMIN_LAYOUT=$(find resources/views -maxdepth 3 -name "admin.blade.php" | head -n 1)
if [ -n "$ADMIN_LAYOUT" ]; then
  grep -q "neobrutalism-admin.css" "$ADMIN_LAYOUT" || sed -i '/<\/head>/i <link rel="stylesheet" href="/themes/neobrutalism-admin.css">' "$ADMIN_LAYOUT"
  grep -q "nb-falling-stars-layer" "$ADMIN_LAYOUT" || sed -i '/<\/body>/i <div id="nb-falling-stars-layer" class="nb-sky-bg"><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><\/div>' "$ADMIN_LAYOUT"
fi

yarn run build:production
php artisan view:clear && php artisan cache:clear
chown -R www-data:www-data /var/www/pterodactyl
systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null || true
echo "SELESAI: Tema Neo-Brutalism Black + White rapi aktif."
