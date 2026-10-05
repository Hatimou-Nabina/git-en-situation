#!/usr/bin/env bash
# Travailler en équipe : branche de travail et branche de production.
# Page : src/content/docs/equipe/branche-de-travail-et-de-production.md
#
# Les pull requests fusionnées sur main sont jouées en local, sans affichage.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "1. Créer prod depuis main, une fois"
run awa git switch -c prod
run awa git push -u origin prod
run awa git switch main

note "2. Le travail arrive sur main, par pull request ; prod ne bouge pas"
quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche" && git switch -q main && git merge -q --no-ff -m "Merge pull request #21 from equipe/feature/recherche" feature/recherche && git branch -q -d feature/recherche
git switch -q -c feature/export && echo "export" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV" && git switch -q main && git merge -q --no-ff -m "Merge pull request #22 from equipe/feature/export" feature/export && git branch -q -d feature/export
git push -q'
run awa git log --oneline prod..main

note "3. Mettre en production : prod rejoint main"
run awa git switch prod
run awa git merge --ff-only main
run awa git push
run awa git log --oneline prod..main

note "4. Un correctif urgent en production, pendant que main a déjà avancé"
quiet_sh awa 'git switch -q main && git switch -q -c feature/filtres && echo "filtres" > filtres.js && git add . && git commit -q -m "feat(recherche): ajoute les filtres" && git switch -q main && git merge -q --no-ff -m "Merge pull request #23 from equipe/feature/filtres" feature/filtres && git branch -q -d feature/filtres && git push -q'
run awa git switch prod
run awa git switch -c hotfix/export-vide
quiet_sh awa 'echo "export, liste vide ok" > export.js && git commit -q -am "fix(export): corrige l export d une liste vide"'
run awa git switch prod
run awa git merge --ff-only hotfix/export-vide
run awa git push
quiet awa git branch -q -d hotfix/export-vide

note "5. Reporter le correctif sur main, tout de suite"
run awa git switch main
run awa git log --oneline main..prod
run awa git merge prod
run awa git push
run awa git log --oneline main..prod

note "6. Savoir ce qui est où"
run awa git log --oneline prod..main
run awa git branch -r --contains origin/prod

note "Version de Git utilisée"
run awa git --version
