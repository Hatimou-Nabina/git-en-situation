#!/usr/bin/env bash
# Situation : .gitignore ne marche pas, le fichier est déjà suivi.
# Page : src/content/docs/situations/fichiers/gitignore-fichier-deja-suivi.md
source "$(dirname "$0")/_lib.sh"
setup_team

# Awa a commité un fichier .env avant de penser au .gitignore.
quiet_sh awa 'echo "SECRET=abc" > .env && echo "console.log(1)" > app.js && git add . && git commit -q -m "Ajoute l application"'

note "Le .gitignore est là, et pourtant Git voit toujours le fichier"
run_sh awa 'echo ".env" > .gitignore'
run_sh awa 'echo "SECRET=def" > .env'
run awa git status --short
run awa git check-ignore -v .env

note "Diagnostic : le fichier est déjà suivi"
run awa git ls-files

note "Solution : le retirer du suivi, sans le supprimer du disque"
run awa git rm --cached .env
run awa git status --short
run_sh awa 'git add .gitignore && git commit -q -m "Ignore le fichier .env"'
run awa git status --short
run_sh awa 'ls -a'
run awa git check-ignore -v .env

note "Autre cause : un .gitignore que Git ne sait pas lire"
# Le fichier est écrit comme le ferait « echo node_modules/ > .gitignore » dans PowerShell 5 : UTF-16 LE avec BOM.
quiet_sh awa '{ printf "\377\376"; printf "node_modules/\n" | iconv -f UTF-8 -t UTF-16LE; } > .gitignore && mkdir -p node_modules && echo "x" > node_modules/lib.js'
run awa git status --short
run awa git check-ignore -v node_modules/lib.js
run_sh awa 'od -An -c -N 8 .gitignore'
run_sh awa 'iconv -f UTF-16 -t UTF-8 .gitignore > .gitignore.utf8 && mv .gitignore.utf8 .gitignore'
run_sh awa 'od -An -c -N 8 .gitignore'
run awa git check-ignore -v node_modules/lib.js
run awa git status --short

note "Version de Git utilisée"
run awa git --version
