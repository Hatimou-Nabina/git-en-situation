#!/usr/bin/env bash
# Comprendre : les fichiers de .git/.
# Page : src/content/docs/comprendre/les-fichiers-de-git.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a" && git branch feature/x'

note "Le dossier .git, vue d'ensemble"
run_sh awa 'ls -F .git'

note "HEAD et refs : des noms qui mènent à des commits"
run_sh awa 'cat .git/HEAD'
run_sh awa 'find .git/refs -type f | sort'
run_sh awa 'cat .git/refs/heads/main'

note "config : les serveurs et les liens de suivi"
run_sh awa "git config --local --get-regexp '^(remote|branch)\.'"

note "objects : tout le contenu, rangé par empreinte"
run awa git rev-parse HEAD:a.js
run_sh awa 'ls .git/objects/$(git rev-parse HEAD:a.js | cut -c1-2)/'
run_sh awa 'git cat-file -p $(git rev-parse HEAD:a.js)'
run awa git cat-file -t HEAD
run_sh awa 'find .git/objects -type f | wc -l'

note "index : la liste des fichiers du prochain commit"
run awa git ls-files -s

note "logs : le reflog, un journal par référence"
run_sh awa 'find .git/logs -type f | sort'
run_sh awa 'tail -n 2 .git/logs/HEAD'

note "info/exclude : des règles d'ignorance qui ne quittent pas ce clone"
run_sh awa 'echo "scratch/" >> .git/info/exclude && mkdir -p scratch && echo "x" > scratch/notes.txt && git status --short'
run awa git check-ignore -v scratch/notes.txt

note "Version de Git utilisée"
run awa git --version
