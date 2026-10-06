#!/usr/bin/env bash
# Commandes : git commit.
# Page : src/content/docs/commandes/commit.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "Le commit, et ce qu'il répond"
quiet_sh awa 'echo "app" > app.js && git add app.js'
run_sh awa 'git commit -m "feat(app): premiere version"'

note "Rien d'ajouté : commit ne devine pas"
quiet_sh awa 'echo "app v2" > app.js'
run_sh awa 'git commit -m "fix(app): corrige le demarrage"'

note "-a : ajouter les fichiers suivis et commiter d'un coup"
run_sh awa 'git commit -am "fix(app): corrige le demarrage"'

note "Un corps, pour dire pourquoi"
quiet_sh awa 'echo "api" > api.js && git add api.js'
run_sh awa 'git commit -m "feat(api): ajoute le point d entree" -m "Le client mobile en a besoin pour la version 2. Le format est celui de l API publique."'
run_sh awa "git log -1 --format='%B'"

note "Compléter ou corriger le dernier commit : --amend"
quiet_sh awa 'echo "test" > api.test.js && git add api.test.js'
run awa git log --oneline -1
run awa git commit --amend --no-edit
run awa git log --oneline -1
run_sh awa 'git commit --amend -m "feat(api): ajoute le point d entree et son test"'
run_sh awa "git show --stat --format='%h %s' HEAD"

note "Un commit sans changement, pour relancer une CI"
run_sh awa 'git commit --allow-empty -m "chore: relance la CI"'

note "Version de Git utilisée"
run awa git --version
