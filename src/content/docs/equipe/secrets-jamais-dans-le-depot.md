---
title: Les secrets ne vont jamais dans le dépôt
description: Clés d'API, mots de passe, jetons. Où ils vivent à la place, comment un .env ignoré dès le premier commit et un .env.example versionné rendent la fuite improbable, un garde-fou local en dix lignes, et ce que GitHub bloque de son côté.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 5
---

## Ce que ça évite

Une clé d'API poussée sur GitHub et exploitée en quelques minutes par un robot. Une facture cloud à cinq chiffres un lundi matin. L'après-midi passée à révoquer, réécrire l'historique, forcer le push et demander à toute l'équipe de recloner : c'est la situation [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/), et cette page existe pour que tu n'aies jamais à la lire.

Un secret est tout ce qui donne un accès : clé d'API, mot de passe de base de données, jeton, clé privée, fichier de compte de service. Il vit dans l'environnement de la machine qui en a besoin, jamais dans un fichier que Git suit.

## Comment on fait

**1. Dès le premier commit : `.env` ignoré, `.env.example` versionné.** Le vrai fichier reste sur chaque poste ; le modèle, avec les noms et des valeurs vides, dit à un nouveau venu ce qu'il doit remplir.

```console
$ cat .gitignore
.env
.env.*
!.env.example

$ cat .env.example
# Copie ce fichier vers .env et remplis les valeurs. Ne commite jamais .env.
API_KEY=
DATABASE_URL=

$ git status --short
?? .env.example
?? .gitignore
```

Le `.env` existe bien sur le disque, avec de vraies valeurs, et `git status` ne le voit pas. `check-ignore` dit quelle règle s'applique à chaque fichier, y compris la règle `!` qui réintègre le modèle :

```console
$ git check-ignore -v .env .env.local .env.example
.gitignore:1:.env	.env
.gitignore:2:.env.*	.env.local
.gitignore:3:!.env.example	.env.example

$ git ls-files
.env.example
.gitignore
README.md
```

**2. L'application lit l'environnement**, et le dit clairement quand il manque quelque chose. Un script d'exemple, mais `process.env.API_KEY`, `os.environ["API_KEY"]` ou `System.getenv("API_KEY")` font pareil :

```console
$ cat app.sh
#!/usr/bin/env bash
# La cle vient de l'environnement, jamais d'un fichier versionne.
: "${API_KEY:?manquante. Copie .env.example vers .env et remplis-le.}"
echo "Connexion avec la cle ${API_KEY:0:8}..."

$ bash app.sh
app.sh: line 3: API_KEY: manquante. Copie .env.example vers .env et remplis-le.

$ set -a && source .env && set +a && bash app.sh
Connexion avec la cle sk-live-...
```

Sur le poste, le `.env` est chargé au lancement ; la plupart des frameworks le font d'eux-mêmes (`dotenv`). Sur le serveur et dans la CI, les variables sont posées par la plateforme, et le `.env` n'existe pas.

**3. Un garde-fou local**, dans `.git/hooks/pre-commit` : refuser un fichier `.env`, même ajouté de force, et toute ligne ajoutée qui ressemble à un secret connu.

```console
$ cat .git/hooks/pre-commit
#!/usr/bin/env bash
# Refuse un commit qui ajoute un fichier .env, ou une ligne qui ressemble a un secret.
fichiers=$(git diff --cached --name-only | grep -E '(^|/)\.env(\.[^/]+)?$' | grep -Ev '\.env\.example$')
if [ -n "$fichiers" ]; then
  echo "Commit refuse : $fichiers ne va pas dans le depot (voir .env.example)." >&2
  exit 1
fi
if git diff --cached -U0 | grep -E '^\+' | grep -Eq 'sk-live-[A-Za-z0-9]+|AKIA[0-9A-Z]{16}|BEGIN( RSA| OPENSSH)? PRIVATE KEY'; then
  echo "Commit refuse : une ligne ajoutee ressemble a un secret." >&2
  exit 1
fi

$ git add -f .env

$ git commit -m "chore: ajoute la config"
Commit refuse : .env ne va pas dans le depot (voir .env.example).
```

Même chose pour une clé écrite en dur dans le code. Le premier `config.js` contenait `const API_KEY = "sk-live-123456";`, le second `const API_KEY = process.env.API_KEY;` :

```console
$ git commit -m "feat: ajoute la configuration"
Commit refuse : une ligne ajoutee ressemble a un secret.

$ git commit -m "feat: lit la configuration dans l environnement"
[main 7473ce3] feat: lit la configuration dans l environnement
 1 file changed, 1 insertion(+)
 create mode 100644 config.js
```

Un hook n'est pas versionné : chacun l'installe. Pour l'équipe, un outil partagé comme `gitleaks` fait la même chose avec des centaines de motifs, en hook et dans la CI.

**4. Avant de rendre un dépôt public**, chercher dans tout l'historique, pas seulement dans les fichiers actuels : un secret retiré il y a six mois est toujours dans un vieux commit.

```console
$ git log --all --oneline -S'sk-live-'
```

Aucune ligne : aucun commit, sur aucune branche, n'a jamais ajouté ni retiré cette chaîne. Pour un vrai dépôt, où l'on ne sait pas quoi chercher, `gitleaks detect` parcourt l'historique avec ses motifs.

**5. Où vivent les secrets, alors ?** Sur le poste, dans le `.env` ignoré, ou mieux, dans un gestionnaire de mots de passe. Sur le serveur, dans les variables d'environnement posées par la plateforme d'hébergement. Dans la CI, dans les secrets du dépôt, chiffrés et masqués dans les journaux :

```yaml
# .github/workflows/deploy.yml
steps:
  - run: ./deploy.sh
    env:
      API_KEY: ${{ secrets.API_KEY }}
```

## Sur GitHub

- **Settings → Secrets and variables → Actions** : les secrets du dépôt, lisibles par les workflows seulement, jamais affichés. Depuis le terminal : `gh secret set API_KEY`. Les « environments » (production, staging) ont chacun les leurs.
- **Secret scanning** (Settings → Code security) repère les clés des grands fournisseurs dans ce qui est déjà poussé, et t'alerte. Gratuit sur les dépôts publics.
- **Push protection** va plus loin : le push qui contient un secret reconnu est refusé avant d'arriver, avec le fichier et la ligne. C'est le filet derrière le hook local, à activer dès la création du dépôt.
- **Les journaux d'Actions masquent** les valeurs des secrets déclarés, mais pas ce qui en dérive : un `echo` de l'URL qui contient le mot de passe l'affiche en clair.
- **Un `.env` dans un dépôt privé reste un secret exposé** : chaque collaborateur, chaque fork, chaque clone en a une copie. Privé n'est pas secret.

## Pièges

- **Le `.gitignore` arrivé après le `.env`** : le fichier est déjà suivi, et l'ignorer ne change rien. [.gitignore ne marche pas, le fichier est déjà suivi](/situations/fichiers/gitignore-fichier-deja-suivi/).
- **La « vraie » valeur mise dans `.env.example` « pour tester »**, puis commitée. Le modèle ne contient que des noms et des valeurs vides ou fictives.
- **Les autres fichiers de configuration** : `settings.json`, `application.properties`, `docker-compose.yml`, un notebook avec sa sortie. Un secret se glisse partout où on configure un accès. Le motif à retenir : la valeur vient de l'environnement, le fichier ne contient que le nom.
- **Les secrets dans les messages** : un commit, une issue ou une PR qui colle une URL de connexion complète. Ils ne se réécrivent pas avec `filter-repo`.
- **Un secret partagé par message** (chat, mail) pour « aller vite ». Il traîne ensuite dans des historiques que personne ne contrôle. Un gestionnaire de mots de passe partagé coûte moins cher que la révocation.
- **Si malgré tout c'est parti** : révoquer d'abord, nettoyer ensuite. [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/), dans l'ordre.

## Voir aussi

- [J'ai poussé un secret par erreur](/situations/fichiers/secret-pousse-par-erreur/)
- [.gitignore ne marche pas, le fichier est déjà suivi](/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Deux comptes GitHub sur le même poste](/situations/avec-les-autres/deux-comptes-github-sur-un-poste/), pour les clés SSH
- [Protéger la branche principale](/equipe/proteger-la-branche-principale/)

:::tip[Sorties vérifiées]
Les sorties de cette page viennent du script [`scripts/equipe/secrets-jamais-dans-le-depot.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/secrets-jamais-dans-le-depot.sh), exécuté avec Git 2.50 le 5 octobre 2026, hook compris. Les réglages de GitHub (Secret scanning, Push protection, secrets d'Actions) ne se rejouent pas dans un bac à sable et sont décrits, pas exécutés. Seuls les identifiants de commit sont ceux du dépôt d'exemple.
:::
