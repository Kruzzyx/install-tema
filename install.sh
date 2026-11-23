#!/bin/bash
set -e

cd /var/www/pterodactyl
unset NODE_OPTIONS

cat <<'CSS' > resources/scripts/neumorphism.css
:root {
  --neu-bg: #252932;
  --neu-surface: #282c36;
  --neu-light: #323744;
  --neu-dark: #181b21;
  --neu-text: #d6dce8;
  --neu-muted: #939db0;
  --neu-accent: #7aa7ff;
  --neu-accent-soft: rgba(122, 167, 255, 0.18);
  --neu-raised: 8px 8px 18px var(--neu-dark), -7px -7px 16px var(--neu-light);
  --neu-raised-sm: 4px 4px 10px var(--neu-dark), -4px -4px 10px var(--neu-light);
  --neu-inset-sm: inset 3px 3px 6px var(--neu-dark), inset -2px -2px 6px var(--neu-light);
}

html,
body,
#app {
  background: var(--neu-bg) !important;
  color: var(--neu-text) !important;
  min-height: 100vh;
}

::selection {
  background: var(--neu-accent);
  color: #14171f;
}

[class*="LoginFormContainer"] > div,
[class*="login-form-container"] > div,
form[class*="LoginForm"],
#app div[class*="bg-white"],
#app div[class*="bg-neutral-100"],
#app div[class*="bg-gray-100"],
#app div[class*="shadow-md"],
#app div[class*="shadow-lg"] {
  background: var(--neu-surface) !important;
  color: var(--neu-text) !important;
  border: 0 !important;
  border-radius: 20px !important;
  box-shadow: var(--neu-raised) !important;
}

#NavigationBar,
nav,
header,
[role="navigation"] {
  background: var(--neu-surface) !important;
  border: 0 !important;
  box-shadow: 0 6px 14px var(--neu-dark), inset 0 -1px 0 var(--neu-light) !important;
}

#NavigationBar a,
#NavigationBar button,
nav a,
nav button,
header a,
header button {
  color: var(--neu-muted);
  border: 0 !important;
  border-radius: 10px !important;
  transition: background .16s ease, color .16s ease, box-shadow .16s ease, transform .16s ease;
}

#NavigationBar a:hover,
#NavigationBar button:hover,
nav a:hover,
nav button:hover {
  color: var(--neu-text) !important;
  background: var(--neu-surface) !important;
  box-shadow: var(--neu-raised-sm) !important;
}

#NavigationBar a[aria-current="page"],
#NavigationBar a.active,
nav a[aria-current="page"],
nav a.active {
  color: var(--neu-accent) !important;
  background: var(--neu-surface) !important;
  box-shadow: var(--neu-inset-sm) !important;
}

#NavigationBar svg,
nav svg,
header svg,
[class*="ServerRow"] svg,
[class*="server-row"] svg,
[class*="GreyRowBox"] svg {
  filter: drop-shadow(1px 1px 2px var(--neu-dark));
}

[class*="ServerRow"],
[class*="server-row"],
[class*="GreyRowBox"],
[class*="grey-row-box"],
[class*="ContentBox"],
[class*="content-box"],
.bg-neutral-700,
.bg-neutral-800,
.bg-neutral-900,
.bg-gray-700,
.bg-gray-800,
.bg-gray-900 {
  background: var(--neu-surface) !important;
  color: var(--neu-text) !important;
  border: 0 !important;
  border-radius: 14px !important;
  box-shadow: var(--neu-raised) !important;
}

[class*="ServerRow"] [class*="rounded-full"],
[class*="server-row"] [class*="rounded-full"],
[class*="GreyRowBox"] [class*="rounded-full"] {
  background: var(--neu-surface) !important;
  border: 0 !important;
  box-shadow: var(--neu-inset-sm) !important;
  color: var(--neu-accent) !important;
}

input:not([type="checkbox"]):not([type="radio"]):not([type="range"]),
select,
textarea {
  background: var(--neu-surface) !important;
  color: var(--neu-text) !important;
  border: 0 !important;
  border-radius: 10px !important;
  box-shadow: var(--neu-inset-sm) !important;
}

input:not([type="checkbox"]):not([type="radio"]):not([type="range"]):focus,
select:focus,
textarea:focus {
  outline: none !important;
  color: #ffffff !important;
  box-shadow: var(--neu-inset-sm), 0 0 0 2px var(--neu-accent-soft) !important;
}

::placeholder {
  color: var(--neu-muted) !important;
}

[role="switch"],
label:has(input[type="checkbox"]) > span,
[class*="Switch"] {
  background: var(--neu-surface) !important;
  border: 0 !important;
  box-shadow: var(--neu-inset-sm) !important;
}

button,
a[class*="button"],
[role="button"] {
  border: 0 !important;
  border-radius: 10px !important;
  box-shadow: var(--neu-raised-sm);
  transition: box-shadow .15s ease, transform .15s ease, color .15s ease;
}

button[type="submit"],
button[class*="bg-blue"],
button[class*="bg-primary"] {
  background: linear-gradient(145deg, #2e384d, #222836) !important;
  color: var(--neu-accent) !important;
  box-shadow: var(--neu-raised-sm) !important;
}

button:hover:not(:disabled) {
  transform: translateY(-1px);
  color: #ffffff;
}

button:active:not(:disabled) {
  transform: translateY(0);
  box-shadow: var(--neu-inset-sm) !important;
}
CSS

sed -i "/blackpurpleblue\.css/d; /neumorphism\.css/d" resources/scripts/index.tsx
sed -i "1i import './neumorphism.css';" resources/scripts/index.tsx

yarn run build:production
php artisan view:clear && php artisan cache:clear
chown -R www-data:www-data /var/www/pterodactyl
systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null || true
echo "DONE: Neumorphism aktif."
