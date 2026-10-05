#!/usr/bin/env bash
# Situation : mes scripts cassent sur le serveur à cause des fins de ligne.
# Page : src/content/docs/situations/fichiers/fins-de-ligne-crlf-lf.md
source "$(dirname "$0")/_lib.sh"
setup_team

# À rejouer sur Linux. Sous Windows, le bash de Git Bash tolère les CRLF dans un
# script : l'erreur montrée dans la page n'y apparaît pas. Le workflow GitHub
# Actions « Rejouer une situation » exécute ce script sur Ubuntu.
run_linux() { run "$@"; }

note "Un script écrit sous Windows, avec des fins de ligne CRLF"
quiet_sh awa 'printf "#!/usr/bin/env bash\r\n\r\necho \"Deploiement en cours\"\r\nls deploy.sh\r\n" > deploy.sh'
run_sh awa 'od -c deploy.sh | head -3'

note "Sur le serveur Linux, le même script"
run_linux awa bash deploy.sh

note "Commité tel quel, il arrive cassé sur le serveur"
run_sh awa 'git add deploy.sh && git commit -q -m "Ajoute le script de deploiement"'
run awa git ls-files --eol deploy.sh

note "Solution : imposer LF dans le dépôt, pour tout le monde"
run_sh awa 'printf "* text=auto eol=lf\n" > .gitattributes'
run awa git add --renormalize .
run awa git status --short
run awa git ls-files --eol deploy.sh
run_sh awa 'git commit -q -m "Fins de ligne LF pour tout le depot"'
run_sh awa 'rm deploy.sh && git checkout -- deploy.sh'
run awa git ls-files --eol deploy.sh

note "Sur le serveur Linux, après correction"
run_linux awa bash deploy.sh

note "Version de Git utilisée"
run awa git --version
