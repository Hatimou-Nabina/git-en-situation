#!/usr/bin/env bash
# Situation : annuler mon dernier commit, pas encore poussé.
# Page : src/content/docs/situations/reparer/annuler-mon-dernier-commit.md
source "$(dirname "$0")/_lib.sh"
setup_team

quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherhce"'

note "Cas 1 : le message est faux"
run awa git log --oneline -1
run_sh awa 'git commit --amend -m "Ajoute la recherche"'
run awa git log --oneline -1

note "Cas 1 bis : il manque un fichier"
quiet_sh awa 'echo "test" > recherche.test.js'
run awa git add recherche.test.js
run awa git commit --amend --no-edit
run awa git show --stat --oneline HEAD

note "Cas 2 : défaire le commit, garder le travail"
run awa git reset --soft HEAD~1
run awa git status --short
run awa git log --oneline -1
quiet_sh awa 'git commit -q -m "Ajoute la recherche et son test"'

note "Cas 3 : défaire le commit et jeter le travail"
run awa git reset --hard HEAD~1
run awa git status --short
run awa git log --oneline -1

note "Même après --hard, rien n'est perdu tout de suite"
run awa git reflog -3
run awa git reset --hard HEAD@{1}
run awa git log --oneline -1
run awa git ls-files

note "Version de Git utilisée"
run awa git --version
