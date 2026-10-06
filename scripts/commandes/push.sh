#!/usr/bin/env bash
# Commandes : git push.
# Page : src/content/docs/commandes/push.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "Le premier push d'une branche : -u"
quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche"'
run awa git push
run awa git push -u origin feature/recherche

note "Les suivants"
quiet_sh awa 'echo "filtre" >> recherche.js && git commit -q -am "feat(recherche): ajoute le filtre"'
run awa git push

note "Refusé : le serveur a quelque chose que tu n'as pas"
quiet_sh bakary 'git fetch -q && git switch -q feature/recherche && echo "accents" > accents.js && git add . && git commit -q -m "fix(recherche): corrige les accents" && git push -q'
quiet_sh awa 'echo "tri" > tri.js && git add . && git commit -q -m "feat(recherche): ajoute le tri"'
run awa git push
run awa git push --force-with-lease

note "Forcer sa propre branche après l'avoir réécrite : --force-with-lease"
quiet_sh awa 'git pull -q --rebase && git push -q && git commit -q --amend -m "feat(recherche): ajoute le tri par date"'
run awa git push
run awa git push --force-with-lease

note "Supprimer une branche sur le serveur"
run awa git push origin --delete feature/recherche

note "Ne plus taper -u"
run awa git config --global push.autoSetupRemote true

note "Version de Git utilisée"
run awa git --version
