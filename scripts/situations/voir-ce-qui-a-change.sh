#!/usr/bin/env bash
# Situation : voir ce qui a changé entre ma branche et main.
# Page : src/content/docs/situations/voir-ce-qui-a-change.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Deux commits sur la branche d'Awa, un commit sur main pendant ce temps.
quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche" && echo "filtre" >> recherche.js && git commit -q -am "Filtre les resultats"'
quiet_sh awa 'git switch -q main && echo "contact" > contact.html && git add . && git commit -q -m "Ajoute la page contact" && git switch -q feature/recherche'

note "Quels commits ma branche a-t-elle que main n'a pas ?"
run awa git log --oneline main..feature/recherche

note "Et l'inverse ?"
run awa git log --oneline feature/recherche..main

note "Les deux côtés d'un coup"
run awa git log --oneline --left-right main...feature/recherche

note "Les fichiers que ma branche a touchés depuis qu'elle a quitté main"
run awa git diff --stat main...feature/recherche

note "Le détail d'un fichier"
run awa git diff main...feature/recherche -- recherche.js

note "Ce que j'ai modifié et pas encore commité"
quiet_sh awa 'echo "tri" >> recherche.js'
run awa git diff --stat
run awa git diff

note "Version de Git utilisée"
run awa git --version
