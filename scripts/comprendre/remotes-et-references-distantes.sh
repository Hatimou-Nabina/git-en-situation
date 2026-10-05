#!/usr/bin/env bash
# Comprendre : les remotes et les références distantes.
# Page : src/content/docs/comprendre/remotes-et-references-distantes.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "Un remote, c'est un nom pour une adresse"
run awa git remote -v

note "Trois choses s'appellent main"
run awa git branch -a
run awa git show-ref main
run_sh awa 'git config --get branch.main.remote && git config --get branch.main.merge'

note "Le serveur avance ; ma copie de son état ne bouge pas tant que je ne demande rien"
quiet_sh bakary 'echo "contact" > contact.html && git add . && git commit -q -m "Ajoute la page contact" && git push -q origin main'
run awa git status
run awa git fetch
run awa git status
run awa git log --oneline main..origin/main
run awa git branch -vv

note "origin/main n'est qu'une copie : on ne travaille pas dessus"
run awa git switch origin/main

note "pull, c'est fetch puis intégrer"
run awa git pull --ff-only
run awa git branch -vv

note "push met à jour le serveur et ma copie de son état en même temps"
quiet_sh awa 'echo "a" > a.txt && git add . && git commit -q -m "Ajoute a.txt"'
run awa git branch -vv
run awa git push
run awa git branch -vv

note "Version de Git utilisée"
run awa git --version
