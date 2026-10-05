#!/usr/bin/env bash
# Travailler en équipe : une branche par changement.
# Page : src/content/docs/equipe/une-branche-par-changement.md
#
# La fusion « par GitHub » est jouée par un second poste.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "1. Partir d'un main à jour, nommer la branche par ce qu'elle change"
run awa git switch main
run awa git pull --ff-only
run awa git switch -c fix/connexion-timeout

note "2. Des commits qui ne parlent que de ça"
quiet_sh awa 'echo "timeout 30" > connexion.js && git add . && git commit -q -m "fix(connexion): porte le timeout a 30 s" && echo "test timeout" > connexion.test.js && git add . && git commit -q -m "test(connexion): couvre le timeout"'
run awa git log --oneline main..HEAD
run awa git diff --stat main...HEAD

note "3. Un second changement en cours : une seconde branche"
run awa git switch main
run awa git switch -c feature/export-csv
quiet_sh awa 'echo "export" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV"'
run awa git branch
run_sh awa "git for-each-ref --sort=committerdate --format='%(refname:short)  %(committerdate:short)  %(subject)' refs/heads/"

note "4. Garder la branche courte : voir ce que main a reçu pendant ce temps"
quiet_sh bakary 'echo "doc" >> README.md && git commit -q -am "docs: complete le README" && git push -q origin main'
run awa git fetch
run awa git log --oneline HEAD..origin/main
run awa git log --oneline origin/main..HEAD

note "5. Un garde-fou local : pas de commit direct sur main"
cat > "$SANDBOX/awa/.git/hooks/pre-commit" <<'EOF'
#!/usr/bin/env bash
# Refuse un commit fait directement sur main.
if [ "$(git symbolic-ref --short HEAD 2>/dev/null)" = "main" ]; then
  echo "Pas de commit direct sur main : cree une branche, git switch -c type/sujet" >&2
  exit 1
fi
EOF
chmod +x "$SANDBOX/awa/.git/hooks/pre-commit"
run_sh awa 'cat .git/hooks/pre-commit'
run awa git switch main
quiet_sh awa 'echo "oups" > oups.js && git add oups.js'
run_sh awa 'git commit -m "fix: corrige un detail"'
run awa git switch -c fix/detail
run_sh awa 'git commit -m "fix: corrige un detail"'

note "6. Après la fusion : la branche disparaît, et -d refuse celle qui ne l'est pas"
quiet awa git push -q -u origin fix/connexion-timeout
quiet_sh bakary 'git fetch -q && git merge -q --no-ff -m "Merge pull request #7 from equipe/fix/connexion-timeout" origin/fix/connexion-timeout && git push -q origin main && git push -q origin --delete fix/connexion-timeout'
run awa git switch main
run awa git pull --ff-only
run awa git fetch --prune
run awa git branch -d fix/connexion-timeout
run awa git branch -d feature/export-csv

note "Version de Git utilisée"
run awa git --version
