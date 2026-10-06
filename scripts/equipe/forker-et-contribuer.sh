#!/usr/bin/env bash
# Travailler en équipe : forker et contribuer à un projet open source.
# Page : src/content/docs/equipe/forker-et-contribuer.md
#
# Le projet d'origine est le serveur habituel (github.com:equipe/projet.git),
# maintenu par Bakary. Awa n'y a pas le droit d'écrire : son fork est un second
# dépôt nu, github.com:awa/projet.git, et son poste est le dossier « contrib ».
source "$(dirname "$0")/../situations/_lib.sh"
CLEAN_EXTRA=(-e 's#github.com/awa#github.com:awa#g')
setup_team
quiet_sh bakary 'echo "Un outil en ligne de commande." >> README.md && git commit -q -am "docs: decrit le projet" && git push -q'

# Le bouton « Fork » : une copie du dépôt sur le compte d'Awa.
FORK="$SANDBOX/github.com/awa/projet.git"
git clone -q --bare "$SERVER" "$FORK"
git clone -q "$FORK" "$SANDBOX/contrib"
quiet contrib git remote set-url origin ../github.com/awa/projet.git

note "1. Cloner son fork, et ajouter le projet d'origine sous le nom upstream"
run contrib git remote -v
run contrib git remote add upstream ../github.com/equipe/projet.git
run contrib git remote -v
run contrib git fetch upstream

note "2. Une branche par contribution, partie d'upstream/main"
run contrib git switch -c fix/typo-readme upstream/main
quiet_sh contrib 'echo "Un outil en ligne de commande, libre." > README.md && git commit -q -am "docs: corrige la description du README"'
run contrib git push -u origin fix/typo-readme

note "3. Pendant la relecture, le projet avance : se mettre à jour"
quiet_sh bakary 'echo "MIT" > LICENSE && git add LICENSE && git commit -q -m "chore: ajoute la licence" && git push -q'
run contrib git fetch upstream
run contrib git log --oneline HEAD..upstream/main
run contrib git rebase upstream/main
run contrib git push --force-with-lease

note "4. Après la fusion : remettre son fork au niveau du projet"
quiet_sh bakary "git fetch -q $FORK fix/typo-readme && git merge -q --no-ff -m 'Merge pull request #42 from awa/fix/typo-readme' FETCH_HEAD && git push -q"
run contrib git switch main
run contrib git pull --ff-only upstream main
run contrib git push origin main
run contrib git branch -d fix/typo-readme
run contrib git push origin --delete fix/typo-readme
run contrib git log --oneline origin/main..upstream/main

note "Version de Git utilisée"
run contrib git --version
