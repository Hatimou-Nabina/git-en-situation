#!/usr/bin/env bash
# Travailler en équipe : tenir un changelog.
# Page : src/content/docs/equipe/tenir-un-changelog.md
#
# Les fichiers sont réécrits en entier par le script (pas de sed -i, qui
# diffère entre GNU et BSD) : seule la commande affichée compte.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Le projet a déjà un changelog et une version 1.1.0.
cat > "$SANDBOX/awa/CHANGELOG.md" <<'EOF'
# Changelog

Les évolutions notables du projet, pour ceux qui l'utilisent. Format : Keep a Changelog ; numéros : versionnage sémantique.

## [Non publié]

## [1.1.0] - 2026-09-20

### Ajouté
- Recherche dans les documents, avec un filtre par date.

### Corrigé
- L'export d'une liste vide ne plante plus.
EOF
quiet_sh awa 'git add . && git commit -q -m "docs: ajoute le changelog" && git tag -a v1.1.0 -m "Version 1.1.0" && git push -q && git push -q --tags'
quiet bakary git pull -q

note "1. Le fichier : une section « Non publié » en haut, une section par version ensuite"
run awa cat CHANGELOG.md

note "2. La ligne du changelog voyage dans le même commit que le changement"
cat > "$SANDBOX/awa/CHANGELOG.md" <<'EOF'
# Changelog

Les évolutions notables du projet, pour ceux qui l'utilisent. Format : Keep a Changelog ; numéros : versionnage sémantique.

## [Non publié]

### Ajouté
- Export CSV des résultats de recherche.

## [1.1.0] - 2026-09-20

### Ajouté
- Recherche dans les documents, avec un filtre par date.

### Corrigé
- L'export d'une liste vide ne plante plus.
EOF
quiet_sh awa 'echo "export csv" > export.js && git add . && git commit -q -m "feat(export): ajoute l export CSV" && git push -q'
run_sh awa "git show --stat --format='%h %s' HEAD"
run awa git log --oneline -- CHANGELOG.md

note "3. Deux pull requests touchent la même section : le conflit"
# Bakary, sans avoir récupéré le commit d'Awa, ajoute sa ligne au même endroit.
cat > "$SANDBOX/bakary/CHANGELOG.md" <<'EOF'
# Changelog

Les évolutions notables du projet, pour ceux qui l'utilisent. Format : Keep a Changelog ; numéros : versionnage sémantique.

## [Non publié]

### Corrigé
- La recherche ignore désormais les accents.

## [1.1.0] - 2026-09-20

### Ajouté
- Recherche dans les documents, avec un filtre par date.

### Corrigé
- L'export d'une liste vide ne plante plus.
EOF
quiet_sh bakary 'echo "accents" > recherche.js && git add . && git commit -q -m "fix(recherche): ignore les accents"'
run bakary git pull --rebase
run_sh bakary 'sed -n "5,16p" CHANGELOG.md'
run bakary git rebase --abort

note "4. L'éviter une fois pour toutes : merge=union pour ce fichier"
quiet_sh awa 'echo "CHANGELOG.md merge=union" > .gitattributes && git add .gitattributes && git commit -q -m "chore: fusion par union pour le changelog" && git push -q'
run awa cat .gitattributes
run bakary git pull --rebase
run_sh bakary 'sed -n "5,12p" CHANGELOG.md'
quiet bakary git push -q

note "5. Le brouillon de la version, depuis les commits conventionnels"
quiet awa git pull -q --rebase
run_sh awa "git log --format='- %s' --grep='^feat' v1.1.0..HEAD"
run_sh awa "git log --format='- %s' --grep='^fix' v1.1.0..HEAD"

note "6. À la version : la section prend un numéro et une date"
cat > "$SANDBOX/awa/CHANGELOG.md" <<'EOF'
# Changelog

Les évolutions notables du projet, pour ceux qui l'utilisent. Format : Keep a Changelog ; numéros : versionnage sémantique.

## [Non publié]

## [1.2.0] - 2026-10-05

### Ajouté
- Export CSV des résultats de recherche.

### Corrigé
- La recherche ignore désormais les accents.

## [1.1.0] - 2026-09-20

### Ajouté
- Recherche dans les documents, avec un filtre par date.

### Corrigé
- L'export d'une liste vide ne plante plus.
EOF
quiet_sh awa 'git commit -q -am "chore(release): version 1.2.0" && git tag -a v1.2.0 -m "Version 1.2.0" && git push -q && git push -q --tags'
run awa git diff HEAD~1 -- CHANGELOG.md
run awa git log --oneline v1.1.0..v1.2.0

note "Version de Git utilisée"
run awa git --version
