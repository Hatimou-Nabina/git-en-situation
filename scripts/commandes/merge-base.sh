#!/usr/bin/env bash
# Commandes : git merge-base.
# Page : src/content/docs/commandes/merge-base.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a" && git push -q
git switch -q -c feature/x && echo "x1" > x.js && git add . && git commit -q -m "feat(x): premiere partie" && echo "x2" >> x.js && git commit -q -am "feat(x): seconde partie"
git switch -q main && echo "b" > b.js && git add . && git commit -q -m "feat: b"'

note "Le commit d'où la branche est partie"
run awa git log --oneline --graph --all
run awa git merge-base main feature/x

note "Ce que la branche a apporté depuis : commits, puis contenu"
run_sh awa 'git log --oneline $(git merge-base main feature/x)..feature/x'
run_sh awa 'git diff --stat $(git merge-base main feature/x) feature/x'
run awa git diff --stat main...feature/x

note "Est-ce que ce commit est un ancêtre de cette branche ?"
run_sh awa 'git merge-base --is-ancestor origin/main main && echo "oui" || echo "non"'
run_sh awa 'git merge-base --is-ancestor feature/x main && echo "oui" || echo "non"'

note "Version de Git utilisée"
run awa git --version
