#!/usr/bin/env bash
# Commandes : git checkout.
# Page : src/content/docs/commandes/checkout.mdx
#
# Chaque forme ancienne est suivie de la commande qui la remplace.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'git switch -q -c feature/x && echo "x" > x.js && git add . && git commit -q -m "feat: x" && git switch -q main && echo "A" >> README.md && git commit -q -am "docs: ajoute A au README"'

note "Changer de branche : checkout, et switch qui le remplace"
run awa git checkout feature/x
run awa git switch main

note "Créer une branche et y aller : -b, et switch -c"
run awa git checkout -b fix/titre
run awa git switch -c fix/titre-2 main

note "Remettre un fichier : checkout -- fichier, et restore"
quiet_sh awa 'echo "modif" >> README.md'
run awa git status --short
run awa git checkout -- README.md
run awa git status --short
quiet_sh awa 'echo "modif" >> README.md'
run awa git restore README.md
run awa git status --short

note "Un ancien contenu : checkout commit -- fichier, et restore --source"
run awa git checkout HEAD~1 -- README.md
run awa git status --short
quiet awa git restore --staged --worktree README.md
run awa git restore --source=HEAD~1 README.md
run awa git status --short
quiet awa git restore README.md

note "Se placer sur un commit : checkout commit, et switch --detach"
run awa git checkout HEAD~1
run awa git switch -

note "Version de Git utilisée"
run awa git --version
