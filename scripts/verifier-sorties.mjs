#!/usr/bin/env node
/**
 * Vérifie que les blocs de terminal des pages correspondent aux sorties de
 * leurs scripts.
 *
 * Chaque page qui montre des sorties cite son script dans l'encadré
 * « Sorties vérifiées ». Ce programme rejoue le script et vérifie que chaque
 * bloc ```console de la page se retrouve tel quel dans la sortie, après avoir
 * retiré les retours chariot et les espaces de fin de ligne. Une page montre
 * un extrait de son script, dans l'ordre qu'elle veut : c'est une inclusion,
 * pas une égalité.
 *
 * Les blocs text, bash et yaml sont cités par nature et ne sont pas vérifiés.
 * Une page sans script (index, à propos, la fiche gh) est ignorée.
 *
 * Usage :
 *   node scripts/verifier-sorties.mjs                  les pages dont gitVersion est celle du git installé
 *   node scripts/verifier-sorties.mjs commandes/log    seulement les pages dont le chemin contient ce texte
 *   node scripts/verifier-sorties.mjs --git-version 2.50
 *   node scripts/verifier-sorties.mjs --toutes         sans tenir compte de la version de Git
 *   node scripts/verifier-sorties.mjs --parallele 2    nombre de scripts rejoués en même temps (4 par défaut)
 * Code de sortie : 0 si tout correspond, 1 sinon.
 */
import { readFileSync, readdirSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const exec = promisify(execFile);
const racine = process.cwd();
const docs = join(racine, 'src', 'content', 'docs');

// Arguments
const options = { gitVersion: null, toutes: false, parallele: 4, filtres: [] };
const args = process.argv.slice(2);
for (let i = 0; i < args.length; i++) {
  if (args[i] === '--git-version') options.gitVersion = args[++i];
  else if (args[i] === '--toutes') options.toutes = true;
  else if (args[i] === '--parallele') options.parallele = Number(args[++i]);
  else options.filtres.push(args[i]);
}

// Version de Git installée, en majeur.mineur
const { stdout: versionBrute } = await exec('git', ['--version']);
const gitInstallee = versionBrute.match(/(\d+\.\d+)/)[1];
const versionCible = options.gitVersion ?? gitInstallee;

// Les pages
function pages(dossier) {
  const resultat = [];
  for (const nom of readdirSync(dossier)) {
    const chemin = join(dossier, nom);
    if (statSync(chemin).isDirectory()) resultat.push(...pages(chemin));
    else if (/\.mdx?$/.test(nom)) resultat.push(chemin);
  }
  return resultat;
}

const normaliser = (texte) =>
  texte
    .replace(/\r/g, '')
    .split('\n')
    .map((l) => l.trimEnd())
    .join('\n');

function analyser(chemin) {
  const texte = readFileSync(chemin, 'utf8');
  const id = relative(docs, chemin).replace(/\\/g, '/').replace(/\.mdx?$/, '');
  const gitVersion = texte.match(/^gitVersion:\s*"?(\d+\.\d+)"?/m)?.[1] ?? null;
  const script = texte.match(/\[`(scripts\/[^`]+\.sh)`\]/)?.[1] ?? null;
  const blocs = [];
  const lignes = texte.replace(/\r/g, '').split('\n');
  for (let i = 0; i < lignes.length; i++) {
    if (lignes[i].trim() !== '```console') continue;
    const contenu = [];
    for (i++; i < lignes.length && !lignes[i].startsWith('```'); i++) contenu.push(lignes[i].trimEnd());
    while (contenu.length && contenu[contenu.length - 1] === '') contenu.pop();
    if (contenu.length) blocs.push(contenu);
  }
  return { id, gitVersion, script, blocs };
}

let toutesLesPages = pages(docs)
  .map(analyser)
  .filter((p) => !p.id.startsWith('en/'))
  .filter((p) => options.filtres.length === 0 || options.filtres.some((f) => p.id.includes(f)));

const sansScript = toutesLesPages.filter((p) => !p.script);
const autreVersion = toutesLesPages.filter((p) => p.script && !options.toutes && p.gitVersion !== versionCible);
const aVerifier = toutesLesPages.filter((p) => p.script && (options.toutes || p.gitVersion === versionCible));

console.log(`Git installé : ${gitInstallee}. Pages à vérifier : ${aVerifier.length} (Git ${options.toutes ? 'toutes versions' : versionCible}).`);
if (autreVersion.length) {
  console.log(`Ignorées, autre version de Git : ${autreVersion.map((p) => `${p.id} (${p.gitVersion})`).join(', ')}.`);
}
if (sansScript.length && options.filtres.length) {
  console.log(`Sans script : ${sansScript.map((p) => p.id).join(', ')}.`);
}

// Rejouer un script et comparer
async function verifier(page) {
  let sortie;
  try {
    const { stdout, stderr } = await exec('bash', [page.script], { cwd: racine, maxBuffer: 16 * 1024 * 1024 });
    sortie = normaliser(stdout + stderr);
  } catch (erreur) {
    return { page, erreurs: [`le script a échoué : ${erreur.message.split('\n')[0]}`] };
  }
  const lignesSortie = new Set(sortie.split('\n'));
  const erreurs = [];
  page.blocs.forEach((bloc, n) => {
    // Un bloc est une suite de commandes. Chaque commande, avec sa sortie,
    // doit se retrouver telle quelle dans la sortie du script, et dans l'ordre :
    // une page peut regrouper des commandes que le script sépare par un titre.
    let position = 0;
    for (const segment of segments(bloc)) {
      const texte = segment.join('\n');
      const trouve = sortie.indexOf(texte, position);
      if (trouve >= 0) {
        position = trouve + texte.length;
        continue;
      }
      const absente = segment.find((l) => !lignesSortie.has(l));
      const ou = sortie.includes(texte) ? 'présente, mais pas dans cet ordre' : absente !== undefined ? `ligne absente de la sortie : « ${absente} »` : 'lignes présentes, mais pas contiguës';
      erreurs.push(`bloc ${n + 1}, « ${segment[0]} » : ${ou}`);
    }
  });
  return { page, erreurs };
}

// Découpe un bloc en segments : une ligne « $ commande » et les lignes de
// sortie qui la suivent. Un bloc sans commande est un seul segment.
function segments(bloc) {
  const resultat = [];
  let courant = [];
  for (const ligne of bloc) {
    if (ligne.startsWith('$ ') && courant.length) {
      resultat.push(courant);
      courant = [];
    }
    courant.push(ligne);
  }
  if (courant.length) resultat.push(courant);
  return resultat.map((s) => {
    while (s.length && s[s.length - 1] === '') s.pop();
    return s;
  });
}

// Quatre scripts à la fois : chacun a son propre bac à sable
const resultats = [];
const file = [...aVerifier];
await Promise.all(
  Array.from({ length: Math.max(1, options.parallele) }, async () => {
    while (file.length) resultats.push(await verifier(file.shift()));
  }),
);
resultats.sort((a, b) => a.page.id.localeCompare(b.page.id, 'fr'));

let blocsVerifies = 0;
let pagesEnEchec = 0;
for (const { page, erreurs } of resultats) {
  blocsVerifies += page.blocs.length;
  if (erreurs.length === 0) {
    console.log(`  ✓ ${page.id} (${page.blocs.length} blocs)`);
  } else {
    pagesEnEchec++;
    console.log(`  ✗ ${page.id}`);
    for (const e of erreurs) console.log(`      ${e}`);
  }
}
console.log(
  pagesEnEchec === 0
    ? `\n${resultats.length} pages, ${blocsVerifies} blocs : tout correspond.`
    : `\n${pagesEnEchec} page(s) sur ${resultats.length} ne correspondent plus à leur script.`,
);
process.exit(pagesEnEchec === 0 ? 0 : 1);
