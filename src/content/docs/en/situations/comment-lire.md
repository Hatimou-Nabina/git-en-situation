---
title: How to read a situation
description: Every page in this section follows the same template, from symptom to why. Here is how to use it, and what the outputs shown guarantee.
sidebar:
  order: 0
  label: How to read a situation
---

Every page answers **one** situation, the one you type into a search engine at 6 pm: "my push is rejected", "I still see a deleted branch". They all follow the same plan.

| Part | What you find there |
|---|---|
| **Symptom** | What you see on screen, exact message included. To check you are on the right page. |
| **Diagnosis** | What happened, in two or three sentences. |
| **Solution** | The commands, in order, with their real output. |
| **Why it works** | The piece of mental model that makes it stick, instead of copying. |
| **Pitfalls** | The variants that mislead, and what not to do. |
| **See also** | Neighbouring situations. |

## The badges at the top of the page

- **Level**: *beginner* can be followed without preparation; *intermediate* assumes you are comfortable with branches; *advanced* touches history or configuration.
- **Risk**: *no risk* when nothing can be lost; *reversible* when a way back exists and is explained; *destructive* when a command on the page can lose work. In that case, the page says where and how.
- **Git x.y, verified on …**: the Git version and the date on which the page's commands were actually run.

## The outputs shown are real

No output is written by hand. Every situation has a script in the repository's `scripts/situations/` folder, which replays the scenario in throwaway repositories, with a neutral Git configuration, and prints each command followed by its output. The page copies that result, and a checker replays every script on each change to the site to make sure the pages still match, with the Git version each one declares. The English page shows exactly the same blocks as the French one: Git speaks English in both.

Three simplifications, and only those: the server address is replaced by `github.com:equipe/projet.git`; the commit ids are those of the example repository; and for a command that writes both messages and results, the messages (`Switched to branch…`, `hint:`…) are shown before the results, in a fixed order, whereas your terminal may interleave them differently. The example repository belongs to a French-speaking team: its commit messages and some file names are in French, like « Ajoute la page contact ». On your machine, these details change; everything else must be identical, for the same Git version. If it isn't, [report it](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=signaler-une-erreur.yml): it's precious.

## Try it yourself

Reading a solution and doing it are not the same thing. Every situation ends with a "Try it yourself" callout: the page's script knows how to create the problem on your machine, in a throwaway folder, and stop right after the symptom. It tells you which folder to go to and what to achieve, without giving the command. You fix it, then run the script again without the variable to compare with the solution. You need a clone of the [site's repository](https://github.com/Hatimou-Nabina/git-en-situation) and, on Windows, Git Bash:

```bash
EXERCICE=1 bash scripts/situations/premier-push-no-upstream.sh
```

Nothing is sent anywhere: the "server" is a folder next door, and everything goes away by deleting `exercices/`. The script's messages are in French; the objective it prints is the sentence after « Objectif ».

## Your situation is missing?

[Propose it](https://github.com/Hatimou-Nabina/git-en-situation/issues/new?template=proposer-une-situation.yml), even without knowing the answer. What you saw and what you were trying to do are enough to start.
