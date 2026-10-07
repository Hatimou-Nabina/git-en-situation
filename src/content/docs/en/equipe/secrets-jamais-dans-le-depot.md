---
title: Secrets never go into the repository
description: API keys, passwords, tokens. Where they live instead, how a .env ignored from the first commit and a versioned .env.example make a leak unlikely, a ten-line local guard rail, and what GitHub blocks on its side.
level: debutant
gitVersion: "2.50"
verified: 2026-10-05
published: 2026-10-05
sidebar:
  order: 5
---

## What it avoids

An API key pushed to GitHub and exploited within minutes by a bot. A five-figure cloud bill on a Monday morning. The afternoon spent revoking, rewriting the history, forcing the push and asking the whole team to re-clone: that's the situation [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/), and this page exists so that you never have to read it.

A secret is anything that grants access: API key, database password, token, private key, service account file. It lives in the environment of the machine that needs it, never in a file Git tracks.

## How it's done

**1. From the first commit: `.env` ignored, `.env.example` versioned.** The real file stays on each machine; the template, with the names and empty values, tells a newcomer what to fill in.

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

The template's comment, in French, reads "Copy this file to .env and fill in the values. Never commit .env". The `.env` does exist on the disk, with real values, and `git status` doesn't see it. `check-ignore` says which rule applies to each file, including the `!` rule that brings the template back in:

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

**2. The application reads the environment**, and says so clearly when something is missing. An example script, but `process.env.API_KEY`, `os.environ["API_KEY"]` or `System.getenv("API_KEY")` do the same:

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

The script's messages, in French, read "missing. Copy .env.example to .env and fill it in" and "Connecting with key sk-live-...". On the machine, the `.env` is loaded at launch; most frameworks do it on their own (`dotenv`). On the server and in the CI, the variables are set by the platform, and the `.env` doesn't exist.

**3. A local guard rail**, in `.git/hooks/pre-commit`: refuse a `.env` file, even force-added, and any added line that looks like a known secret.

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

The hook's messages, in French, read "Commit refused: .env doesn't belong in the repository (see .env.example)" and "Commit refused: an added line looks like a secret". Same thing for a key hard-coded in the source. The first `config.js` contained `const API_KEY = "sk-live-123456";`, the second `const API_KEY = process.env.API_KEY;`:

```console
$ git commit -m "feat: ajoute la configuration"
Commit refuse : une ligne ajoutee ressemble a un secret.

$ git commit -m "feat: lit la configuration dans l environnement"
[main 7473ce3] feat: lit la configuration dans l environnement
 1 file changed, 1 insertion(+)
 create mode 100644 config.js
```

A hook is not versioned: everyone installs it. For the team, a shared tool like `gitleaks` does the same thing with hundreds of patterns, as a hook and in the CI.

**4. Before making a repository public**, search the whole history, not only the current files: a secret removed six months ago is still in an old commit.

```console
$ git log --all --oneline -S'sk-live-'
```

No line: no commit, on any branch, ever added or removed that string. For a real repository, where you don't know what to look for, `gitleaks detect` walks the history with its patterns.

**5. So where do secrets live?** On the machine, in the ignored `.env`, or better, in a password manager. On the server, in the environment variables set by the hosting platform. In the CI, in the repository's secrets, encrypted and masked in the logs:

```yaml
# .github/workflows/deploy.yml
steps:
  - run: ./deploy.sh
    env:
      API_KEY: ${{ secrets.API_KEY }}
```

## On GitHub

- **Settings → Secrets and variables → Actions**: the repository's secrets, readable by workflows only, never displayed. From the terminal: `gh secret set API_KEY`. "Environments" (production, staging) each have their own.
- **Secret scanning** (Settings → Code security) spots the major providers' keys in what is already pushed, and alerts you. Free on public repositories.
- **Push protection** goes further: a push that contains a recognised secret is refused before it arrives, with the file and the line. It's the net behind the local hook, to enable as soon as the repository is created.
- **Actions logs mask** the values of declared secrets, but not what derives from them: an `echo` of the URL that contains the password shows it in clear.
- **A `.env` in a private repository is still an exposed secret**: every collaborator, every fork, every clone has a copy. Private is not secret.

## Pitfalls

- **The `.gitignore` that arrives after the `.env`**: the file is already tracked, and ignoring it changes nothing. [.gitignore doesn't work, the file is already tracked](/en/situations/fichiers/gitignore-fichier-deja-suivi/).
- **The "real" value put in `.env.example` "for testing"**, then committed. The template contains only names and empty or fake values.
- **The other configuration files**: `settings.json`, `application.properties`, `docker-compose.yml`, a notebook with its output. A secret slips in wherever you configure an access. The pattern to remember: the value comes from the environment, the file contains only the name.
- **Secrets in messages**: a commit, an issue or a PR that pastes a complete connection URL. They can't be rewritten with `filter-repo`.
- **A secret shared by message** (chat, email) to "go fast". It then lingers in histories nobody controls. A shared password manager costs less than a revocation.
- **If it went out anyway**: revoke first, clean up next. [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/), in order.

## See also

- [I pushed a secret by mistake](/en/situations/fichiers/secret-pousse-par-erreur/)
- [.gitignore doesn't work, the file is already tracked](/en/situations/fichiers/gitignore-fichier-deja-suivi/)
- [Two GitHub accounts on the same machine](/en/situations/avec-les-autres/deux-comptes-github-sur-un-poste/), for SSH keys
- [Protecting the main branch](/en/equipe/proteger-la-branche-principale/)

:::tip[Verified outputs]
The outputs on this page come from the script [`scripts/equipe/secrets-jamais-dans-le-depot.sh`](https://github.com/Hatimou-Nabina/git-en-situation/blob/main/scripts/equipe/secrets-jamais-dans-le-depot.sh), run with Git 2.50 on 5 October 2026, hook included. GitHub's settings (Secret scanning, Push protection, Actions secrets) cannot be replayed in a sandbox and are described, not run. Only the commit ids are those of the example repository, whose commit messages are in French.
:::
