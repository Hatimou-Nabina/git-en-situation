#!/usr/bin/env bash
# Situation : j'ai commité sur la mauvaise branche.
# Page : src/content/docs/situations/reparer/commit-sur-la-mauvaise-branche.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Cas 1 : Awa voulait créer une branche, mais a commité sur main.
quiet_sh awa 'echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche"'

note "Cas 1 : le commit est sur main, pas poussé"
run awa git status
run awa git log --oneline -2

exercice awa "ton dernier commit est sur main alors qu'il devait être sur une branche feature/recherche. Déplace-le, et remets main au niveau du serveur."

note "Solution : poser une branche sur ce commit, puis remettre main où elle était"
run awa git branch feature/recherche
run awa git reset --keep origin/main
run awa git log --oneline -2
run awa git switch feature/recherche
run awa git log --oneline -2

# Cas 2 : un commit destiné à feature/recherche est allé sur feature/export.
quiet_sh awa 'git switch -q main && git switch -q -c feature/export && echo "export" > export.js && git add . && git commit -q -m "Ajoute un export" && echo "tri" > tri.js && git add . && git commit -q -m "Trie les resultats de recherche"'

note "Cas 2 : le commit est allé sur une autre branche de travail"
run awa git log --oneline -3

note "Solution : le copier sur la bonne branche, puis le retirer de la mauvaise"
run awa git switch feature/recherche
run awa git cherry-pick feature/export
run awa git log --oneline -3
run awa git switch feature/export
run awa git reset --keep HEAD~1
run awa git log --oneline -3

note "Version de Git utilisée"
run awa git --version
