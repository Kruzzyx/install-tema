#!/bin/bash
set -e

cd /var/www/pterodactyl
unset NODE_OPTIONS
mkdir -p public/themes

cat <<'EOF' > resources/scripts/neobrutalism.css
:root {
  --nb-bg: #0e1017;
  --nb-surface: #171b26;
  --nb-card: #1f2433;
  --nb-border: #050608;
  --nb-text: #f8fafc;
  --nb-muted: #cbd5e1;
  --nb-yellow: #facc15;
  --nb-cyan: #38bdf8;
  --nb-purple: #a855f7;
  --nb-sh: 5px 5px 0px var(--nb-border);
  --nb-sh-lg: 8px 8px 0px var(--nb-border);
  --nb-sh-sm: 3px 3px 0px var(--nb-border);
}

html, body, #app {
  background: var(--nb-bg) !important;
  color: var(--nb-text) !important;
  min-height: 100vh;
}

::selection {
  background: var(--nb-yellow);
  color: var(--nb-border);
}

[class*="LoginFormContainer"] > div,
[class*="login-form-container"] > div,
form[class*="LoginForm"],
#app div[class*="bg-white"],
#app div[class*="bg-neutral-100"],
#app div[class*="bg-gray-100"] {
  background: var(--nb-card) !important;
  color: var(--nb-text) !important;
  border: 3px solid var(--nb-border) !important;
  border-radius: 4px !important;
  box-shadow: var(--nb-sh-lg) !important;
}

#NavigationBar, nav, header, [role="navigation"],
[class*="SubNavigation"], [class*="sub-navigation"] {
  background: var(--nb-surface) !important;
  border-bottom: 3px solid var(--nb-border) !important;
  box-shadow: 0 5px 0px var(--nb-border) !important;
}

#NavigationBar a, #NavigationBar button,
nav a, nav button, header a, header button,
[role="tab"], [role="menuitem"] {
  color: var(--nb-text) !important;
  border: 2px solid transparent !important;
  border-radius: 4px !important;
  font-weight: 700;
  transition: transform .1s ease, background .1s ease, box-shadow .1s ease;
}

#NavigationBar a:hover, #NavigationBar button:hover,
nav a:hover, nav button:hover,
[role="tab"]:hover, [role="menuitem"]:hover {
  background: var(--nb-card) !important;
  border-color: var(--nb-border) !important;
  box-shadow: var(--nb-sh-sm) !important;
  transform: translate(-1px, -1px);
}

#NavigationBar a[aria-current="page"], #NavigationBar a.active,
nav a[aria-current="page"], nav a.active,
[role="tab"][aria-selected="true"], a.active[href*="/server/"] {
  background: var(--nb-yellow) !important;
  color: var(--nb-border) !important;
  border-color: var(--nb-border) !important;
  box-shadow: var(--nb-sh-sm) !important;
}

[class*="ServerRow"], [class*="server-row"],
[class*="GreyRowBox"], [class*="grey-row-box"],
[class*="ContentBox"], [class*="content-box"],
[class*="TitledGreyBox"], [class*="titled-grey-box"],
[class*="StatBlock"], [class*="stat-block"],
[role="dialog"], [class*="Modal"],
.bg-neutral-700, .bg-neutral-800, .bg-neutral-900,
.bg-gray-700, .bg-gray-800, .bg-gray-900,
.bg-zinc-800, .bg-zinc-900, .bg-slate-800, .bg-slate-900 {
  background: var(--nb-card) !important;
  color: var(--nb-text) !important;
  border: 3px solid var(--nb-border) !important;
  border-radius: 4px !important;
  box-shadow: var(--nb-sh) !important;
}

[class*="ServerRow"] [class*="rounded-full"],
[class*="server-row"] [class*="rounded-full"],
[class*="GreyRowBox"] [class*="rounded-full"] {
  background: var(--nb-cyan) !important;
  color: var(--nb-border) !important;
  border: 2px solid var(--nb-border) !important;
  border-radius: 4px !important;
  box-shadow: 2px 2px 0px var(--nb-border) !important;
}

input:not([type="checkbox"]):not([type="radio"]):not([type="range"]),
select, textarea {
  background: var(--nb-bg) !important;
  color: var(--nb-text) !important;
  border: 2px solid var(--nb-border) !important;
  border-radius: 4px !important;
  box-shadow: 3px 3px 0px var(--nb-border) !important;
}

input:not([type="checkbox"]):not([type="radio"]):not([type="range"]):focus,
select:focus, textarea:focus {
  outline: none !important;
  border-color: var(--nb-yellow) !important;
  box-shadow: 4px 4px 0px var(--nb-yellow) !important;
}

::placeholder { color: var(--nb-muted) !important; }

[role="switch"], input[type="checkbox"] {
  accent-color: var(--nb-yellow);
  border: 2px solid var(--nb-border) !important;
  border-radius: 3px !important;
  box-shadow: 2px 2px 0px var(--nb-border) !important;
}

button, a[class*="button"], [role="button"] {
  border: 2px solid var(--nb-border) !important;
  border-radius: 4px !important;
  box-shadow: var(--nb-sh-sm) !important;
  font-weight: 700;
  transition: transform .1s ease, box-shadow .1s ease;
}

button:hover:not(:disabled), a[class*="button"]:hover, [role="button"]:hover {
  transform: translate(-1px, -1px);
  box-shadow: 4px 4px 0px var(--nb-border) !important;
}

button:active:not(:disabled), a[class*="button"]:active, [role="button"]:active {
  transform: translate(2px, 2px);
  box-shadow: 1px 1px 0px var(--nb-border) !important;
}

.nb-sky-bg {
  position: fixed;
  inset: 0;
  z-index: 0;
  pointer-events: none;
  overflow: hidden;
}

.nb-star-streak {
  position: absolute;
  top: -80px;
  width: 2px;
  height: 90px;
  background: linear-gradient(180deg, rgba(250, 204, 21, 0), rgba(56, 189, 248, 0.9), rgba(255, 255, 255, 1));
  box-shadow: 0 0 10px rgba(56, 189, 248, 0.8), 0 0 18px rgba(168, 85, 247, 0.6);
  transform: rotate(35deg);
  opacity: 0;
  animation: nb-falling-star linear infinite;
}

.nb-star-streak:nth-child(1) { left: 8%; animation-duration: 3.2s; animation-delay: 0.1s; }
.nb-star-streak:nth-child(2) { left: 22%; animation-duration: 4.1s; animation-delay: 1.2s; height: 70px; }
.nb-star-streak:nth-child(3) { left: 39%; animation-duration: 3.0s; animation-delay: 0.7s; }
.nb-star-streak:nth-child(4) { left: 57%; animation-duration: 4.5s; animation-delay: 1.9s; height: 110px; }
.nb-star-streak:nth-child(5) { left: 74%; animation-duration: 3.6s; animation-delay: 1.0s; }
.nb-star-streak:nth-child(6) { left: 89%; animation-duration: 3.9s; animation-delay: 2.5s; height: 75px; }

@keyframes nb-falling-star {
  0% { transform: translate3d(0, -120px, 0) rotate(35deg); opacity: 0; }
  12% { opacity: 1; }
  85% { opacity: 0.9; }
  100% { transform: translate3d(-240px, 110vh, 0) rotate(35deg); opacity: 0; }
}

#app > div, main, .wrapper {
  position: relative;
  z-index: 1;
}
EOF

cat <<'EOF' > public/themes/neobrutalism-admin.css
:root {
  --nb-bg: #0e1017;
  --nb-surface: #171b26;
  --nb-card: #1f2433;
  --nb-border: #050608;
  --nb-text: #f8fafc;
  --nb-muted: #cbd5e1;
  --nb-yellow: #facc15;
  --nb-cyan: #38bdf8;
  --nb-purple: #a855f7;
}

body, .wrapper, .content-wrapper, .right-side, .main-footer {
  background: var(--nb-bg) !important;
  color: var(--nb-text) !important;
  border: 0 !important;
}

.main-header .navbar, .skin-blue .main-header .navbar,
.main-header .logo, .skin-blue .main-header .logo {
  background: var(--nb-surface) !important;
  color: var(--nb-yellow) !important;
  border-bottom: 3px solid var(--nb-border) !important;
  border-right: 3px solid var(--nb-border) !important;
  font-weight: 800;
}

.main-sidebar, .skin-blue .main-sidebar, .skin-blue .wrapper {
  background: var(--nb-surface) !important;
  border-right: 3px solid var(--nb-border) !important;
}

.skin-blue .sidebar-menu > li.header {
  background: var(--nb-bg) !important;
  color: var(--nb-yellow) !important;
  font-weight: 800;
  letter-spacing: .06em;
  border-top: 2px solid var(--nb-border);
  border-bottom: 2px solid var(--nb-border);
}

.skin-blue .sidebar-menu > li > a {
  color: var(--nb-text) !important;
  border-left: 4px solid transparent !important;
  font-weight: 600;
}

.skin-blue .sidebar-menu > li:hover > a {
  background: var(--nb-card) !important;
  color: var(--nb-cyan) !important;
  border-left-color: var(--nb-cyan) !important;
}

.skin-blue .sidebar-menu > li.active > a {
  background: var(--nb-yellow) !important;
  color: var(--nb-border) !important;
  border-left-color: var(--nb-border) !important;
  font-weight: 800;
}

.skin-blue .sidebar-menu > li > .treeview-menu {
  background: var(--nb-bg) !important;
}

.skin-blue .treeview-menu > li > a {
  color: var(--nb-muted) !important;
}

.skin-blue .treeview-menu > li.active > a,
.skin-blue .treeview-menu > li > a:hover {
  color: var(--nb-yellow) !important;
  background: var(--nb-card) !important;
}

.content-header > h1, .content-header > h1 > small {
  color: var(--nb-text) !important;
}

.breadcrumb {
  background: var(--nb-card) !important;
  border: 2px solid var(--nb-border) !important;
  border-radius: 4px !important;
  box-shadow: 3px 3px 0px var(--nb-border) !important;
  color: var(--nb-yellow) !important;
}

.breadcrumb > li > a {
  color: var(--nb-cyan) !important;
  font-weight: 700;
}

.box, .info-box, .small-box, .nav-tabs-custom, .modal-content, .callout {
  background: var(--nb-card) !important;
  color: var(--nb-text) !important;
  border: 3px solid var(--nb-border) !important;
  border-top: 4px solid var(--nb-purple) !important;
  border-radius: 4px !important;
  box-shadow: 6px 6px 0px var(--nb-border) !important;
}

.box-header, .box-footer, .modal-header, .modal-footer {
  background: transparent !important;
  border-color: var(--nb-border) !important;
}

.box-title {
  color: var(--nb-yellow) !important;
  font-weight: 800 !important;
}

.table > thead > tr > th,
.table > tbody > tr > td {
  border-color: var(--nb-border) !important;
  color: var(--nb-text) !important;
}

.table-hover > tbody > tr:hover,
.table-striped > tbody > tr:nth-of-type(odd) {
  background: var(--nb-surface) !important;
}

.label, .badge {
  background: var(--nb-cyan) !important;
  color: var(--nb-border) !important;
  border: 2px solid var(--nb-border) !important;
  border-radius: 3px !important;
  font-weight: 800;
}

.btn {
  border: 2px solid var(--nb-border) !important;
  border-radius: 4px !important;
  box-shadow: 4px 4px 0px var(--nb-border) !important;
  font-weight: 800 !important;
  transition: transform .1s ease, box-shadow .1s ease;
}

.btn:hover {
  transform: translate(-1px, -1px);
  box-shadow: 5px 5px 0px var(--nb-border) !important;
}

.btn:active {
  transform: translate(2px, 2px);
  box-shadow: 1px 1px 0px var(--nb-border) !important;
}

.form-control, select.form-control, textarea.form-control,
.input-group-addon, .select2-selection {
  background: var(--nb-bg) !important;
  color: var(--nb-text) !important;
  border: 2px solid var(--nb-border) !important;
  border-radius: 4px !important;
  box-shadow: 3px 3px 0px var(--nb-border) !important;
}
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
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mountStars, { once: true });
  } else {
    mountStars();
  }
})();
EOF

sed -i "/blackpurpleblue\.css/d; /neumorphism\.css/d; /neobrutalism\.css/d; /falling-stars/d" resources/scripts/index.tsx
sed -i "1i import './falling-stars';" resources/scripts/index.tsx
sed -i "1i import './neobrutalism.css';" resources/scripts/index.tsx

ADMIN_LAYOUT=$(find resources/views -maxdepth 3 -name "admin.blade.php" | head -n 1)
if [ -n "$ADMIN_LAYOUT" ]; then
  if ! grep -q "neobrutalism-admin.css" "$ADMIN_LAYOUT"; then
    sed -i '/<\/head>/i <link rel="stylesheet" href="/themes/neobrutalism-admin.css">' "$ADMIN_LAYOUT"
  fi
  if ! grep -q "nb-falling-stars-layer" "$ADMIN_LAYOUT"; then
    sed -i '/<\/body>/i <div id="nb-falling-stars-layer" class="nb-sky-bg"><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><span class="nb-star-streak"><\/span><\/div>' "$ADMIN_LAYOUT"
  fi
fi

yarn run build:production
php artisan view:clear && php artisan cache:clear
chown -R www-data:www-data /var/www/pterodactyl
systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null || true
echo "DONE: Full Neo-Brutalism + Falling Stars aktif."
