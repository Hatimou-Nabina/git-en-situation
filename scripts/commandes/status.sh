#!/usr/bin/env bash
# Commandes : git status.
# Page : src/content/docs/commandes/status.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "Rien à signaler"
run awa git status

note "Trois états : non suivi, modifié, prêt à être commité"
quiet_sh awa 'echo "notes" > notes.txt && echo "# Projet modifie" > README.md && echo "app" > app.js && git add app.js'
run awa git status
run awa git status --short

note "Un même fichier dans deux états"
quiet_sh awa 'echo "app v2" > app.js'
run awa git status --short

note "L'avance et le retard sur le serveur"
quiet_sh awa 'git add . && git commit -q -m "feat: ajoute app et notes"'
quiet_sh bakary 'printf "# Projet\nContact\n" > README.md && echo "contact" > contact.js && git add . && git commit -q -m "feat: ajoute la page contact" && git push -q'
quiet awa git fetch -q
run awa git status -sb
run awa git status

note "Pendant un conflit"
quiet awa git merge origin/main
run awa git status
quiet awa git merge --abort

note "Les fichiers ignorés"
quiet_sh awa 'echo "*.log" > .gitignore && echo "x" > debug.log'
run awa git status --short
run awa git status --short --ignored

note "Version de Git utilisée"
run awa git --version
