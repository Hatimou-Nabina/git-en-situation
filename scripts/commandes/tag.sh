#!/usr/bin/env bash
# Commandes : git tag.
# Page : src/content/docs/commandes/tag.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a" && echo "b" > b.js && git add . && git commit -q -m "fix: b" && echo "c" > c.js && git add . && git commit -q -m "feat: c" && git push -q'

note "Poser un tag annoté, ici et sur un commit plus ancien"
run_sh awa 'git tag -a v1.1.0 -m "Version 1.1.0"'
run_sh awa 'git tag -a v1.0.0 -m "Version 1.0.0" HEAD~2'
run awa git tag
run awa git tag -n
run awa git log --oneline --decorate -3

note "Annoté ou léger"
run awa git tag brouillon
run awa git cat-file -t v1.1.0
run awa git cat-file -t brouillon
run awa git tag -d brouillon

note "Filtrer, trier"
run_sh awa "git tag -l 'v1.1*'"
run awa git tag --sort=-version:refname

note "Envoyer les tags au serveur"
run awa git push origin v1.1.0
run awa git push --tags
run awa git ls-remote --tags origin

note "Supprimer, en local puis sur le serveur"
run awa git tag -d v1.0.0
run awa git push origin --delete v1.0.0
run awa git ls-remote --tags origin

note "Lire un tag"
run awa git show --no-patch v1.1.0
run awa git describe --tags HEAD

note "Version de Git utilisée"
run awa git --version
