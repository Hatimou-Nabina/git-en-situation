#!/usr/bin/env bash
# Commandes : git rm.
# Page : src/content/docs/commandes/rm.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'mkdir -p docs && echo "a" > a.js && echo "c" > c.js && echo "x" > docs/x.md && echo "y" > docs/y.md && echo "API_KEY=secret" > .env && git add . && git commit -q -m "feat: premiere version" && git push -q'

note "Supprimer un fichier suivi : du disque et de l'index d'un coup"
run awa git rm a.js
run awa git status --short

note "Retirer du suivi en gardant le fichier : --cached"
run awa git rm --cached .env
run awa git status --short
run awa ls -a

note "Un dossier entier : -r"
run awa git rm -r docs
run awa git status --short

note "Un fichier modifié : rm refuse, -f force"
quiet_sh awa 'echo "modif" >> c.js'
run awa git rm c.js
run awa git rm -f c.js

note "Revenir en arrière avant le commit"
run awa git restore --staged --worktree a.js
run awa git status --short

note "Version de Git utilisée"
run awa git --version
