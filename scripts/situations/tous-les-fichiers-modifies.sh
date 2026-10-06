#!/usr/bin/env bash
# Situation : Git voit tous mes fichiers comme modifiés.
# Page : src/content/docs/situations/fichiers/tous-les-fichiers-modifies.md
source "$(dirname "$0")/_lib.sh"
setup_team

quiet_sh awa 'printf "a\nb\n" > a.txt && printf "c\nd\n" > b.txt && printf "e\n" > c.txt && git add . && git commit -q -m "Ajoute des fichiers" && git push -q origin main'

# Bakary, sous Windows, a cloné avec core.autocrlf=true : ses fichiers sont en CRLF sur le disque.
rm -rf "$SANDBOX/bakary"
git clone -q -c core.autocrlf=true "$SERVER" "$SANDBOX/bakary"
quiet bakary git config user.name "Bakary"
quiet bakary git config user.email "bakary@example.com"

note "Fraîchement cloné sous Windows, avec core.autocrlf=true : rien à signaler"
run bakary git config core.autocrlf
run bakary git status --short

note "Un réglage change, et tout est modifié sans qu'on ait rien touché"
run bakary git config core.autocrlf false
# Git fait confiance aux dates des fichiers : tant qu'elles n'ont pas bougé
# depuis le clone, il ne relit pas leur contenu et status ne verrait rien,
# sauf si le clone et l'index datent de la même seconde. Sur un vrai poste,
# c'est le premier enregistrement dans l'éditeur qui révèle le problème ; ici,
# touch joue ce rôle, pour une sortie identique à chaque exécution.
quiet_sh bakary 'touch README.md a.txt b.txt c.txt'
run bakary git status --short
run bakary git diff --stat
run_sh bakary 'git diff a.txt | cat -A | tail -4'

note "Diagnostic : les fins de ligne, fichier par fichier"
run bakary git ls-files --eol

note "Solution : fixer la règle dans le dépôt, puis tout réécrire selon la règle"
run_sh bakary 'printf "* text=auto eol=lf\n" > .gitattributes'
run bakary git add --renormalize .
run bakary git status --short
run_sh bakary 'git add .gitattributes && git commit -q -m "Fins de ligne LF pour tout le depot"'
run_sh bakary 'git rm -r -q --cached . && git reset -q --hard'
run bakary git ls-files --eol
run bakary git status --short

note "Version de Git utilisée"
run bakary git --version
