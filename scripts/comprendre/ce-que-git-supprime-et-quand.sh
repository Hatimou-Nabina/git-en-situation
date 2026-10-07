#!/usr/bin/env bash
# Comprendre : ce que Git supprime, et quand.
# Page : src/content/docs/comprendre/ce-que-git-supprime-et-quand.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a"'

note "Un fichier retiré du dossier est toujours dans les commits"
run_sh awa 'git rm -q a.js && git commit -q -m "Retire a.js" && git show HEAD~1:a.js'

note "Un commit que plus aucun nom n'atteint reste dans le dépôt"
SHA=$(cd "$SANDBOX/awa" && git rev-parse --short HEAD)
run awa git reset --hard HEAD~1
run awa git log --oneline
run awa git cat-file -t "$SHA"
run awa git log --oneline -1 "$SHA"

note "Ce qui le retient encore : une ligne du reflog"
run awa git reflog -2
run awa git fsck --unreachable
run awa git fsck --unreachable --no-reflogs

note "Quand le journal expire, le nettoyage emporte l'objet"
run_sh awa 'git reflog expire --expire-unreachable=now --all && git gc --prune=now -q'
run awa git cat-file -t "$SHA"

note "Un stash supprimé : plus de nom, mais l'objet est encore là un temps"
run_sh awa 'echo "b" > b.js && git add b.js && git stash push -q -m "brouillon" && git stash list'
STASH_SHA=$(cd "$SANDBOX/awa" && git rev-parse --short stash@{0})
run awa git stash drop
run awa git cat-file -t "$STASH_SHA"
run awa git stash apply "$STASH_SHA"

note "Ce que Git ne supprime jamais de lui-même : tes branches, tes copies du serveur"
quiet_sh bakary 'git switch -q -c feature/ancienne && git commit -q --allow-empty -m "Ancienne branche" && git push -q -u origin feature/ancienne'
quiet awa git fetch -q
quiet bakary git push -q origin --delete feature/ancienne
run awa git branch -r
run awa git fetch --prune
run awa git branch -r

note "Version de Git utilisée"
run awa git --version
