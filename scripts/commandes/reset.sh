#!/usr/bin/env bash
# Commandes : git reset.
# Page : src/content/docs/commandes/reset.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Trois commits sur main ; seul le premier est poussé.
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a" && git push -q
echo "b" > b.js && git add . && git commit -q -m "feat: b"
echo "c" > c.js && git add . && git commit -q -m "feat: c"'

note "Défaire le dernier commit en gardant tout dans l'index : --soft"
run awa git log --oneline -3
run awa git reset --soft HEAD~1
run awa git status --short
run awa git log --oneline -2

note "Défaire le commit et le git add, garder les fichiers : sans option"
quiet_sh awa 'git commit -q -m "feat: c"'
run awa git reset HEAD~1
run awa git status --short

note "Tout jeter : --hard, et le filet du reflog"
quiet_sh awa 'git add . && git commit -q -m "feat: c"'
run awa git reset --hard HEAD~1
run awa git status --short
run awa git log --oneline -2
run awa git reflog -3
run awa git reset --hard 'HEAD@{1}'
run awa git log --oneline -3

note "Déplacer la branche sans perdre le travail en cours : --keep"
quiet_sh awa 'echo "a modifie" > a.js'
run awa git branch feature/b-et-c
run awa git reset --keep origin/main
run awa git status --short
run awa git log --oneline -1
run awa git log --oneline feature/b-et-c -3

note "Retirer un fichier de l'index, à l'ancienne"
quiet awa git add a.js
run awa git reset a.js
run awa git status --short

note "Version de Git utilisée"
run awa git --version
