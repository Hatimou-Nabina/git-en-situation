#!/usr/bin/env bash
# Situation : après un clone, je ne vois pas les branches des autres.
# Page : src/content/docs/situations/quotidien/branches-invisibles-apres-clone.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa a poussé une branche avant que Bakary ne clone.
quiet_sh awa 'git switch -q -c feature/export-pdf && echo "export" > export.js && git add . && git commit -q -m "Ajoute la fonction export PDF" && git push -q -u origin feature/export-pdf && git switch -q main'
rm -rf "$SANDBOX/bakary"
git clone -q "$SERVER" "$SANDBOX/bakary"
quiet bakary git config user.name "Bakary"
quiet bakary git config user.email "bakary@example.com"

note "Bakary vient de cloner : où est la branche d'Awa ?"
run bakary git branch
run bakary git branch -a

exercice bakary "Awa a poussé la branche feature/export-pdf avant ton clone. Retrouve-la et place-toi dessus."

note "Solution : basculer dessus, Git crée la branche locale"
run bakary git switch feature/export-pdf
run bakary git branch -vv

note "Si la branche a été poussée après le clone"
quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche" && git push -q -u origin feature/recherche && git switch -q main'
run bakary git switch feature/recherche
run bakary git fetch
run bakary git switch feature/recherche

note "Version de Git utilisée"
run bakary git --version
