#!/usr/bin/env bash
# Comprendre : upstream, la branche que la tienne suit.
# Page : src/content/docs/comprendre/upstream-la-branche-que-la-tienne-suit.md
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "Une branche neuve ne suit rien ; main, elle, suit origin/main"
quiet_sh awa 'git switch -q -c feature/recherche && echo "recherche" > recherche.js && git add . && git commit -q -m "Ajoute la recherche"'
run awa git branch -vv
run_sh awa "git config --get-regexp '^branch\.'"
run awa git push

note "push -u écrit deux lignes dans .git/config"
run awa git push -u origin feature/recherche
run_sh awa "git config --get-regexp '^branch\.feature'"
run awa git branch -vv

note "ahead : un commit local que le serveur n'a pas"
quiet_sh awa 'echo "filtre" >> recherche.js && git commit -qam "Filtre les resultats"'
run awa git status -sb
run awa git branch -vv

note "behind : un collègue a poussé sur la même branche"
quiet awa git push -q
quiet_sh bakary 'git fetch -q && git switch -q feature/recherche && echo "tri" >> recherche.js && git commit -qam "Trie les resultats" && git push -q'
run awa git fetch
run awa git status -sb
run awa git branch -vv

note "gone : la branche du serveur a disparu"
quiet awa git pull -q --ff-only
quiet bakary git push -q origin --delete feature/recherche
run awa git fetch --prune
run awa git branch -vv
run awa git status -sb

note "Retirer le lien, le poser après coup"
run awa git branch --unset-upstream
run awa git branch -vv
run awa git push origin feature/recherche
run awa git branch -vv
run awa git branch -u origin/feature/recherche
run awa git branch -vv

note "Version de Git utilisée"
run awa git --version
