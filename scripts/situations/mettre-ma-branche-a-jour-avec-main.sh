#!/usr/bin/env bash
# Situation : mettre ma branche à jour avec main.
# Page : src/content/docs/situations/avec-les-autres/mettre-ma-branche-a-jour-avec-main.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa travaille sur une branche poussée ; pendant ce temps, main avance.
quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche" && echo "filtre" >> recherche.js && git commit -q -am "Filtre les resultats" && git push -q -u origin feature/recherche'
quiet_sh bakary 'echo "contact" > contact.html && git add . && git commit -q -m "Ajoute la page contact" && git push -q origin main'

note "Où en est ma branche par rapport à main ?"
run awa git fetch
run awa git log --oneline --left-right origin/main...feature/recherche

# Deux copies du même état, pour montrer les deux options. Entre les deux, le
# serveur est remis tel qu'il était : chaque option part exactement du même point.
cp -r "$SANDBOX/awa" "$SANDBOX/awa-merge"
BEFORE=$(cd "$SANDBOX/awa" && git rev-parse origin/feature/recherche)

note "Option 1 : rebase, ma branche repart du main à jour"
run awa git rebase origin/main
run awa git log --oneline --graph -4
run awa git push
run awa git push --force-with-lease
run awa git status
AFTER_REBASE=$(cd "$SANDBOX/awa" && git rev-parse HEAD)

note "Option 2 : merge, main entre dans ma branche"
git -C "$SERVER" update-ref refs/heads/feature/recherche "$BEFORE"
run awa-merge git merge origin/main
run awa-merge git log --oneline --graph -5
run awa-merge git push
git -C "$SERVER" update-ref refs/heads/feature/recherche "$AFTER_REBASE"

note "Ce que --force-with-lease empêche"
quiet_sh bakary 'git fetch -q && git switch -q feature/recherche && echo "retouche" >> recherche.js && git commit -q -am "Retouche de Bakary" && git push -q'
quiet_sh awa 'git commit -q --amend -m "Filtre les resultats de recherche"'
run awa git push --force-with-lease
run awa git fetch
run awa git log --oneline feature/recherche..origin/feature/recherche
run awa git cherry-pick origin/feature/recherche
run awa git push --force-with-lease
run awa git log --oneline --graph -5

note "Version de Git utilisée"
run awa git --version
