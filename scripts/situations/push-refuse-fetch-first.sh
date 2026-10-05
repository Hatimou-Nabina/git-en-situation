#!/usr/bin/env bash
# Situation : mon push est refusé, « rejected », « fetch first ».
# Page : src/content/docs/situations/push-refuse-fetch-first.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa pousse un commit sur main. Bakary, qui n'a rien récupéré, commite de son côté.
quiet_sh awa 'echo "contact" > contact.html && git add . && git commit -q -m "Ajoute la page contact" && git push -q origin main'
quiet_sh bakary 'echo "# Projet EduShare" > README.md && git commit -q -am "Corrige le titre du README"'

note "Bakary pousse son commit"
run bakary git push

note "Que s'est-il passé ?"
run bakary git fetch
run bakary git status
run bakary git log --oneline main..origin/main
run bakary git log --oneline origin/main..main

note "Ce que donne un git pull sans configuration, avec un Git récent"
run bakary git pull

note "Solution : rejouer son commit par-dessus celui du serveur"
run bakary git rebase origin/main
run bakary git log --oneline -3
run bakary git status
run bakary git push

note "Version de Git utilisée"
run bakary git --version
