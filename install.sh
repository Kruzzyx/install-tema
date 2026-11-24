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
  --nb-green: #4ade80;
  --nb-red: #f87171;
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

/* Login box */
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
EOF
