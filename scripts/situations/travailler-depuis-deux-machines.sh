#!/usr/bin/env bash
# Situation : travailler sur le même projet depuis deux machines.
# Page : src/content/docs/situations/avec-les-autres/travailler-depuis-deux-machines.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Deux postes d'Awa : le bureau et la maison, chacun avec sa configuration globale.
mv "$SANDBOX/awa" "$SANDBOX/bureau"
git clone -q "$SERVER" "$SANDBOX/maison"
cp "$GIT_CONFIG_GLOBAL" "$SANDBOX/gitconfig-bureau"
cp "$GIT_CONFIG_GLOBAL" "$SANDBOX/gitconfig-maison"
# run_on <poste> <commande...> : comme run, avec la configuration globale de ce poste.
run_on() { GIT_CONFIG_GLOBAL="$SANDBOX/gitconfig-$1" run "$@"; }

note "Au bureau : un commit, du travail mis de côté, un fichier d'environnement"
quiet_sh bureau 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche" && echo "en cours" > brouillon.txt && git stash push -q -u -m "Brouillon" && echo "SECRET=abc" > .env && echo ".env" > .gitignore && git add .gitignore && git commit -q -m "Ignore le fichier .env"'
run bureau git log --oneline -3
run bureau git stash list
run_sh bureau 'ls -a'

note "À la maison, le soir : rien de tout ça"
run maison git fetch
run maison git branch -a

note "La routine en partant : vérifier ce qui n'est que sur ce poste, puis pousser"
run bureau git status --short --branch
run bureau git log --branches --not --remotes --oneline
run bureau git push -u origin feature/recherche
run bureau git log --branches --not --remotes --oneline

note "La routine en arrivant"
run maison git fetch --prune
run maison git switch feature/recherche
run maison git log --oneline -3
run_sh maison 'ls -a'
run maison git stash list

note "Ce qui ne voyage pas non plus : la configuration de Git"
run_on bureau git config --global pull.rebase true
run_on maison git config --global --get pull.rebase

note "Version de Git utilisée"
run bureau git --version
