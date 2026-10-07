#!/usr/bin/env bash
# Comprendre : l'index, l'étape entre ton dossier et le commit.
# Page : src/content/docs/comprendre/l-index-l-etape-entre-ton-dossier-et-le-commit.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'echo "v1" > config.js && git add . && git commit -q -m "Ajoute la configuration"'

note "Trois endroits : le dossier, l'index, le dernier commit"
run_sh awa 'echo "v2" > config.js && git status --short'
run awa git ls-files -s config.js
run awa git rev-parse HEAD:config.js

note "git add dépose une version dans l'index : un nouvel objet"
run awa git add config.js
run awa git status --short
run awa git ls-files -s config.js
run_sh awa 'git cat-file -p $(git ls-files -s config.js | cut -d" " -f2)'

note "Modifier encore : trois versions, et deux diff"
run_sh awa 'echo "v3" > config.js && git status --short'
run awa git diff
run awa git diff --staged

note "Le commit prend l'index, pas le disque"
run_sh awa 'git commit -m "Passe la configuration en v2"'
run awa git show HEAD:config.js
run_sh awa 'cat config.js'
run awa git status --short

note "Retirer de l'index sans toucher au disque"
run awa git add config.js
run awa git status --short
run awa git restore --staged config.js
run awa git status --short
run_sh awa 'cat config.js'

note "Choisir ce qui entre dans le prochain commit"
run_sh awa 'echo "a" > a.js && echo "b" > b.js && git add a.js && git status --short'
run_sh awa 'git commit -m "Ajoute a"'
run awa git status --short

note "Version de Git utilisée"
run awa git --version
