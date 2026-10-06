#!/usr/bin/env bash
# Commandes : git revert.
# Page : src/content/docs/commandes/revert.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Trois commits poussés sur main, puis une branche fusionnée avec un commit de merge.
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a" && echo "b" > b.js && git add . && git commit -q -m "feat: b" && echo "c" > c.js && git add . && git commit -q -m "feat: c" && git push -q
git switch -q -c feature/x && echo "x" > x.js && git add . && git commit -q -m "feat: x" && git switch -q main && git merge -q --no-ff -m "Merge branch feature/x" feature/x && git push -q'

note "Annuler un commit par un nouveau commit"
run awa git log --oneline -5
run awa git revert --no-edit 4b99ea3
run awa git log --oneline -2
run_sh awa "git show --stat --format='%B' HEAD"

note "Un commit de merge demande -m"
run awa git revert --no-edit f8d7f52
run awa git revert --no-edit -m 1 f8d7f52
run awa git log --oneline -3

note "Annuler un revert : le revert du revert"
run awa git revert --no-edit HEAD~1
run awa git log --oneline -1
run awa ls

note "L'historique est intact, et le push passe"
run awa git log --oneline -8
run awa git push

note "Version de Git utilisée"
run awa git --version
