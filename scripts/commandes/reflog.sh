#!/usr/bin/env bash
# Commandes : git reflog.
# Page : src/content/docs/commandes/reflog.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Deux commits sur main, une branche avec un commit, supprimée de force,
# puis un reset --hard qui fait disparaître le second commit de main.
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a" && echo "b" > b.js && git add . && git commit -q -m "feat: b"
git switch -q -c feature/x && echo "x" > x.js && git add . && git commit -q -m "feat: x" && git switch -q main && git branch -q -D feature/x
git reset -q --hard HEAD~1'

note "Tout ce que HEAD a fait, du plus récent au plus ancien"
run awa git log --oneline
run awa git reflog

note "Retrouver un commit après un reset --hard"
run awa git reset --hard 'HEAD@{1}'
run awa git log --oneline

note "Retrouver une branche supprimée"
run awa git branch feature/x ae0fb9e
run awa git log --oneline feature/x -1

note "Le reflog d'une branche, avec les dates"
run awa git reflog show --date=iso main

note "Version de Git utilisée"
run awa git --version
