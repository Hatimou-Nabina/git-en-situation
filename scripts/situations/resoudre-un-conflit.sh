#!/usr/bin/env bash
# Situation : un conflit pendant un merge ou un rebase.
# Page : src/content/docs/situations/reparer/resoudre-un-conflit.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa et Bakary modifient tous les deux la première ligne du README.
quiet_sh awa 'printf "# Projet - plateforme de partage\n\nContact : contact@example.com\n" > README.md && git commit -q -am "Ajoute le contact au README" && git push -q origin main'
quiet_sh bakary 'printf "# Projet EduShare\n" > README.md && git commit -q -am "Corrige le titre du README"'

# Trois copies du même état : résoudre, abandonner, et la variante merge.
cp -r "$SANDBOX/bakary" "$SANDBOX/bakary-abort"
cp -r "$SANDBOX/bakary" "$SANDBOX/bakary-merge"

note "Bakary récupère avec rebase et tombe sur un conflit"
run bakary git pull --rebase
run bakary git status
run bakary cat README.md

note "Résoudre : écrire la version voulue, puis continuer"
quiet_sh bakary 'printf "# Projet EduShare\n\nContact : contact@example.com\n" > README.md'
run bakary cat README.md
run bakary git add README.md
run bakary git rebase --continue
run bakary git log --oneline -3

note "Changer d'avis : tout abandonner et revenir à l'état d'avant"
quiet bakary-abort git pull --rebase
run bakary-abort git status --short
run bakary-abort git rebase --abort
run bakary-abort git status
run bakary-abort git log --oneline -2

note "La même chose avec une fusion au lieu d'un rebase"
run bakary-merge git pull --no-rebase
run bakary-merge cat README.md
quiet_sh bakary-merge 'printf "# Projet EduShare\n\nContact : contact@example.com\n" > README.md'
run bakary-merge git add README.md
run bakary-merge git commit --no-edit
run bakary-merge git log --oneline --graph -4

note "Une fois le conflit résolu, le push passe"
run bakary git push

note "Version de Git utilisée"
run bakary git --version
