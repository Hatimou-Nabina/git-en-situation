#!/usr/bin/env bash
# Bibliothèque commune aux scripts de situations.
#
# Chaque script rejoue une situation dans des dépôts jetables, avec une
# configuration Git neutre (ni la tienne, ni celle du système), et affiche
# chaque commande suivie de sa vraie sortie. C'est de là que viennent les
# sorties montrées dans les pages : quand Git change de comportement, on
# relance le script et on compare.
#
# Usage : bash scripts/situations/<slug>.sh
#   SANDBOX=/chemin   dossier de travail (sinon un dossier temporaire)
#   KEEP_SANDBOX=1    ne pas supprimer le dossier à la fin

set -u

SANDBOX="${SANDBOX:-$(mktemp -d)}"
KEEP_SANDBOX="${KEEP_SANDBOX:-}"
cleanup() { [ -n "$KEEP_SANDBOX" ] || rm -rf "$SANDBOX"; }
trap cleanup EXIT

# Configuration Git neutre et dates figées : mêmes identifiants de commit à chaque exécution.
export GIT_CONFIG_NOSYSTEM=1
export GIT_CONFIG_GLOBAL="$SANDBOX/gitconfig"
git config --file "$GIT_CONFIG_GLOBAL" user.name "Awa"
git config --file "$GIT_CONFIG_GLOBAL" user.email "awa@example.com"
git config --file "$GIT_CONFIG_GLOBAL" init.defaultBranch main
git config --file "$GIT_CONFIG_GLOBAL" core.autocrlf false
git config --file "$GIT_CONFIG_GLOBAL" color.ui never
export GIT_AUTHOR_DATE="2026-10-05T10:00:00+00:00"
export GIT_COMMITTER_DATE="2026-10-05T10:00:00+00:00"
# Messages de Git en anglais : c'est ce que voient la plupart des gens.
export LANG=C LC_ALL=C
# Jamais d'éditeur : un merge ou un rebase garde son message par défaut.
export GIT_EDITOR=true

# Le « serveur » : un dépôt nu dont le chemin ressemble à une adresse GitHub.
SERVER="$SANDBOX/github.com/equipe/projet.git"

# Dans les sorties, le dossier temporaire est effacé pour ne laisser que
# « github.com:equipe/projet.git », lisible et proche de ce qu'on voit en vrai.
SANDBOX_ALT="$SANDBOX"
command -v cygpath >/dev/null 2>&1 && SANDBOX_ALT="$(cygpath -m "$SANDBOX")"
clean() {
  sed -e "s#$SANDBOX_ALT/##g" -e "s#$SANDBOX/##g" -e "s#github.com/equipe#github.com:equipe#g"
}

# run <poste> <commande...> : affiche « $ commande » puis sa sortie, telle quelle.
# La ligne de commande est nettoyée comme la sortie : un chemin du bac à sable
# passé en argument s'affiche en adresse de serveur.
run() {
  local dir="$1"; shift
  echo "\$ $*" | clean
  ( cd "$SANDBOX/$dir" && "$@" 2>&1 ) | clean
  echo
}

# run_sh <poste> '<ligne shell>' : comme run, pour une ligne avec && ou | .
run_sh() {
  local dir="$1" line="$2"
  echo "\$ $line" | clean
  ( cd "$SANDBOX/$dir" && bash -c "$line" 2>&1 ) | clean
  echo
}

# quiet <poste> <commande...> : exécute sans rien afficher (mise en place).
quiet() {
  local dir="$1"; shift
  ( cd "$SANDBOX/$dir" && "$@" >/dev/null 2>&1 )
}

# quiet_sh <poste> '<ligne shell>' : mise en place en plusieurs commandes.
quiet_sh() {
  local dir="$1" line="$2"
  ( cd "$SANDBOX/$dir" && bash -c "$line" >/dev/null 2>&1 )
}

# setup_team : le serveur avec un premier commit, et deux postes clonés : awa et bakary.
setup_team() {
  git init -q --bare "$SERVER"
  git clone -q "$SERVER" "$SANDBOX/awa" 2>/dev/null
  quiet_sh awa 'echo "# Projet" > README.md && git add . && git commit -q -m "Premier commit" && git push -q -u origin main'
  git clone -q "$SERVER" "$SANDBOX/bakary"
  quiet bakary git config user.name "Bakary"
  quiet bakary git config user.email "bakary@example.com"
}

# note '<texte>' : un titre dans la sortie, pour s'y retrouver.
note() { echo "### $*"; echo; }
