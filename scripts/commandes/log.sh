#!/usr/bin/env bash
# Commandes : git log.
# Page : src/content/docs/commandes/log.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Un petit historique : deux commits sur main, une branche de deux commits,
# et un commit d'un collègue arrivé sur le serveur entre-temps.
quiet_sh awa 'echo "demarrage" > app.js && git add . && git commit -q -m "feat(app): premiere version"
echo "demarrage corrige" > app.js && git commit -q -am "fix(app): corrige le demarrage"
git push -q
git switch -q -c feature/recherche
echo "function rechercher() {}" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche"
echo "// cas de la recherche vide" >> recherche.js && git commit -q -am "test(recherche): couvre la recherche vide"'
quiet_sh bakary 'git pull -q && echo "contact" > contact.js && git add . && git commit -q -m "feat(contact): ajoute la page contact" && git push -q'
quiet awa git fetch -q

note "L'historique, une ligne par commit"
run awa git log --oneline -3

note "Ce qu'une branche a et que l'autre n'a pas"
run awa git log --oneline main..feature/recherche
run awa git log --oneline feature/recherche..origin/main
run awa git log --oneline --left-right origin/main...feature/recherche

note "Filtrer : par message, par contenu, par fichier"
run_sh awa "git log --oneline --all --grep='^fix'"
run_sh awa "git log --oneline --all -S'rechercher'"
run awa git log --oneline -- app.js

note "Le détail d'un commit, le format qu'on veut"
run_sh awa "git log -1 --format='%h %an %ad %s' --date=short"
run awa git log -1 -p

note "Le graphe, pour voir les branches"
run awa git log --oneline --graph --decorate --all

note "Version de Git utilisée"
run awa git --version
