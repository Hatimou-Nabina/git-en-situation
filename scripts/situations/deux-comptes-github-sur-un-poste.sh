#!/usr/bin/env bash
# Situation : deux comptes GitHub sur le même poste.
# Page : src/content/docs/situations/avec-les-autres/deux-comptes-github-sur-un-poste.md
#
# Ici, pas de serveur factice : on montre la configuration Git (identité par
# dossier, adresse du dépôt avec un alias SSH). La connexion SSH à GitHub
# elle-même ne peut pas se rejouer dans un bac à sable.
source "$(dirname "$0")/_lib.sh"

# Le bac à sable joue le rôle du dossier personnel : les chemins s'affichent avec « ~ ».
export HOME="$SANDBOX"
clean() { sed -e "s#$SANDBOX_ALT#~#g" -e "s#$SANDBOX#~#g"; }

mkdir -p "$SANDBOX/travail" "$SANDBOX/perso" "$SANDBOX/.ssh"
git init -q "$SANDBOX/travail/projet-client"
git init -q "$SANDBOX/perso/git-en-situation"
quiet perso/git-en-situation git remote add origin git@github.com:Hatimou-Nabina/git-en-situation.git

note "Le problème : une seule identité, celle du compte pro"
run travail/projet-client git config user.email
run perso/git-en-situation git config user.email

note "1. Une identité par dossier"
cat > "$SANDBOX/.gitconfig-perso" <<'EOF'
[user]
	name = Hatimou Nabina
	email = perso@example.com
EOF
run_sh perso/git-en-situation 'cat ~/.gitconfig-perso'
run_sh perso/git-en-situation 'git config --global includeIf."gitdir:~/perso/".path ~/.gitconfig-perso'
run perso/git-en-situation git config user.email
run travail/projet-client git config user.email

note "2. Une clé SSH par compte, et un alias d'hôte"
cat > "$SANDBOX/.ssh/config" <<'EOF'
# Compte pro : l'adresse habituelle
Host github.com
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_ed25519_pro
	IdentitiesOnly yes

# Compte perso : un nom d'hôte inventé, qui pointe vers GitHub avec l'autre clé
Host github.com-perso
	HostName github.com
	User git
	IdentityFile ~/.ssh/id_ed25519_perso
	IdentitiesOnly yes
EOF
run_sh perso/git-en-situation 'cat ~/.ssh/config'

note "3. Les dépôts perso utilisent l'alias"
run perso/git-en-situation git remote -v
run perso/git-en-situation git remote set-url origin git@github.com-perso:Hatimou-Nabina/git-en-situation.git
run perso/git-en-situation git remote -v

note "Version de Git utilisée"
run perso/git-en-situation git --version
