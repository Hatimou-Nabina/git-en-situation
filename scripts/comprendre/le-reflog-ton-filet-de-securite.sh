#!/usr/bin/env bash
# Comprendre : le reflog, ton filet de sécurité.
# Page : src/content/docs/comprendre/le-reflog-ton-filet-de-securite.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a" && echo "b" > b.js && git add . && git commit -q -m "feat: b"'

note "Chaque mouvement de HEAD laisse une ligne"
run awa git log --oneline
run awa git reflog

note "reset --hard : le commit disparaît de log, pas du reflog"
run awa git reset --hard HEAD~1
run awa git log --oneline
run awa git reflog -3

note "HEAD@{1} n'est pas HEAD~1"
run awa git log --oneline -1 HEAD@{1}
run awa git log --oneline -1 HEAD~1
run awa git reset --hard HEAD@{1}
run awa git log --oneline

note "Une branche supprimée de force : son dernier commit est dans le journal"
quiet_sh awa 'git switch -q -c experimentation && echo "x" > x.js && git add . && git commit -q -m "feat: x" && git switch -q main'
X_SHA=$(cd "$SANDBOX/awa" && git rev-parse --short experimentation)
run awa git branch -D experimentation
run awa git reflog -4
run awa git branch experimentation "$X_SHA"
run awa git log --oneline experimentation -1

note "Chaque branche a son propre journal ; main@{1} et HEAD@{1} diffèrent"
run awa git reflog show main -3
run awa git log --oneline -1 main@{1}
run awa git log --oneline -1 HEAD@{1}

note "Un dépôt fraîchement cloné n'a qu'une ligne : le clone"
run bakary git reflog

note "Ce que le reflog ne contient pas : le travail jamais commité"
run_sh awa 'echo "modif" >> a.js && git status --short'
run awa git reset --hard
run awa git reflog -1
run_sh awa 'cat a.js'

note "Le journal expire, puis le nettoyage emporte ce que plus rien n'atteint"
run awa git branch -D experimentation
run awa git cat-file -t "$X_SHA"
run_sh awa 'git reflog expire --expire=now --all && git gc --prune=now -q'
run awa git cat-file -t "$X_SHA"

note "Version de Git utilisée"
run awa git --version
