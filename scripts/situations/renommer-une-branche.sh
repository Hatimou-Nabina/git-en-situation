#!/usr/bin/env bash
# Situation : renommer une branche, en local et sur le serveur.
# Page : src/content/docs/situations/renommer-une-branche.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa a poussé une branche avec une faute dans le nom ; Bakary l'a déjà récupérée.
quiet_sh awa 'git switch -q -c feautre/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche" && git push -q -u origin feautre/recherche'
quiet bakary git fetch
quiet bakary git switch feautre/recherche
quiet bakary git switch main

note "Une faute dans le nom, et la branche est déjà sur le serveur"
run awa git branch -vv

note "1. Renommer en local"
run awa git branch -m feautre/recherche feature/recherche
run awa git branch -vv

note "2. Pousser le nouveau nom, supprimer l'ancien sur le serveur"
run awa git push -u origin feature/recherche
run awa git push origin --delete feautre/recherche
run awa git branch -vv

note "Chez un collègue qui avait l'ancienne branche"
run bakary git fetch --prune
run bakary git branch -vv
run bakary git branch -m feautre/recherche feature/recherche
run bakary git branch -u origin/feature/recherche feature/recherche
run bakary git branch -vv

note "Version de Git utilisée"
run bakary git --version
