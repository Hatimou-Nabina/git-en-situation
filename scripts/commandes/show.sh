#!/usr/bin/env bash
# Commandes : git show.
# Page : src/content/docs/commandes/show.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team
quiet_sh awa 'echo "port=80" > config.js && git add . && git commit -q -m "feat(config): ajoute la configuration"
echo "Documentation" >> README.md && git commit -q -am "docs: complete le README"
echo "port=8080" > config.js && echo "Voir config.js" >> README.md && git commit -q -am "fix(config): passe le port a 8080" && git push -q'

note "Le dernier commit : message, bilan, diff"
run awa git show --stat HEAD
run awa git show HEAD -- config.js

note "N'importe quel commit, dans le format qu'on veut"
run_sh awa "git show --no-patch --format='%h %an %ad%n%s' --date=short HEAD~1"
run awa git show --name-only --oneline HEAD~1

note "Un fichier tel qu'il était à un commit"
run awa git show HEAD~2:config.js
run awa git show HEAD:config.js

note "Version de Git utilisée"
run awa git --version
