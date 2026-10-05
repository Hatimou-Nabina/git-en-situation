#!/usr/bin/env bash
# Situation : ma branche locale est en retard après une fusion sur GitHub.
# Page : src/content/docs/situations/avec-les-autres/branche-locale-en-retard-apres-fusion.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa pousse une branche et ouvre une pull request.
quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche" && git push -q -u origin feature/recherche && git switch -q main'
# « GitHub » fusionne la PR par un commit de merge, puis supprime la branche (Bakary joue GitHub).
quiet_sh bakary 'git fetch -q && git merge -q --no-ff -m "Merge pull request #12 from equipe/feature/recherche" origin/feature/recherche && git push -q origin main && git push -q origin --delete feature/recherche'

note "La PR est fusionnée sur GitHub ; sur mon poste, rien n'a bougé"
run awa git status
run awa git fetch
run awa git status
run awa git branch -vv

note "Solution : avancer main, sans rien créer"
run awa git pull --ff-only
run awa git log --oneline --graph -4

note "Et la branche de travail, maintenant fusionnée"
run awa git fetch --prune
run awa git branch -vv
run awa git branch -d feature/recherche

note "Si --ff-only refuse : main a un commit local"
quiet_sh bakary 'echo "contact" > contact.html && git add . && git commit -q -m "Ajoute la page contact" && git push -q origin main'
quiet_sh awa 'echo "note" > note.txt && git add . && git commit -q -m "Commit local sur main"'
run awa git fetch
run awa git pull --ff-only
run awa git status

note "Version de Git utilisée"
run awa git --version
