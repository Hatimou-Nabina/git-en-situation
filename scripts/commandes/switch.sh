#!/usr/bin/env bash
# Commandes : git switch.
# Page : src/content/docs/commandes/switch.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Une branche d'Awa qui modifie le README, et une branche de Bakary sur le serveur.
quiet_sh bakary 'git switch -q -c feature/export && echo "e" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV" && git push -q -u origin feature/export'
quiet_sh awa 'git fetch -q && git switch -q -c feature/recherche && echo "recherche" >> README.md && git commit -q -am "docs: decrit la recherche" && git switch -q main'

note "Changer de branche, en créer une depuis un point de départ"
run awa git switch feature/recherche
run awa git switch -c fix/titre main

note "Revenir à la branche précédente"
run awa git switch -

note "Une branche qui n'existe que sur le serveur"
run awa git switch feature/export

note "Quand des modifications en cours gênent, et quand elles suivent"
quiet_sh awa 'git switch -q main && echo "modif en cours" >> README.md'
run awa git switch feature/recherche
run awa git switch fix/titre
run awa git status --short
quiet awa git restore README.md

note "Se placer sur un commit sans branche : ce que switch refuse, et la bonne façon"
run awa git switch origin/main
run awa git switch --detach origin/main
run awa git switch -

note "Version de Git utilisée"
run awa git --version
