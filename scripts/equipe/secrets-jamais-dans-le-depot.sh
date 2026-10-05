#!/usr/bin/env bash
# Travailler en équipe : les secrets ne vont jamais dans le dépôt.
# Page : src/content/docs/equipe/secrets-jamais-dans-le-depot.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "1. Dès le premier commit : .env ignoré, .env.example versionné"
quiet_sh awa 'printf ".env\n.env.*\n!.env.example\n" > .gitignore
printf "# Copie ce fichier vers .env et remplis les valeurs. Ne commite jamais .env.\nAPI_KEY=\nDATABASE_URL=\n" > .env.example
printf "API_KEY=sk-live-123456\nDATABASE_URL=postgres://app:motdepasse@localhost/app\n" > .env
printf "API_KEY=sk-live-local\n" > .env.local'
run awa cat .gitignore
run awa cat .env.example
run awa git status --short
run awa git check-ignore -v .env .env.local .env.example
quiet_sh awa 'git add . && git commit -q -m "chore: ajoute .env.example et ignore .env" && git push -q'
run awa git ls-files

note "2. L'application lit l'environnement, et le dit clairement quand il manque"
cat > "$SANDBOX/awa/app.sh" <<'EOF'
#!/usr/bin/env bash
# La cle vient de l'environnement, jamais d'un fichier versionne.
: "${API_KEY:?manquante. Copie .env.example vers .env et remplis-le.}"
echo "Connexion avec la cle ${API_KEY:0:8}..."
EOF
run awa cat app.sh
run awa bash app.sh
run_sh awa 'set -a && source .env && set +a && bash app.sh'
quiet_sh awa 'git add app.sh && git commit -q -m "feat: lit la cle d API dans l environnement"'

note "3. Un garde-fou local : refuser le commit d'un .env ou d'une clé"
cat > "$SANDBOX/awa/.git/hooks/pre-commit" <<'EOF'
#!/usr/bin/env bash
# Refuse un commit qui ajoute un fichier .env, ou une ligne qui ressemble a un secret.
fichiers=$(git diff --cached --name-only | grep -E '(^|/)\.env(\.[^/]+)?$' | grep -Ev '\.env\.example$')
if [ -n "$fichiers" ]; then
  echo "Commit refuse : $fichiers ne va pas dans le depot (voir .env.example)." >&2
  exit 1
fi
if git diff --cached -U0 | grep -E '^\+' | grep -Eq 'sk-live-[A-Za-z0-9]+|AKIA[0-9A-Z]{16}|BEGIN( RSA| OPENSSH)? PRIVATE KEY'; then
  echo "Commit refuse : une ligne ajoutee ressemble a un secret." >&2
  exit 1
fi
EOF
chmod +x "$SANDBOX/awa/.git/hooks/pre-commit"
run_sh awa 'cat .git/hooks/pre-commit'
run awa git add -f .env
run_sh awa 'git commit -m "chore: ajoute la config"'
quiet_sh awa 'git reset -q .env'
quiet_sh awa 'printf "const API_KEY = \"sk-live-123456\";\n" > config.js && git add config.js'
run_sh awa 'git commit -m "feat: ajoute la configuration"'
quiet_sh awa 'printf "const API_KEY = process.env.API_KEY;\n" > config.js && git add config.js'
run_sh awa 'git commit -m "feat: lit la configuration dans l environnement"'

note "4. Avant de rendre un dépôt public : chercher dans tout l'historique"
run_sh awa "git log --all --oneline -S'sk-live-'"

note "Version de Git utilisée"
run awa git --version
