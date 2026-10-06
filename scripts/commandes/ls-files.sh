#!/usr/bin/env bash
# Commandes : git ls-files.
# Page : src/content/docs/commandes/ls-files.mdx
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

# Des fichiers suivis, dont un script exécutable et un fichier en CRLF ; puis
# un fichier nouveau, un ignoré, un modifié, un supprimé du disque.
quiet_sh awa 'mkdir -p src scripts && echo "a" > src/a.js && echo "b" > src/b.js && printf "#!/usr/bin/env bash\necho ok\n" > scripts/run.sh && printf "ligne 1\r\nligne 2\r\n" > ancien.txt && echo "old" > old.js && git add . && git update-index --chmod=+x scripts/run.sh && git commit -q -m "feat: premiere version" && git push -q
echo "*.log" > .gitignore && git add .gitignore && git commit -q -m "chore: ignore les logs"
echo "notes" > notes.txt && echo "x" > debug.log && echo "modifie" >> README.md && rm old.js'

note "Ce que Git suit"
run awa git ls-files
run awa git ls-files src/

note "Ce que l'index sait de chaque fichier : mode, objet, fins de ligne"
run awa git ls-files -s
run awa git ls-files --eol

note "Ce que Git ne suit pas"
run awa git ls-files -o --exclude-standard
run awa git ls-files -o

note "Modifié, supprimé du disque"
run awa git ls-files -m
run awa git ls-files -d

note "Ce fichier est-il suivi ?"
run awa git ls-files --error-unmatch notes.txt
run_sh awa 'git ls-files --error-unmatch README.md && echo "suivi"'

note "Version de Git utilisée"
run awa git --version
