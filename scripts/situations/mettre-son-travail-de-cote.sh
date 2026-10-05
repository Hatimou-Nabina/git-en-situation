#!/usr/bin/env bash
# Situation : mettre mon travail en cours de côté pour changer de branche.
# Page : src/content/docs/situations/mettre-son-travail-de-cote.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa travaille sur une branche : un commit, puis des modifications en cours et un fichier nouveau.
quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche" && echo "filtre en cours" >> recherche.js && echo "notes" > brouillon.txt'

note "Awa a du travail en cours et doit corriger un bug sur main"
run awa git status --short
run awa git switch main

note "Solution : mettre de côté, changer de branche, corriger"
run_sh awa 'git stash push -u -m "Filtre de recherche en cours"'
run awa git status --short
run awa git switch main
quiet_sh awa 'echo "fix" > fix.txt && git add . && git commit -q -m "Corrige le bug de connexion"'

note "Retour au travail en cours"
run awa git switch feature/recherche
run awa git stash list
run awa git stash pop
run awa git status --short

note "Version de Git utilisée"
run awa git --version
