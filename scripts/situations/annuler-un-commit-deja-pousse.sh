#!/usr/bin/env bash
# Situation : annuler un commit déjà poussé.
# Page : src/content/docs/situations/reparer/annuler-un-commit-deja-pousse.md
source "$(dirname "$0")/_lib.sh"
setup_team

quiet_sh awa 'echo "contact" > contact.html && git add . && git commit -q -m "Ajoute la page contact" && git push -q origin main'
quiet_sh awa 'echo "cache" > cache.js && git add . && git commit -q -m "Active le nouveau cache" && git push -q origin main'
quiet bakary git pull

note "Le dernier commit poussé casse la production"
run awa git log --oneline -3

exercice awa "le dernier commit poussé casse la production. Annule-le sans réécrire l'historique du serveur, puis pousse."

note "Ce qu'il ne faut pas faire : revenir en arrière et pousser"
cp -r "$SANDBOX/awa" "$SANDBOX/awa-reset"
run awa-reset git reset --hard HEAD~1
run awa-reset git push

note "Solution : un commit qui annule"
run awa git revert --no-edit HEAD
run awa git log --oneline -3
run awa git ls-files
run awa git push

note "Annuler un commit plus ancien"
run awa git revert --no-edit HEAD~2
run awa git log --oneline -5
run awa git ls-files

note "Version de Git utilisée"
run awa git --version
