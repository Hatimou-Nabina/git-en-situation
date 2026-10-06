#!/usr/bin/env bash
# Commandes : git remote.
# Page : src/content/docs/commandes/remote.mdx
#
# Un second serveur, github.com:organisation/projet.git, joue le projet
# d'origine d'un fork.
source "$(dirname "$0")/../situations/_lib.sh"
CLEAN_EXTRA=(-e 's#github.com/organisation#github.com:organisation#g')
setup_team
UPSTREAM="$SANDBOX/github.com/organisation/projet.git"
git clone -q --bare "$SERVER" "$UPSTREAM"

note "Les serveurs connus, et leurs adresses"
run awa git remote -v
run awa git remote get-url origin

note "Tout ce que Git sait d'un serveur"
quiet_sh bakary 'git switch -q -c feature/export && echo "export" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV" && git push -q -u origin feature/export && git switch -q main && echo "contact" > contact.js && git add . && git commit -q -m "feat(contact): ajoute la page contact" && git push -q'
run awa git remote show origin

note "Le ménage des branches supprimées sur le serveur"
quiet awa git fetch -q
quiet bakary git push -q origin --delete feature/export
run awa git remote prune --dry-run origin
run awa git remote prune origin

note "Un second serveur : le projet d'origine d'un fork, un miroir"
run awa git remote add upstream "$UPSTREAM"
run awa git fetch upstream
run awa git remote -v
run awa git remote remove upstream
run awa git remote

note "Changer l'adresse : HTTPS vers SSH, ou un autre compte"
run awa git remote set-url origin git@github.com:equipe/projet.git
run awa git remote -v

note "Version de Git utilisée"
run awa git --version
