#!/usr/bin/env bash
# Commandes : git pull.
# Page : src/content/docs/commandes/pull.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "Le cas simple : rien en local, le serveur a avancé"
quiet_sh bakary 'echo "contact" > contact.js && git add . && git commit -q -m "feat(contact): ajoute la page contact" && git push -q'
run awa git pull

note "Les deux côtés ont avancé : pull refuse de deviner"
quiet_sh bakary 'echo "export" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV" && git push -q'
quiet_sh awa 'echo "recherche" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche"'
run awa git pull
run awa git pull --ff-only
run awa git pull --rebase
run awa git log --oneline -3

note "Choisir une fois pour toutes"
run awa git config --global pull.ff only

note "Sans branche de suivi, pull ne sait pas quoi tirer"
run awa git switch -c feature/filtres
run awa git pull

note "Version de Git utilisée"
run awa git --version
