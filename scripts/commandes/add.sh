#!/usr/bin/env bash
# Commandes : git add.
# Page : src/content/docs/commandes/add.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Un fichier de vingt lignes, pour avoir deux morceaux séparés à ajouter ; un
# vieux fichier à supprimer.
quiet_sh awa 'for i in $(seq 1 20); do echo "ligne $i"; done > config.js && echo "old" > old.js && git add . && git commit -q -m "feat: config et old" && git push -q'
quiet_sh awa 'echo "a" > a.js && echo "b" > b.js && mkdir -p src && echo "s" > src/s.js
sed -e "1s/.*/ligne 1 modifiee/" -e "20s/.*/ligne 20 modifiee/" config.js > config.tmp && mv config.tmp config.js'

note "Un fichier, un dossier"
run awa git status --short
run awa git add a.js
run awa git add src/
run awa git status --short

note "Voir ce qui serait ajouté, sans le faire"
run awa git add --dry-run .

note "Une partie d'un fichier seulement : -p"
run_sh awa "printf 'y\nn\n' | git add -p config.js"
run awa git diff --stat --staged
run awa git diff --stat

note "Les suppressions aussi"
quiet_sh awa 'rm old.js'
run awa git status --short
run awa git add old.js
run awa git status --short

note "Tout d'un coup : -A"
run awa git add -A
run awa git status --short

note "Un fichier ignoré"
quiet_sh awa 'echo "*.log" > .gitignore && echo "x" > debug.log && git add .gitignore'
run awa git add debug.log

note "Version de Git utilisée"
run awa git --version
