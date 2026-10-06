#!/usr/bin/env bash
# Commandes : git branch.
# Page : src/content/docs/commandes/branch.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Chez Awa : un correctif déjà fusionné, une branche en cours jamais poussée,
# une autre poussée mais pas fusionnée ; chez Bakary : une branche poussée
# qu'Awa n'a pas encore en local.
quiet_sh awa 'git switch -q -c fix/ancien && echo "x" > x.js && git add . && git commit -q -m "fix: ancien correctif" && git switch -q main && git merge -q --ff-only fix/ancien && git push -q
git switch -q -c feature/recherche && echo "r" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche"
git switch -q main
git switch -q -c feature/poussee && echo "p" > poussee.js && git add . && git commit -q -m "feat(poussee): travail en cours, deja pousse" && git push -q -u origin feature/poussee
git switch -q main'
quiet_sh bakary 'git pull -q && git switch -q -c feature/export && echo "e" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV" && git push -q -u origin feature/export'
quiet awa git fetch -q

note "Lister : les miennes, leur suivi, celles du serveur"
run awa git branch
run awa git branch -vv
run awa git branch -r

note "Créer sans changer de branche, renommer"
run awa git branch feature/filtres
run awa git branch -m feature/filtres feature/filtres-date
run awa git branch

note "Supprimer : -d refuse ce qui n'est pas fusionné"
run awa git branch -d fix/ancien
run awa git branch -d feature/recherche
run awa git branch -d feature/poussee
run awa git branch --merged
run awa git branch --no-merged

note "Le lien avec une branche du serveur"
run awa git branch feature/export origin/feature/export
run awa git branch -vv

note "Qui contient ce commit ?"
run awa git branch -a --contains 02bcbed

note "-D supprime quand même, et le commit reste"
run awa git branch -D feature/recherche
run awa git branch feature/recherche 7fb3039
run awa git branch -vv

note "Version de Git utilisée"
run awa git --version
