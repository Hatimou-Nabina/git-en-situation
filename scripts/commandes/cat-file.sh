#!/usr/bin/env bash
# Commandes : git cat-file.
# Page : src/content/docs/commandes/cat-file.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'mkdir -p src && echo "console.log(1)" > src/app.js && git add . && git commit -q -m "feat(app): premiere version" && git tag -a v1.0.0 -m "Version 1.0.0"'

note "Le type d'un objet"
run awa git rev-parse HEAD
run awa git cat-file -t HEAD
run awa git cat-file -t 'HEAD^{tree}'
run awa git cat-file -t HEAD:src/app.js
run awa git cat-file -t v1.0.0

note "Un commit : son arbre, son parent, son auteur, son message"
run awa git cat-file -p HEAD

note "Un arbre : les fichiers et dossiers du commit"
run awa git cat-file -p 'HEAD^{tree}'
run awa git cat-file -p HEAD:src

note "Un blob : le contenu d'un fichier, et sa taille"
run awa git cat-file -p HEAD:src/app.js
run awa git cat-file -s HEAD:src/app.js

note "Un tag annoté"
run awa git cat-file -p v1.0.0

note "Version de Git utilisée"
run awa git --version
