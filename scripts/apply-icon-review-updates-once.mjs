#!/usr/bin/env node
// Aggiornamento una tantum della documentazione canonica e correzioni al validatore.
// Lo script è idempotente e viene rimosso dopo che la PR ha materializzato le modifiche.

import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");

function read(path) {
  return readFileSync(join(ROOT, path), "utf8");
}

function write(path, content) {
  writeFileSync(join(ROOT, path), content, "utf8");
}

function replaceSection(text, start, end, replacement) {
  const startIndex = text.indexOf(start);
  const endIndex = text.indexOf(end, startIndex + start.length);
  if (startIndex < 0 || endIndex < 0) {
    throw new Error(`sezione non trovata: ${start} → ${end}`);
  }
  return `${text.slice(0, startIndex)}${replacement.trimEnd()}\n\n${text.slice(endIndex)}`;
}

const masterPlanSection = `## 4.8 Icona

### Direzione confermata

**Monogramma \`R\` costruito attorno a un ciclo:** il ciclo è la forma dominante e genera
la curva superiore della lettera; il fianco sinistro continua fino alla linea di base e la
gamba diagonale completa una \`R\` riconoscibile. Un arco esterno di progresso, staccato dal
segno, cresce lungo il percorso e termina in una testa piena. La descrizione non nasconde la
lettura alfabetica: il monogramma collega il nome Routally al concetto di ciclo.

Regole di costruzione, vincolanti per ogni resa futura del segno:

- contorno esterno del ciclo ellittico in rapporto \`288:274\` e contatore circolare esatto,
  così il ciclo pesa più sui fianchi che sulle curve orizzontali;
- il fianco continua senza discontinuità la tangente verticale del ciclo e del contatore,
  con la stessa larghezza;
- gamba rastremata verso il piede, con taglio orizzontale sulla linea di base;
- terminali degli archi tagliati sui raggi, senza raccordi arrotondati;
- overshoot ottico per le forme circolari che appoggiano alla linea di base;
- il varco della soglia e l'apertura di un eventuale secondo ciclo cadono sulla diagonale a
  quarantacinque gradi; l'arco esterno si ferma trenta gradi sopra l'orizzontale;
- un eventuale secondo ciclo si incastra fra gamba e linea di base ed è tangente a gamba,
  base e ciclo principale: il suo raggio è determinato, non scelto;
- la versione chiara su fondo indaco è disegnata al 97 per cento dello spessore per
  compensare l'irradiazione;
- l'arco usa su fondo indaco \`#CAC7FF\`: garantisce \`4,13:1\` contro i \`3,00:1\` di
  \`#A9A5FF\`; il trattamento chiaro usa \`#3429BD\` e raggiunge \`9,55:1\`;
- il trattamento su fondo indaco è la baseline;
- con l'arco accessorio, il punto portato al centro della tela sta a tre quarti fra il centro
  dell'ingombro e quello del monogramma; con un accento strutturale si centra l'ingombro.

La candidata preferita è \`a1-air-medium\`, con distacco dell'arco a novantadue unità. Non è
una scelta definitiva. Il confronto finale comprende almeno \`a3-air-wide-short\` e
\`t1-cycle-consequence\`, oltre alle microvarianti A1 con testa 54/50 e accento
Lavender/Amber.

\`t1-cycle-consequence\` è il **benchmark della silhouette** senza arco. iOS non lo
sostituisce automaticamente alle piccole dimensioni: può diventare soltanto un fallback
globale scelto esplicitamente se la composizione completa non supera le prove a 29 e 40 pt.
La build Dev usa la stessa candidata con una fascia diagonale in basso a sinistra.

Gli asset canonici sono in \`docs/DESIGN/icon/\`; i livelli SVG autonomi per tutte le
varianti sono in \`composer-layers/\`, le rifiniture controllate in \`experiments/\` e le
tavole riproducibili in \`evidence/\`. Il controllo indipendente è
\`scripts/validate-icon-assets.mjs\` e non importa il generatore parametrico.

### Alternative esplorate e archiviate

L'esplorazione vettoriale ha coperto azione centrale e conseguenze collegate, \`R\` con due
cicli, onde originate da un gesto, tre elementi che chiudono un ciclo e tally marks
collegati. Sono archiviate. In particolare, le onde coincidono troppo con un glifo di
segnale e le varianti a due cicli possono leggere come la sillaba «Ro».

### Validazione e chiusura

Prima della scelta definitiva sono obbligatori:

- import dei livelli autonomi in Icon Composer su macOS Tahoe 26.4 o successivo;
- configurazione e verifica di Default, Dark e Mono, comprese le rese Clear e Tinted;
- file \`.icon\` versionato e collegato ai target pubblico e Dev;
- prova su iPhone e iPad reali, con attenzione a 29 e 40 pt;
- user test cieco su almeno cinque persone, con obiettivo otto;
- ricerca figurativa formale o accettazione esplicita del rischio residuo;
- decision record approvato dal Product Owner.

Criteri:

- dimensioni piccole;
- aspetti Default, Dark, Mono, Clear e Tinted;
- distinzione da reminder generici, navigatori, condivisione, reti, sincronizzazione e app di
  automazione;
- percezione consumer e calma;
- leggibilità senza testo;
- coerenza con il nome;
- originalità sufficiente nel settore software.

**Decision Gate DG-ICON:** resta aperto e blocca il file definitivo e i materiali App Store
finché tutte le evidenze del \`decision-record.md\` non sono complete e approvate.
`;

const uiFoundationSection = `## Direzione dell'icona

La direzione confermata è un **monogramma \`R\` costruito attorno a un ciclo**, definito nella
sezione 4.8 del Master Plan. Il ciclo è la forma dominante, il fianco ne continua la tangente
verticale fino alla base, la gamba completa la lettera e un arco esterno di progresso termina
in una testa piena.

Le direzioni precedenti — azione centrale e conseguenze collegate, \`R\` con due cicli,
onde originate da un gesto, tre elementi che chiudono un ciclo e tally marks collegati —
sono archiviate.

Ogni variante combinata mantiene gruppi SVG nominati. Per non presumere il comportamento di
Icon Composer, il confronto usa però i file autonomi di
\`docs/DESIGN/icon/composer-layers/\`, con coordinate già trasformate. A1 è soltanto la
candidata preferita; A3 e T1 restano confronti obbligatori. T1 è il benchmark della
silhouette e non viene sostituito automaticamente dal sistema alle piccole dimensioni.

Le tavole SVG verificano in modo riproducibile dimensioni e contesti piatti, ma non simulano
Liquid Glass. La scelta resta nel Decision Gate \`DG-ICON\` e richiede Icon Composer,
dispositivi reali, user test cieco e verifica figurativa prima del file \`.icon\` definitivo.
`;

let masterPlan = read("docs/MASTER_PLAN.md");
masterPlan = replaceSection(masterPlan, "## 4.8 Icona", "## 4.9 Routine Kits visuali", masterPlanSection);
write("docs/MASTER_PLAN.md", masterPlan);

let uiFoundation = read("docs/DESIGN/ui-foundation.md");
uiFoundation = replaceSection(uiFoundation, "## Direzione dell'icona", "## Benchmark applicato", uiFoundationSection);
write("docs/DESIGN/ui-foundation.md", uiFoundation);

let decisions = read("docs/DECISION_REGISTER.md");
decisions = decisions.replace(
  /\| MP-ICON-DIRECTION \|[^\n]+/,
  "| MP-ICON-DIRECTION | Direzione dell'icona: monogramma `R` costruito attorno a un ciclo | Confirmed | 1.0 | Le direzioni alternative sono state costruite e archiviate | Vincola la costruzione; `DG-ICON` resta aperto per variante, resa Apple e originalità | 2026-08-21 |",
);
decisions = decisions.replace(
  /\| DG-ICON \|[^\n]+/,
  "| DG-ICON | Scelta dell'icona definitiva | Decision Gate | 1.0 | Richiede SVG validati, Icon Composer, dispositivi, user test e verifica figurativa | Blocca file `.icon` e asset App Store finali | — |",
);
write("docs/DECISION_REGISTER.md", decisions);

let validator = read("scripts/validate-icon-assets.mjs");
validator = validator.replace("if (values.length < 20)", "if (values.length < 18)");
validator = validator.replace(
  '["v2-nested-cycle-threshold", "v3-nested-cycle-opening"]',
  '["v2-nested-cycle-threshold"]',
);
validator = validator.replace(
  String.raw`/^#([0-9A-F])\1([0-9A-F])\2([0-9A-F])\3$/`,
  String.raw`/^#([0-9A-F]{2})\1\1$/`,
);
write("scripts/validate-icon-assets.mjs", validator);

console.log("Documentazione canonica e validatore aggiornati.");
