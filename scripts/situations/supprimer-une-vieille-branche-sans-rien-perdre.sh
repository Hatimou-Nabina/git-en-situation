#!/usr/bin/env bash
# Situation : supprimer une vieille branche sans rien perdre.
# Page : src/content/docs/situations/quotidien/supprimer-une-vieille-branche-sans-rien-perdre.md
source "$(dirname "$0")/_lib.sh"
setup_team

# refonte-header : fusionnée dans main il y a longtemps, jamais supprimée.
quiet_sh awa 'git switch -q -c refonte-header && echo "header" > header.html && git add . && git commit -q -m "Refait le haut de page" && git push -q -u origin refonte-header && git switch -q main && git merge -q --no-ff -m "Fusionne refonte-header" refonte-header && git push -q origin main'
# experimentation : poussée sur le serveur, avec un commit que main n'a pas.
quiet_sh awa 'git switch -q -c experimentation && echo "essai" > essai.txt && git add . && git commit -q -m "Essai non termine" && git push -q -u origin experimentation && git switch -q main'
# brouillon : locale, jamais poussée, avec un commit que main n'a pas.
quiet_sh awa 'git switch -q -c brouillon && echo "brouillon" > brouillon.txt && git add . && git commit -q -m "Brouillon local" && git switch -q main'

note "État des lieux"
run awa git fetch --prune
run awa git branch -a

exercice awa "trois vieilles branches, refonte-header, experimentation, brouillon. Supprime celles qui ne contiennent rien que main n'ait pas, en local et sur le serveur, et garde les autres."

note "refonte-header a-t-elle des commits que main n'a pas ?"
run awa git log --oneline main..refonte-header
run awa git rev-list --count main..refonte-header
run_sh awa 'git merge-base --is-ancestor refonte-header main && echo "tout est dans main" || echo "des commits manquent dans main"'

note "Toutes les branches déjà contenues dans main, d'un coup"
run awa git branch --merged main
run awa git branch -r --merged origin/main

note "Suppression : sur le serveur, puis en local"
run awa git push origin --delete refonte-header
run awa git branch -d refonte-header

note "Contre-exemple 1 : une branche poussée, avec un commit que main n'a pas"
run awa git rev-list --count main..experimentation
run awa git log --oneline main..experimentation
run awa git branch -d experimentation

note "Contre-exemple 2 : un brouillon local, jamais poussé"
run awa git log --oneline main..brouillon
run awa git branch -d brouillon

note "Garder une trace, puis supprimer pour de bon"
run awa git tag archive/brouillon brouillon
run awa git branch -D brouillon
run awa git log --oneline -1 archive/brouillon

note "Version de Git utilisée"
run awa git --version
