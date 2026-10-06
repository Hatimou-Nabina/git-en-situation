#!/usr/bin/env bash
# Situation : j'ai poussé un secret par erreur.
# Page : src/content/docs/situations/fichiers/secret-pousse-par-erreur.md
#
# La réécriture de l'historique utilise git filter-repo, qui ne vient pas avec
# Git : pip install git-filter-repo. Sans lui, le script s'arrête avant cette étape.
source "$(dirname "$0")/_lib.sh"
setup_team

# Un fichier .env avec une clé est commité, poussé, puis un autre commit suit.
quiet_sh awa 'echo "API_KEY=sk-live-123456" > .env && echo "console.log(1)" > app.js && git add . && git commit -q -m "Ajoute l application" && git push -q origin main'
quiet_sh awa 'echo "console.log(2)" > app.js && git commit -q -am "Corrige un bug" && git push -q origin main'
quiet bakary git pull

note "Le secret est parti sur le serveur, deux commits plus tôt"
run awa git log --oneline -3
run awa git show --stat --oneline HEAD~1

note "1. Révoquer la clé, puis retirer le fichier du suivi"
run awa git rm --cached .env
run_sh awa 'echo ".env" > .gitignore && git add .gitignore && git commit -q -m "Retire le fichier .env du suivi" && git push -q origin main'
run awa git status --short

note "Le fichier n'est plus suivi, mais il est toujours dans l'historique"
run awa git log --oneline --all -- .env
run awa git show HEAD~2:.env

# Git cherche un exécutable « git-filter-repo » dans le PATH. Installé par pip
# sous Windows, il n'y est pas toujours : on passe alors par le module Python.
if ! command -v git-filter-repo >/dev/null 2>&1 && python -m git_filter_repo --version >/dev/null 2>&1; then
  mkdir -p "$SANDBOX/bin"
  printf '#!/usr/bin/env bash\nexec python -m git_filter_repo "$@"\n' > "$SANDBOX/bin/git-filter-repo"
  chmod +x "$SANDBOX/bin/git-filter-repo"
  export PATH="$SANDBOX/bin:$PATH"
fi
if ! command -v git-filter-repo >/dev/null 2>&1; then
  echo "git filter-repo n'est pas installé (pip install git-filter-repo) : fin du script."
  exit 0
fi

note "2. Réécrire l'historique sans ce fichier"
# --quiet : sans la progression « Parsed N commits », qui s'affiche selon
# l'horloge et non selon le nombre de commits, donc jamais deux fois pareil.
run awa git filter-repo --quiet --invert-paths --path .env --force
run awa git log --oneline --all -- .env
run awa git log --oneline -3
run awa git show HEAD~2:.env

note "3. Remplacer l'historique sur le serveur"
run awa git remote -v
run awa git remote add origin github.com:equipe/projet.git
quiet awa git remote set-url origin "$SERVER"
run awa git push --force --all

note "Chez les collègues : l'ancien historique a divergé, il faut recloner"
run bakary git fetch
run bakary git status

note "Version de Git utilisée"
run awa git --version
