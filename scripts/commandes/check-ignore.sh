#!/usr/bin/env bash
# Commandes : git check-ignore.
# Page : src/content/docs/commandes/check-ignore.mdx
#
# Le fichier d'exclusions global vit dans un faux dossier personnel,
# /home/awa/.gitignore_global, pour que -v affiche un chemin réaliste.
source "$(dirname "$0")/../situations/_lib.sh"
CLEAN_PRE=(-e "s#$SANDBOX_ALT/home#/home#g" -e "s#$SANDBOX/home#/home#g")
mkdir -p "$SANDBOX/home/awa"
echo ".DS_Store" > "$SANDBOX/home/awa/.gitignore_global"
setup_team
quiet awa git config --global core.excludesFile "$SANDBOX/home/awa/.gitignore_global"
quiet_sh awa 'printf "*.log\nnode_modules/\n/dist\n!important.log\n" > .gitignore && echo "scratch/" >> .git/info/exclude
mkdir -p node_modules dist src/dist scratch
for f in debug.log important.log node_modules/x.js dist/app.js src/dist/app.js .DS_Store scratch/notes.txt app.js suivi.log; do echo "x" > "$f"; done
git add .gitignore app.js && git add -f suivi.log && git commit -q -m "chore: gitignore"'

note "Ce fichier est-il ignoré, et par quelle règle ?"
run awa cat .gitignore
run awa git check-ignore debug.log app.js
run awa git check-ignore -v debug.log important.log node_modules/x.js dist/app.js src/dist/app.js

note "Voir aussi ce qui n'est pas ignoré : --non-matching"
run awa git check-ignore -v --non-matching src/dist/app.js important.log

note "Les règles qui ne sont pas dans le .gitignore du projet"
run awa git check-ignore -v .DS_Store
run awa git check-ignore -v scratch/notes.txt

note "Dans un script : le code de sortie"
run_sh awa 'git check-ignore -q debug.log && echo "ignore" || echo "pas ignore"'
run_sh awa 'git check-ignore -q app.js && echo "ignore" || echo "pas ignore"'

note "Un fichier déjà suivi n'est jamais ignoré"
run awa git check-ignore -v suivi.log
run awa git check-ignore -v --no-index suivi.log

note "Version de Git utilisée"
run awa git --version
