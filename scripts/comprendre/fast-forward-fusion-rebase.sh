#!/usr/bin/env bash
# Comprendre : fast-forward, fusion, rebase.
# Page : src/content/docs/comprendre/fast-forward-fusion-rebase.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

quiet_sh awa 'git switch -q -c feature/a && echo "a" > a.txt && git add . && git commit -q -m "Ajoute a" && git switch -q main'

note "Cas 1 : main n'a pas bougé depuis la création de la branche"
run awa git log --oneline --graph --all
run awa git merge feature/a
run awa git log --oneline --graph --all

quiet_sh awa 'git switch -q -c feature/b && echo "b" > b.txt && git add . && git commit -q -m "Ajoute b" && git switch -q main && echo "c" > c.txt && git add . && git commit -q -m "Ajoute c"'
cp -r "$SANDBOX/awa" "$SANDBOX/awa-rebase"

note "Cas 2 : les deux ont avancé"
run awa git log --oneline --graph --all
run awa git merge-base main feature/b

note "Fusion : un commit avec deux parents"
run awa git merge feature/b
run awa git log --oneline --graph --all
run_sh awa "git log --format='%h  parents: %p  %s' -1"

note "Rebase : les commits de la branche rejoués par-dessus main"
run awa-rebase git switch feature/b
run awa-rebase git rebase main
run awa-rebase git log --oneline --graph --all
run awa-rebase git switch main
run awa-rebase git merge feature/b
run awa-rebase git log --oneline --graph --all

note "Forcer un commit de fusion même quand le fast-forward est possible"
quiet_sh awa-rebase 'git switch -q -c feature/d && echo "d" > d.txt && git add . && git commit -q -m "Ajoute d" && git switch -q main'
run awa-rebase git merge --no-ff feature/d
run awa-rebase git log --oneline --graph -4

note "Version de Git utilisée"
run awa git --version
