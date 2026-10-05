#!/usr/bin/env bash
# Situation : une branche distante a été supprimée, mais je la vois encore.
# Page : src/content/docs/situations/branche-distante-supprimee-encore-visible.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa crée une branche et la pousse ; Bakary la récupère sur son poste.
quiet_sh awa 'git switch -q -c feature/export-pdf && echo "export" > export.js && git add . && git commit -q -m "Ajoute la fonction export PDF" && git push -q -u origin feature/export-pdf'
quiet bakary git fetch
quiet bakary git switch feature/export-pdf
quiet bakary git switch main

# Awa fusionne dans main, puis supprime la branche sur le serveur.
quiet_sh awa 'git switch -q main && git merge -q --no-ff -m "Fusionne feature/export-pdf" feature/export-pdf && git push -q origin main'

note "Côté Awa : la branche est fusionnée, elle la supprime sur le serveur"
run awa git push origin --delete feature/export-pdf

note "Côté Bakary, plus tard : la branche est toujours là"
run bakary git pull
run bakary git branch -a
run bakary git fetch
run bakary git branch -a

note "Solution"
run bakary git fetch --prune
run bakary git branch -a
run bakary git branch -vv
run bakary git branch -d feature/export-pdf

note "Pour ne plus y penser"
run bakary git config --global fetch.prune true
run bakary git config --global --get fetch.prune

note "Version de Git utilisée"
run bakary git --version
