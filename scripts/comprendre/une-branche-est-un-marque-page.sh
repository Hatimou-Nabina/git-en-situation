#!/usr/bin/env bash
# Comprendre : une branche, c'est un marque-page.
# Page : src/content/docs/comprendre/une-branche-est-un-marque-page.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "HEAD désigne une branche, la branche désigne un commit"
run_sh awa 'cat .git/HEAD'
run_sh awa 'cat .git/refs/heads/main'
run awa git log --oneline -1

note "Créer une branche : écrire le même identifiant dans un nouveau fichier"
run awa git branch feature/recherche
run_sh awa 'cat .git/refs/heads/feature/recherche'
run_sh awa 'ls -R .git/refs/heads'

note "Commiter fait avancer la branche courante, et elle seule"
run awa git switch feature/recherche
run_sh awa 'cat .git/HEAD'
quiet_sh awa 'echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche"'
run_sh awa 'cat .git/refs/heads/feature/recherche'
run_sh awa 'cat .git/refs/heads/main'
run awa git log --oneline --graph --all

note "Quelles branches contiennent ce commit ?"
run awa git branch --contains HEAD
run awa git branch --contains main

note "Supprimer une branche supprime le marque-page, pas le commit"
SHA=$(cd "$SANDBOX/awa" && git rev-parse --short feature/recherche)
run awa git switch main
run awa git branch -D feature/recherche
run_sh awa 'ls -R .git/refs/heads'
run awa git cat-file -t "$SHA"
run awa git log --oneline -1 "$SHA"

note "Version de Git utilisée"
run awa git --version
