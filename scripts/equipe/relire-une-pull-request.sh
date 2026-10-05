#!/usr/bin/env bash
# Travailler en équipe : relire une pull request.
# Page : src/content/docs/equipe/relire-une-pull-request.md
#
# Awa ouvre la PR, Bakary la relit depuis son poste. La fusion « par GitHub »
# est jouée par Awa.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# L'état de départ sur main : une fonction de recherche, et la page qui l'appelle.
quiet_sh awa 'printf "function chercher(terme) {\n  return index.filter(e => e.includes(terme));\n}\n" > recherche.js
printf "const resultats = chercher(saisie);\n" > page.js
git add . && git commit -q -m "feat(recherche): premiere version" && git push -q'
quiet bakary git pull -q

# La PR d'Awa : la fonction est renommée et gagne une option ; la page n'est pas mise à jour.
quiet_sh awa 'git switch -q -c feature/recherche-options
printf "function rechercher(terme, options = {}) {\n  const base = options.sensibleCasse ? index : index.map(e => e.toLowerCase());\n  return base.filter(e => e.includes(terme));\n}\n" > recherche.js
git commit -q -am "refactor(recherche): renomme chercher en rechercher, ajoute l option sensibleCasse"
printf "test: rechercher(\"a\") trouve \"A\" sans sensibleCasse\n" > recherche.test.js
git add . && git commit -q -m "test(recherche): couvre la casse"
git push -q -u origin feature/recherche-options'

note "1. Récupérer la branche de la PR sur ton poste"
run bakary git fetch
run bakary git switch feature/recherche-options

note "2. Ce que la PR change : l'ensemble, puis commit par commit"
run bakary git log --oneline --reverse main..HEAD
run bakary git diff --stat main...HEAD
run_sh bakary "git show --format='%h %s' HEAD~1"

note "3. Vérifier plutôt que croire : qui appelle encore l'ancien nom ?"
run bakary git grep -nw chercher

note "4. Après la remarque, l'auteur pousse un correctif : ne relire que ce qui a changé"
quiet_sh awa 'printf "const resultats = rechercher(saisie);\n" > page.js && git commit -q -am "fix(recherche): met a jour l appel dans page.js" && git push -q'
run bakary git fetch
run bakary git log --oneline HEAD..origin/feature/recherche-options
run bakary git diff HEAD origin/feature/recherche-options
run bakary git pull --ff-only
run bakary git grep -nw chercher

note "5. Après l'approbation et la fusion : le ménage"
quiet_sh awa 'git switch -q main && git merge -q --no-ff -m "Merge pull request #14 from equipe/feature/recherche-options" feature/recherche-options && git push -q origin main && git push -q origin --delete feature/recherche-options && git branch -q -d feature/recherche-options'
run bakary git switch main
run bakary git pull --ff-only
run bakary git fetch --prune
run bakary git branch -d feature/recherche-options

note "Version de Git utilisée"
run bakary git --version
