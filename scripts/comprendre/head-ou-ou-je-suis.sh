#!/usr/bin/env bash
# Comprendre : HEAD, ou « où je suis ».
# Page : src/content/docs/comprendre/head-ou-ou-je-suis.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "HEAD désigne une branche, qui désigne un commit"
run_sh awa 'cat .git/HEAD'
run awa git symbolic-ref HEAD
run awa git rev-parse --abbrev-ref HEAD
run awa git rev-parse --short HEAD

note "Commiter : la branche avance, HEAD suit sans changer"
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a"'
run_sh awa 'cat .git/HEAD'
run_sh awa 'cat .git/refs/heads/main'
run awa git log --oneline -2

note "Changer de branche change HEAD, et rien d'autre"
quiet awa git branch feature/x
run awa git switch feature/x
run_sh awa 'cat .git/HEAD'
run awa git log --oneline -1

note "detached HEAD : HEAD contient un identifiant, pas un nom"
run awa git switch --detach HEAD~1
run_sh awa 'cat .git/HEAD'
run awa git symbolic-ref HEAD
run awa git rev-parse --abbrev-ref HEAD
run awa git status

note "Un commit fait là n'avance aucune branche"
quiet_sh awa 'echo "z" > z.js && git add . && git commit -q -m "feat: z"'
run awa git log --oneline -1
run awa git branch --contains HEAD
run awa git switch main

note "HEAD~1, HEAD^ et HEAD@{1} : trois adresses relatives à HEAD"
run awa git log --oneline -1 HEAD
run awa git log --oneline -1 HEAD~1
run awa git log --oneline -1 HEAD^
run awa git log --oneline -1 HEAD@{1}

note "Version de Git utilisée"
run awa git --version
