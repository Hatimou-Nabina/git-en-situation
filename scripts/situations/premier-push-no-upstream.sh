#!/usr/bin/env bash
# Situation : premier push d'une branche, « has no upstream branch ».
# Page : src/content/docs/situations/quotidien/premier-push-no-upstream.md
source "$(dirname "$0")/_lib.sh"
setup_team

quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche"'

note "Awa pousse sa nouvelle branche"
run awa git push

note "Solution"
run awa git push -u origin feature/recherche
run awa git branch -vv

note "Les fois suivantes, git push suffit"
quiet_sh awa 'echo "filtre" >> recherche.js && git commit -q -am "Filtre les resultats"'
run awa git push

note "Pour ne plus jamais avoir à le taper"
run awa git config --global push.autoSetupRemote true
quiet_sh awa 'git switch -q -c feature/export && echo "export" > export.js && git add . && git commit -q -m "Ajoute un export"'
run awa git push

note "Version de Git utilisée"
run awa git --version
