#!/usr/bin/env bash
# Comprendre : un commit, c'est un instantané.
# Page : src/content/docs/comprendre/un-commit-est-un-instantane.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

quiet_sh awa 'echo "console.log(1)" > app.js && git add . && git commit -q -m "Ajoute l application"'

note "Un commit, vu de l'intérieur"
run awa git log --oneline -2
run awa git cat-file -p HEAD

note "Ce qu'il contient : l'arbre complet du projet, pas une différence"
run awa git cat-file -p 'HEAD^{tree}'
run awa git cat-file -p 'HEAD~1^{tree}'

note "Le même fichier dans deux commits : un seul objet stocké"
run awa git rev-parse HEAD:README.md HEAD~1:README.md

note "La différence entre deux commits est calculée à la demande"
run awa git show --stat --oneline HEAD

note "Changer quoi que ce soit, même le message, c'est un autre commit"
run_sh awa 'git commit --amend -q -m "Ajoute l application (message retouche)"'
run awa git log --oneline -2
run awa git cat-file -p HEAD

note "Version de Git utilisée"
run awa git --version
