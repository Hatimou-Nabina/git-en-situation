#!/usr/bin/env bash
# Commandes : git restore.
# Page : src/content/docs/commandes/restore.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Un fichier qui a eu trois versions, et un autre fichier.
quiet_sh awa 'echo "v1" > config.js && echo "x" > x.js && git add . && git commit -q -m "feat: v1" && echo "v2" > config.js && git commit -q -am "feat: v2" && echo "v3" > config.js && git commit -q -am "feat: v3" && git push -q'

note "Retirer de l'index, sans toucher au fichier : --staged"
quiet_sh awa 'echo "v4 en cours" > config.js && echo "x modifie" > x.js && git add config.js x.js'
run awa git status --short
run awa git restore --staged x.js
run awa git status --short

note "Jeter une modification du dossier : sans option"
run awa git restore x.js
run awa git status --short
run awa cat x.js

note "Les deux d'un coup : index et dossier"
run awa git restore --staged --worktree config.js
run awa git status --short
run awa cat config.js

note "Reprendre une ancienne version d'un fichier : --source"
run awa git restore --source=HEAD~2 config.js
run awa cat config.js
run awa git status --short
run awa git diff --stat

note "Tout remettre comme au dernier commit"
quiet_sh awa 'echo "x modifie" > x.js'
run awa git status --short
run awa git restore .
run awa git status --short

note "Version de Git utilisée"
run awa git --version
