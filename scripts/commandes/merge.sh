#!/usr/bin/env bash
# Commandes : git merge.
# Page : src/content/docs/commandes/merge.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "Avance rapide : main n'a pas bougé, elle rejoint la branche"
quiet_sh awa 'git switch -q -c feature/a && echo "a" > a.js && git add . && git commit -q -m "feat(a): ajoute a" && git switch -q main'
run awa git merge feature/a

note "Les deux ont avancé : un commit de merge"
quiet_sh awa 'git switch -q -c feature/b && echo "b" > b.js && git add . && git commit -q -m "feat(b): ajoute b" && git switch -q main && echo "contact" > contact.js && git add . && git commit -q -m "feat(contact): ajoute la page contact"'
run awa git merge feature/b
run awa git log --oneline --graph -4

note "Un commit de merge même en avance rapide : --no-ff"
quiet_sh awa 'git switch -q -c feature/c && echo "c" > c.js && git add . && git commit -q -m "feat(c): ajoute c" && git switch -q main'
run awa git merge --no-ff feature/c
run awa git log --oneline -2

note "Rien d'autre que l'avance rapide : --ff-only"
quiet_sh awa 'git switch -q -c feature/d && echo "d" > d.js && git add . && git commit -q -m "feat(d): ajoute d" && echo "d2" >> d.js && git commit -q -am "feat(d): complete d" && git switch -q main && echo "export" > export.js && git add . && git commit -q -m "feat(export): ajoute l export"'
run awa git merge --ff-only feature/d

note "Toute la branche en un seul commit : --squash"
run awa git merge --squash feature/d
run awa git status --short
run_sh awa 'git commit -m "feat(d): ajoute d"'
run awa git log --oneline -3

note "Un conflit, et la sortie de secours"
quiet_sh awa 'git switch -q -c feature/e && echo "# Projet, version e" > README.md && git commit -q -am "docs: titre version e" && git switch -q main && echo "# Projet, version main" > README.md && git commit -q -am "docs: titre version main"'
run awa git merge feature/e
run awa git status --short
run awa git merge --abort
run awa git status --short

note "Version de Git utilisée"
run awa git --version
