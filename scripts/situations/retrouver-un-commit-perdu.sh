#!/usr/bin/env bash
# Situation : retrouver un commit perdu.
# Page : src/content/docs/situations/retrouver-un-commit-perdu.md
source "$(dirname "$0")/_lib.sh"
setup_team

quiet_sh awa 'git switch -q -c experimentation && echo "essai" > essai.txt && git add . && git commit -q -m "Essai prometteur" && git switch -q main'

note "Cas 1 : une branche supprimée avec un commit unique"
run awa git branch -D experimentation
run awa git log --oneline --all

note "Solution : le reflog se souvient de tout ce que HEAD a visité"
run awa git reflog -4
SHA=$(cd "$SANDBOX/awa" && git reflog --format='%h %gs' | awk '/commit: Essai prometteur/ {print $1; exit}')
run awa git branch experimentation "$SHA"
run awa git log --oneline experimentation -1

note "Cas 2 : un reset --hard trop loin"
quiet_sh awa 'echo "a" > matin.txt && git add . && git commit -q -m "Travail du matin" && echo "b" > apres-midi.txt && git add . && git commit -q -m "Travail de l apres-midi"'
run awa git reset --hard HEAD~2
run awa git log --oneline -1
run awa git reflog -3
run awa git reset --hard HEAD@{1}
run awa git log --oneline -3

note "Version de Git utilisée"
run awa git --version
