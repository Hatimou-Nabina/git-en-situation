#!/usr/bin/env bash
# Travailler en équipe : versions et tags.
# Page : src/content/docs/equipe/versions-et-tags.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Deux changements depuis la version précédente.
quiet_sh awa 'echo "recherche" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche"
echo "export ok" > export.js && git add . && git commit -q -m "fix(export): corrige l export d une liste vide"
git push -q'

note "1. Un tag annoté sur le commit de la version"
run_sh awa 'git tag -a v1.2.0 -m "Version 1.2.0 : barre de recherche, correctif de l export"'
run awa git show --no-patch v1.2.0
run awa git cat-file -t v1.2.0
run awa git tag -n

note "2. Les tags ne partent pas tout seuls"
run awa git push
run awa git ls-remote --tags origin
run awa git push origin v1.2.0
run awa git ls-remote --tags origin

note "3. Où en est-on par rapport à la dernière version ?"
quiet_sh awa 'echo "filtres" > filtres.js && git add . && git commit -q -m "feat(recherche): ajoute les filtres"
echo "tri" > tri.js && git add . && git commit -q -m "feat(recherche): ajoute le tri par date"
git push -q'
run awa git describe --tags
run awa git log --oneline v1.2.0..HEAD

note "4. Dans quelle version ce correctif est-il arrivé ?"
run_sh awa "git log --oneline --all --grep='fix(export)'"
run awa git tag --contains 52ac0b8

note "5. Revenir à une version pour la reconstruire"
run awa git switch --detach v1.2.0
run awa git describe --tags
run awa git switch main

note "6. Chez un collègue, les tags arrivent avec fetch"
run bakary git fetch
run bakary git tag

note "Version de Git utilisée"
run awa git --version
