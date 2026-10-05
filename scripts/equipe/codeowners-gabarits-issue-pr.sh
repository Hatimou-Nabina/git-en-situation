#!/usr/bin/env bash
# Travailler en équipe : CODEOWNERS, gabarits d'issue et de PR.
# Page : src/content/docs/equipe/codeowners-gabarits-issue-pr.md
#
# Les automatismes eux-mêmes sont faits par GitHub ; le script montre les
# fichiers qui les pilotent, et ce que l'historique dit de qui connaît quoi.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Deux zones du projet, deux personnes qui y ont travaillé.
quiet_sh awa 'mkdir -p src/recherche src/paiement
echo "r1" > src/recherche/index.js && git add . && git commit -q -m "feat(recherche): ajoute la barre de recherche"
echo "r2" > src/recherche/filtres.js && git add . && git commit -q -m "feat(recherche): ajoute les filtres"
echo "p0" > src/paiement/index.js && git add . && git commit -q -m "feat(paiement): squelette du module"
git push -q'
quiet_sh bakary 'git pull -q
echo "p1" > src/paiement/carte.js && git add . && git commit -q -m "feat(paiement): ajoute le paiement par carte"
echo "p2" > src/paiement/virement.js && git add . && git commit -q -m "feat(paiement): ajoute le virement"
echo "p3" > src/paiement/carte.js && git commit -q -am "fix(paiement): corrige l arrondi des centimes"
git push -q'
quiet awa git pull -q

note "1. Qui connaît quoi : l'historique le dit"
run awa git shortlog -sn HEAD -- src/paiement/
run awa git shortlog -sn HEAD -- src/recherche/

note "2. CODEOWNERS : un chemin, des responsables"
mkdir -p "$SANDBOX/awa/.github/ISSUE_TEMPLATE"
cat > "$SANDBOX/awa/.github/CODEOWNERS" <<'EOF'
# Qui relit quoi. Même syntaxe que .gitignore ; la dernière règle qui correspond gagne.

# Par défaut, Awa relit tout.
*                   @awa

# Le paiement est relu par Bakary.
/src/paiement/      @bakary

# Ce qui pilote GitHub est relu par les deux.
/.github/           @awa @bakary
EOF
run awa cat .github/CODEOWNERS

note "3. Le gabarit de pull request : les questions posées avant qu'on les oublie"
cat > "$SANDBOX/awa/.github/PULL_REQUEST_TEMPLATE.md" <<'EOF'
## Quoi

<!-- Une phrase : ce que cette PR change. -->

## Pourquoi

<!-- Le problème vécu, ou l'issue liée : « Closes #12 ». -->

## Vérifications

- [ ] Les tests passent en local.
- [ ] La ligne du changelog est là.
- [ ] Ce qui change pour l'utilisateur est dit dans la description.
EOF
run awa cat .github/PULL_REQUEST_TEMPLATE.md

note "4. Les gabarits d'issue : un formulaire plutôt qu'une page blanche"
cat > "$SANDBOX/awa/.github/ISSUE_TEMPLATE/signaler-un-bug.yml" <<'EOF'
name: Signaler un bug
description: Quelque chose ne fait pas ce qu'il devrait.
title: "[Bug] "
labels: ["bug", "à trier"]
body:
  - type: textarea
    id: observe
    attributes:
      label: Ce que tu observes
      description: Le message exact, dans un bloc de code si possible.
    validations:
      required: true
  - type: textarea
    id: attendu
    attributes:
      label: Ce que tu attendais
    validations:
      required: true
  - type: input
    id: version
    attributes:
      label: Version
      placeholder: v1.2.0
EOF
cat > "$SANDBOX/awa/.github/ISSUE_TEMPLATE/config.yml" <<'EOF'
blank_issues_enabled: false
contact_links:
  - name: Poser une question
    url: https://github.com/mon-equipe/projet/discussions
    about: Une question, une idée pas encore mûre : les Discussions sont faites pour ça.
EOF
run awa cat .github/ISSUE_TEMPLATE/signaler-un-bug.yml
run awa cat .github/ISSUE_TEMPLATE/config.yml

note "5. Tout ça est versionné, et passe par une pull request comme le reste"
quiet_sh awa 'git add .github && git commit -q -m "chore(github): CODEOWNERS, gabarits d issue et de PR" && git push -q'
run awa git ls-files .github
run awa git log --oneline -- .github/

note "Version de Git utilisée"
run awa git --version
