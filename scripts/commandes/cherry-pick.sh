#!/usr/bin/env bash
# Commandes : git cherry-pick.
# Page : src/content/docs/commandes/cherry-pick.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Une branche de trois commits, dont un correctif urgent ; une seconde branche
# de deux commits ; et un commit qui entrera en conflit avec main.
quiet_sh awa 'git switch -q -c feature/x
echo "x" > x.js && git add . && git commit -q -m "feat(x): ajoute x"
echo "fix" > urgent.js && git add . && git commit -q -m "fix(export): corrige l export d une liste vide"
echo "doc" > x.md && git add . && git commit -q -m "docs(x): documente x"
git switch -q main
git switch -q -c feature/y && echo "y1" > y1.js && git add . && git commit -q -m "feat(y): premiere partie" && echo "y2" > y2.js && git add . && git commit -q -m "feat(y): seconde partie" && git switch -q main
git switch -q -c feature/z && echo "# Projet, version z" > README.md && git commit -q -am "docs(z): titre version z" && git switch -q main
echo "# Projet, version main" > README.md && git commit -q -am "docs: titre version main"'

note "Prendre un commit d'une autre branche"
run awa git log --oneline main..feature/x
run awa git cherry-pick c3806bb
run awa git log --oneline -2

note "Garder la trace de l'origine : -x"
run awa git cherry-pick -x 3f87a68
run_sh awa "git log -1 --format='%B'"

note "Plusieurs commits d'un coup"
run awa git cherry-pick feature/y~2..feature/y
run awa git log --oneline -4

note "Préparer sans commiter : --no-commit"
run awa git cherry-pick --no-commit c3bb537
run awa git status --short
quiet_sh awa 'git commit -q -m "docs(x): documente x, repris de feature/x"'

note "Un conflit"
run awa git cherry-pick feature/z
run awa git status --short
run awa git cherry-pick --abort
run awa git status --short

note "Version de Git utilisée"
run awa git --version
