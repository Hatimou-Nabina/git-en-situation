#!/usr/bin/env bash
# Commandes : git config.
# Page : src/content/docs/commandes/config.mdx
#
# La configuration globale du bac à sable est déplacée dans un faux dossier
# personnel, /home/awa/.gitconfig, pour que --show-origin affiche un chemin
# qui ressemble à celui d'un vrai poste.
source "$(dirname "$0")/../situations/_lib.sh"
CLEAN_PRE=(-e "s#$SANDBOX_ALT/home#/home#g" -e "s#$SANDBOX/home#/home#g")
mkdir -p "$SANDBOX/home/awa"
cp "$GIT_CONFIG_GLOBAL" "$SANDBOX/home/awa/.gitconfig"
export GIT_CONFIG_GLOBAL="$SANDBOX/home/awa/.gitconfig"
setup_team
quiet_sh awa 'echo "a" > a.js && git add . && git commit -q -m "feat: a" && git switch -q -c feature/x && echo "x" > x.js && git add . && git commit -q -m "feat: x" && git switch -q main'

note "Lire : la valeur effective, et d'où elle vient"
run awa git config user.email
run awa git config --show-origin user.email
run awa git config --global --list

note "Trois niveaux, système, global, local : le plus proche gagne"
run awa git config --local user.email awa.pro@example.com
run awa git config user.email
run awa git config --show-origin user.email
run awa git config --local --unset user.email
run awa git config user.email

note "Les réglages que ce site recommande"
run awa git config --global pull.ff only
run awa git config --global push.autoSetupRemote true
run awa git config --global fetch.prune true
run awa git config --global rebase.autoStash true
run awa git config --global --list

note "Un alias"
run_sh awa 'git config --global alias.lg "log --oneline --graph --decorate --all"'
run awa git lg

note "Retirer un réglage"
run awa git config --global --unset alias.lg
run awa git lg

note "Version de Git utilisée"
run awa git --version
