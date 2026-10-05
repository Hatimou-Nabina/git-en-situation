#!/usr/bin/env bash
# Travailler en équipe : la pull request, de l'ouverture à la fusion.
# Page : src/content/docs/equipe/la-pull-request.md
#
# La partie Git est jouée dans le bac à sable ; la fusion « par GitHub » est
# jouée par un second poste. La dernière section interroge GitHub pour de
# vrai, avec gh, sur les pull requests de ce site : elle est sautée si gh est
# absent ou non connecté.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "1. Partir d'un main à jour, sur une branche au nom parlant"
run awa git switch main
run awa git pull --ff-only
run awa git switch -c feature/recherche

note "2. Des commits petits et lisibles"
quiet_sh awa 'echo "recherche" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche" && echo "test" > recherche.test.js && git add . && git commit -q -m "test(recherche): couvre la recherche vide"'
run awa git log --oneline main..HEAD

note "3. Pousser, puis ouvrir la pull request sur GitHub"
run awa git push -u origin feature/recherche

note "Ce que la pull request contiendra : les commits, et la différence depuis main"
run awa git log --oneline main..feature/recherche
run awa git diff --stat main...feature/recherche

note "4. Une remarque en relecture : un commit de plus, pas de réécriture"
quiet_sh awa 'echo "recherche + filtre" > recherche.js && git commit -q -am "fix(recherche): ignore les espaces en debut de saisie"'
run awa git push
run awa git log --oneline main..feature/recherche

note "5. Après la fusion sur GitHub : se remettre à jour et nettoyer"
quiet_sh bakary 'git fetch -q && git merge -q --no-ff -m "Merge pull request #12 from equipe/feature/recherche" origin/feature/recherche && git push -q origin main && git push -q origin --delete feature/recherche'
run awa git switch main
run awa git pull --ff-only
run awa git fetch --prune
run awa git branch -d feature/recherche

GH=$(command -v gh 2>/dev/null || ls "/c/Program Files/GitHub CLI/gh.exe" 2>/dev/null || true)
if [ -n "$GH" ] && "$GH" auth status >/dev/null 2>&1; then
  note "Vu depuis GitHub : les dernières pull requests fusionnées de ce site"
  echo '$ gh pr list --repo Hatimou-Nabina/git-en-situation --state merged --limit 5'
  "$GH" pr list --repo Hatimou-Nabina/git-en-situation --state merged --limit 5 2>&1
  echo
fi

note "Version de Git utilisée"
run awa git --version
