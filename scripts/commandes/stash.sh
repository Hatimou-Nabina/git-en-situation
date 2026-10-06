#!/usr/bin/env bash
# Commandes : git stash.
# Page : src/content/docs/commandes/stash.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'echo "app" > app.js && git add . && git commit -q -m "feat: app" && git push -q'

note "Mettre de côté : les fichiers suivis seulement, sauf -u"
quiet_sh awa 'echo "app en cours" > app.js && echo "brouillon" > notes.txt'
run awa git status --short
run awa git stash
run awa git status --short
run awa git stash pop
run_sh awa 'git stash push -u -m "recherche en cours"'
run awa git status --short

note "Voir ce qui est de côté"
run awa git stash list
run awa git stash show --stat --include-untracked

note "Changer de branche, faire autre chose, revenir, reprendre"
quiet_sh awa 'git switch -q -c fix/urgent && echo "fix" > fix.js && git add . && git commit -q -m "fix: urgence" && git switch -q main'
run awa git stash pop
run awa git status --short

note "Plusieurs remises : apply garde, drop retire"
quiet_sh awa 'git stash push -q -u -m "essai a" && echo "b" > b.js && git stash push -q -u -m "essai b"'
run awa git stash list
run awa git stash apply 'stash@{1}'
run awa git stash list
run awa git stash drop 'stash@{1}'
run awa git stash list

note "Version de Git utilisée"
run awa git --version
