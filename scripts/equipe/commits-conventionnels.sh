#!/usr/bin/env bash
# Travailler en équipe : les commits conventionnels.
# Page : src/content/docs/equipe/commits-conventionnels.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

quiet_sh awa 'git switch -q -c feature/recherche
echo "r" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche"
echo "t" > recherche.test.js && git add . && git commit -q -m "test(recherche): couvre la recherche vide"
echo "f" > recherche.js && git commit -q -am "fix(recherche): ignore les espaces en debut de saisie"
echo "d" >> README.md && git commit -q -am "docs: explique le filtre de recherche"
printf "feat(api)!: renomme le champ query en q\n\nLe nom query devenait ambigu avec le parametre de pagination,\nqui s appelle aussi query dans la bibliotheque HTTP.\n\nBREAKING CHANGE: les clients doivent envoyer q au lieu de query.\nCloses #12\n" > msg.txt
echo "api" > api.js && git add api.js && git commit -q -F msg.txt && rm msg.txt'

note "Un historique qui se lit sans ouvrir les commits"
run awa git log --oneline main..HEAD

note "Le type sert à filtrer"
run_sh awa "git log --oneline --grep='^feat' main..HEAD"
run_sh awa "git log --oneline --grep='^fix' main..HEAD"

note "Le corps dit pourquoi, le pied de page relie"
run_sh awa "git log -1 --format='%B'"

note "Compter par type, pour un changelog ou un bilan"
run_sh awa "git log --format='%s' main..HEAD | sed -E 's/^([a-z]+).*/\\1/' | sort | uniq -c"

note "Un garde-fou local : refuser un message hors format"
cat > "$SANDBOX/awa/.git/hooks/commit-msg" <<'EOF'
#!/usr/bin/env bash
# Refuse un message qui ne suit pas « type(scope): sujet ».
if ! head -1 "$1" | grep -Eq '^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?!?: .+'; then
  echo "Message refuse. Attendu : type(scope): sujet, par exemple fix(auth): corrige la deconnexion" >&2
  exit 1
fi
EOF
chmod +x "$SANDBOX/awa/.git/hooks/commit-msg"
run_sh awa 'cat .git/hooks/commit-msg'
quiet_sh awa 'echo "x" > x.txt && git add x.txt'
run_sh awa 'git commit -m "update stuff"'
run_sh awa 'git commit -m "chore: ajoute x.txt"'

note "Version de Git utilisée"
run awa git --version
