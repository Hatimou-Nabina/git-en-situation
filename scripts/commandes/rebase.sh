#!/usr/bin/env bash
# Commandes : git rebase.
# Page : src/content/docs/commandes/rebase.mdx
#
# Le rebase interactif ouvre un éditeur ; ici GIT_SEQUENCE_EDITOR le remplace
# par une commande, pour que le script tourne sans terminal. La page le dit.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Une branche de trois commits, poussée ; pendant ce temps, main avance.
quiet_sh awa 'git switch -q -c feature/x
echo "x" > x.js && git add . && git commit -q -m "feat(x): ajoute x"
echo "x corrige" > x.js && git commit -q -am "fix typo"
echo "test x" > x.test.js && git add . && git commit -q -m "test(x): couvre x"
git push -q -u origin feature/x'
quiet_sh bakary 'echo "contact" > contact.js && git add . && git commit -q -m "feat(contact): ajoute la page contact" && git push -q'
quiet awa git fetch -q

note "Rejouer sa branche par-dessus main"
run awa git log --oneline --left-right origin/main...feature/x
run awa git rebase origin/main
run awa git log --oneline -5

note "Nettoyer ses commits avant la relecture : -i"
run_sh awa "GIT_SEQUENCE_EDITOR='sed -n /^pick/p' git rebase -i HEAD~3"
run_sh awa "GIT_SEQUENCE_EDITOR='sed -i 2s/^pick/fixup/' git rebase -i HEAD~3"
run awa git log --oneline -4

note "Un conflit : abandonner, ou résoudre et continuer"
quiet_sh bakary 'echo "# Projet, version main" > README.md && git commit -q -am "docs: titre version main" && git push -q'
quiet_sh awa 'git fetch -q && echo "# Projet, version x" > README.md && git commit -q -am "docs(x): titre version x"'
run awa git rebase origin/main
run awa git status --short
run awa git rebase --abort
run awa git status --short
quiet awa git rebase origin/main
quiet_sh awa 'echo "# Projet, versions main et x" > README.md && git add README.md'
run awa git rebase --continue
run awa git log --oneline -5

note "Après un rebase, la branche poussée a changé : --force-with-lease"
run awa git push
run awa git push --force-with-lease

note "Version de Git utilisée"
run awa git --version
