#!/usr/bin/env bash
# Commandes : git fetch.
# Page : src/content/docs/commandes/fetch.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Awa connaît une branche feature/ancienne. Pendant son absence, Bakary pousse
# un commit sur main, une nouvelle branche, un tag, et supprime l'ancienne.
quiet_sh bakary 'git switch -q -c feature/ancienne && echo "a" > ancienne.js && git add . && git commit -q -m "feat: ancienne branche" && git push -q -u origin feature/ancienne && git switch -q main'
quiet awa git fetch -q
quiet_sh bakary 'echo "contact" > contact.js && git add . && git commit -q -m "feat(contact): ajoute la page contact" && git tag -a v1.0.0 -m "Version 1.0.0" && git push -q && git push -q --tags
git switch -q -c feature/export && echo "export" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV" && git push -q -u origin feature/export
git push -q origin --delete feature/ancienne'

note "Voir ce qui arriverait, sans rien changer"
run awa git fetch --dry-run

note "Récupérer : les branches qui ont bougé, les nouvelles, les tags"
run awa git fetch

note "Ce qui a changé, sans l'avoir intégré"
run awa git status
run awa git log --oneline main..origin/main
run awa git branch -r

note "Les branches supprimées sur le serveur : --prune"
run awa git fetch --prune
run awa git branch -r

note "Pour que ce soit toujours le cas"
run awa git config --global fetch.prune true

note "Version de Git utilisée"
run awa git --version
