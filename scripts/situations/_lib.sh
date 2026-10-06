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
#   EXERCICE=1        mode exercice : le script fabrique la panne dans
#                     exercices/<slug>/ à la racine du dépôt, s'arrête juste
#                     après le symptôme (fonction exercice) et dit dans quel
#                     dossier aller. Sans la variable, il joue la solution.

set -u

EXERCICE="${EXERCICE:-}"
SLUG="$(basename "$0" .sh)"
if [ -n "$EXERCICE" ]; then
  SANDBOX="$(cd "$(dirname "$0")/../.." && pwd)/exercices/$SLUG"
  rm -rf "$SANDBOX"
  mkdir -p "$SANDBOX"
  KEEP_SANDBOX=1
fi
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
# Les durées (« in 0.21 seconds ») ne sont pas reproductibles : remplacées par N.NN.
# Un script peut ajouter ses propres règles sed : CLEAN_PRE s'applique avant
# les règles communes (par exemple pour garder un chemin sous /home), CLEAN_EXTRA
# après (par exemple pour un second serveur github.com/awa).
SANDBOX_ALT="$SANDBOX"
command -v cygpath >/dev/null 2>&1 && SANDBOX_ALT="$(cygpath -m "$SANDBOX")"
CLEAN_PRE=()
CLEAN_EXTRA=()
clean() {
  sed ${CLEAN_PRE[@]+"${CLEAN_PRE[@]}"} \
    -e "s#$SANDBOX_ALT/##g" -e "s#$SANDBOX/##g" -e 's#\.\./github\.com/#github.com/#g' -e "s#github.com/equipe#github.com:equipe#g" \
    -E -e 's/[0-9]+\.[0-9]+ seconds/N.NN seconds/g' \
    ${CLEAN_EXTRA[@]+"${CLEAN_EXTRA[@]}"}
}

# run <poste> <commande...> : affiche « $ commande » puis sa sortie.
# La ligne de commande est nettoyée comme la sortie : un chemin du bac à sable
# passé en argument s'affiche en adresse de serveur.
#
# Les deux flux de sortie sont capturés séparément et imprimés dans un ordre
# fixe, stderr puis stdout. Mélangés (2>&1), leur ordre dépend du système :
# Git pour Windows met stderr en tampon et le vide à la fin, après stdout,
# Linux l'écrit immédiatement. « git switch main » donnait ainsi ses deux
# lignes dans un ordre différent selon le poste. L'ordre choisi est celui d'un
# terminal dans les cas courants : « Switched to branch » avant « Your branch
# is up to date », « From … » avant « Updating … ».
run() {
  local dir="$1"; shift
  echo "\$ $*" | clean
  ( cd "$SANDBOX/$dir" && "$@" >"$SANDBOX/.stdout" 2>"$SANDBOX/.stderr" )
  cat "$SANDBOX/.stderr" "$SANDBOX/.stdout" | clean
  echo
}

# run_sh <poste> '<ligne shell>' : comme run, pour une ligne avec && ou | .
run_sh() {
  local dir="$1" line="$2"
  echo "\$ $line" | clean
  ( cd "$SANDBOX/$dir" && bash -c "$line" >"$SANDBOX/.stdout" 2>"$SANDBOX/.stderr" )
  cat "$SANDBOX/.stderr" "$SANDBOX/.stdout" | clean
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
# L'adresse d'origin est relative (../github.com/equipe/projet.git) : elle est
# la même sur tous les postes et tous les systèmes, donc les commits de merge
# créés par git pull, dont le message cite l'adresse, ont partout le même
# identifiant. Un clone enregistre une adresse absolue : on la remplace.
REMOTE_URL="../github.com/equipe/projet.git"
setup_team() {
  git init -q --bare "$SERVER"
  git clone -q "$SERVER" "$SANDBOX/awa" 2>/dev/null
  quiet awa git remote set-url origin "$REMOTE_URL"
  quiet_sh awa 'echo "# Projet" > README.md && git add . && git commit -q -m "Premier commit" && git push -q -u origin main'
  git clone -q "$SERVER" "$SANDBOX/bakary"
  quiet bakary git remote set-url origin "$REMOTE_URL"
  quiet bakary git config user.name "Bakary"
  quiet bakary git config user.email "bakary@example.com"
}

# note '<texte>' : un titre dans la sortie, pour s'y retrouver.
note() { echo "### $*"; echo; }

# exercice <poste> '<objectif>' : le point d'arrêt du mode exercice, à placer
# juste après le symptôme. Avec EXERCICE=1, affiche le dossier où aller et
# l'objectif, puis s'arrête en gardant le bac à sable. Sinon, ne fait rien.
exercice() {
  [ -n "$EXERCICE" ] || return 0
  local dir="$1"; shift
  echo "### À toi"
  echo
  echo "La situation est en place. Va dans le dossier, et répare :"
  echo
  echo "  cd \"$SANDBOX/$dir\""
  echo
  echo "Objectif : $*"
  echo
  echo "Pour voir la solution : bash scripts/situations/$SLUG.sh"
  echo "Pour recommencer : EXERCICE=1 bash scripts/situations/$SLUG.sh (le dossier est recréé)."
  exit 0
}
