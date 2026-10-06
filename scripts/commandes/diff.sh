#!/usr/bin/env bash
# Commandes : git diff.
# Page : src/content/docs/commandes/diff.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Une branche qui ajoute le tri ; pendant ce temps, main reçoit une page contact.
quiet_sh awa 'printf "recherche\nfiltre\n" > recherche.js && echo "page" > page.js && git add . && git commit -q -m "feat: premiere version" && git push -q
git switch -q -c feature/tri && printf "recherche\nfiltre\ntri\n" > recherche.js && git commit -q -am "feat(recherche): ajoute le tri"'
quiet_sh bakary 'git pull -q && echo "contact" > contact.js && git add . && git commit -q -m "feat: ajoute la page contact" && git push -q'
quiet_sh awa 'git fetch -q && git switch -q main && git merge -q --ff-only origin/main && git switch -q feature/tri'

note "Ce que j'ai modifié et pas encore ajouté"
quiet_sh awa 'printf "recherche\nfiltre\ntri par date\n" > recherche.js'
run awa git diff
run awa git diff --stat

note "Ce qui est prêt à être commité"
run awa git add recherche.js
run awa git diff
run awa git diff --staged
run awa git diff --staged --word-diff

note "Entre deux branches : sans points, puis trois points"
run awa git diff --stat main feature/tri
run awa git diff --stat main...feature/tri
run awa git diff --name-status main...feature/tri

note "Un fichier entre deux commits"
run awa git diff HEAD~1 HEAD -- recherche.js

note "Version de Git utilisée"
run awa git --version
