#!/usr/bin/env bash
# Travailler en équipe : une CI qui vérifie ce que les postes ne voient pas.
# Page : src/content/docs/equipe/ci-ce-que-les-postes-ne-voient-pas.md
#
# Plusieurs sorties dépendent du système : le bit d'exécution et la casse des
# noms de fichiers n'existent pas sous Windows ni, pour la casse, sur macOS.
# Les sorties de la page viennent du rejeu sur Ubuntu (workflow « Rejouer les
# situations »), comme pour la situation sur les fins de ligne.
source "$(dirname "$0")/../situations/_lib.sh"
setup_team

note "1. Un script qui marche sur ton poste et pas en CI : le bit d'exécution"
quiet_sh awa 'printf "#!/usr/bin/env bash\necho \"deploiement ok\"\n" > deploy.sh && git add deploy.sh && git commit -q -m "feat: ajoute le script de deploiement" && git push -q'
run awa git ls-files -s deploy.sh
run awa bash deploy.sh
quiet bakary git pull -q
run_sh bakary './deploy.sh'
# Sur Linux et macOS, chmod suffit et git add relit le mode ; sous Windows, où le
# bit n'existe pas, update-index l'écrit directement dans l'index. Les deux ensemble
# donnent le même résultat partout.
run awa chmod +x deploy.sh
run awa git update-index --chmod=+x deploy.sh
run awa git ls-files -s deploy.sh
quiet_sh awa 'git commit -q -m "fix: rend deploy.sh executable" && git push -q'
quiet bakary git pull -q
run_sh bakary './deploy.sh'

note "2. La casse des noms : ton poste ferme les yeux, Linux non"
quiet_sh awa 'echo "export function util() {}" > utils.js && printf "import { util } from \"./Utils.js\";\n" > app.js && git add . && git commit -q -m "feat: ajoute app.js" && git push -q'
run awa cat app.js
run_sh awa 'test -f Utils.js && echo "trouve" || echo "introuvable"'
run_sh awa "git ls-files | grep -i '^utils.js$'"

note "3. Un fichier qui n'existe que sur ton poste"
quiet_sh awa 'echo "{ \"cle\": \"locale\" }" > config.local.json && echo "config.local.json" >> .gitignore && printf "const config = require(\"./config.local.json\");\n" > serveur.js && git add .gitignore serveur.js && git commit -q -m "feat: ajoute le serveur" && git push -q'
run awa git status --short
run awa git ls-files --error-unmatch config.local.json
quiet bakary git pull -q
run_sh bakary 'ls config.local.json'

note "4. Les vérifications qui attrapent ça, dans un script que la CI lance"
mkdir -p "$SANDBOX/awa/scripts" "$SANDBOX/awa/.github/workflows"
cat > "$SANDBOX/awa/scripts/verifier.sh" <<'EOF'
#!/usr/bin/env bash
# Ce que les postes ne voient pas, la CI le vérifie à chaque push.
code=0
# 1. Fins de ligne : tout en LF dans le dépôt.
if git ls-files --eol | grep -q 'i/crlf'; then
  echo "Fichiers en CRLF dans le depot :"; git ls-files --eol | grep 'i/crlf'; code=1
fi
# 2. Les scripts shell sont exécutables.
if git ls-files -s -- '*.sh' | grep -qv '^100755'; then
  echo "Scripts sans bit d execution :"; git ls-files -s -- '*.sh' | grep -v '^100755'; code=1
fi
# 3. Pas deux fichiers dont le nom ne diffère que par la casse.
if git ls-files | sort -f | uniq -di | grep -q .; then
  echo "Noms en double a la casse pres :"; git ls-files | sort -f | uniq -di; code=1
fi
exit $code
EOF
cat > "$SANDBOX/awa/.github/workflows/verifier.yml" <<'EOF'
name: Vérifier
on: [push, pull_request]
jobs:
  verifier:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7
      - run: bash scripts/verifier.sh
EOF
quiet_sh awa 'git add scripts .github && git commit -q -m "ci: verifie fins de ligne, bit d execution et casse"'
run awa cat scripts/verifier.sh
run_sh awa 'bash scripts/verifier.sh; echo "code de sortie : $?"'
run awa chmod +x scripts/verifier.sh
run awa git update-index --chmod=+x scripts/verifier.sh
run_sh awa 'bash scripts/verifier.sh; echo "code de sortie : $?"'
run awa cat .github/workflows/verifier.yml

note "Version de Git utilisée"
run awa git --version
