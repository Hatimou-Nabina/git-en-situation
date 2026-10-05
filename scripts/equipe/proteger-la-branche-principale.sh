#!/usr/bin/env bash
# Travailler en équipe : protéger la branche principale.
# Page : src/content/docs/equipe/proteger-la-branche-principale.md
#
# La protection est un réglage du serveur. Ici, le serveur est le dépôt nu du
# bac à sable : d'abord sans protection, puis deux réglages que tout serveur
# Git connaît, puis un hook qui joue la règle « pull request obligatoire ».
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "Sans protection : un push forcé efface le travail d'un collègue"
quiet_sh bakary 'echo "export" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV" && git push -q origin main'
run bakary git log --oneline origin/main
quiet_sh awa 'echo "recherche" > recherche.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche"'
run awa git push
run awa git push --force
run bakary git fetch
run bakary git log --oneline origin/main
run bakary git status

# Bakary a encore son commit en local : il le remet en place.
quiet_sh bakary 'git rebase -q origin/main && git push -q origin main'

note "Deux réglages que tout serveur Git connaît"
run github.com/equipe/projet.git git config receive.denyNonFastForwards true
run github.com/equipe/projet.git git config receive.denyDeletes true
quiet_sh awa 'git commit -q --amend -m "feat(recherche): ajoute la barre de recherche et le tri"'
run awa git push --force
run awa git push origin --delete main

# Awa se remet au niveau du serveur.
quiet_sh awa 'git fetch -q && git reset -q --hard origin/main'

note "Imposer la pull request : aucun push direct sur main"
cat > "$SERVER/hooks/update" <<'EOF'
#!/usr/bin/env bash
# Refuse tout push direct sur main : les changements passent par une pull request.
if [ "$1" = "refs/heads/main" ]; then
  echo "main est protegee : passe par une branche et une pull request." >&2
  exit 1
fi
EOF
chmod +x "$SERVER/hooks/update"
run_sh github.com/equipe/projet.git 'cat hooks/update'
quiet_sh awa 'echo "filtre" > filtre.js && git add . && git commit -q -m "feat(recherche): ajoute le filtre par date"'
run awa git push

note "Le réflexe : le commit part sur une branche"
run awa git branch feature/filtre
run awa git reset --keep origin/main
run awa git switch feature/filtre
run awa git push -u origin feature/filtre

note "Version de Git utilisée"
run awa git --version
