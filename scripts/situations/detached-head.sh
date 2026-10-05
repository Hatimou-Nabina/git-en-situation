#!/usr/bin/env bash
# Situation : je suis en « detached HEAD ».
# Page : src/content/docs/situations/reparer/detached-head.md
source "$(dirname "$0")/_lib.sh"
setup_team

quiet_sh awa 'echo "v1" > app.js && git add . && git commit -q -m "Version 1" && git tag v1.0 && echo "v2" > app.js && git commit -q -am "Version 2" && git push -q origin main && git push -q origin v1.0'

note "Awa veut regarder la version 1.0"
run awa git switch v1.0
run awa git switch --detach v1.0
run awa git status
run awa git branch

note "Elle corrige quelque chose et commite, sans y penser"
quiet_sh awa 'echo "v1 corrige" > app.js && git commit -q -am "Corrige la version 1"'
run awa git log --oneline -1
run awa git status

note "Garder ce travail : lui donner une branche"
run awa git switch -c hotfix/v1
run awa git status

note "Si tu es déjà reparti avant de créer la branche"
quiet_sh awa 'git switch -q --detach v1.0 && echo "autre correction" > app.js && git commit -q -am "Autre correction de la version 1"'
run awa git switch main
run awa git branch hotfix/v1-bis HEAD@{1}
run awa git log --oneline -1 hotfix/v1-bis

note "Version de Git utilisée"
run awa git --version
