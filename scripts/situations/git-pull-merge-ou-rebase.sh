#!/usr/bin/env bash
# Situation : git pull me demande de choisir entre merge et rebase.
# Page : src/content/docs/situations/git-pull-merge-ou-rebase.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa pousse un commit ; Bakary, sans avoir récupéré, commite de son côté.
quiet_sh awa 'echo "contact" > contact.html && git add . && git commit -q -m "Ajoute la page contact" && git push -q origin main'
quiet_sh bakary 'echo "# Projet EduShare" > README.md && git commit -q -am "Corrige le titre du README"'

note "Bakary récupère les nouveautés"
run bakary git pull

# Deux copies du même état, pour montrer les deux options.
cp -r "$SANDBOX/bakary" "$SANDBOX/bakary-merge"

note "Option 1 : rebase, l'historique reste en ligne droite"
run bakary git pull --rebase
run bakary git log --oneline --graph -4

note "Option 2 : fusion, un commit de merge apparaît"
run bakary-merge git pull --no-rebase
run bakary-merge git log --oneline --graph -4

note "Choisir une fois pour toutes"
run bakary git config --global pull.rebase true
run bakary git config --global --get pull.rebase

note "Version de Git utilisée"
run bakary git --version
