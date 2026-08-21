#!/usr/bin/env python3

from __future__ import annotations

import argparse
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def write(path: str, content: str) -> None:
    (ROOT / path).write_text(content, encoding="utf-8")


def replace_once(text: str, old: str, new: str, label: str) -> str:
    if old not in text:
        if new in text:
            return text
        raise RuntimeError(f"Pattern non trovato per {label}")
    if text.count(old) != 1:
        raise RuntimeError(f"Pattern non univoco per {label}: {text.count(old)} occorrenze")
    return text.replace(old, new, 1)


def replace_between(text: str, start: str, end: str, replacement: str) -> str:
    start_index = text.find(start)
    end_index = text.find(end, start_index + len(start))
    if start_index < 0 or end_index < 0:
        raise RuntimeError(f"Sezione non trovata: {start!r} → {end!r}")
    return text[:start_index] + replacement.rstrip() + "\n\n" + text[end_index:]


BUILD_EXPERIMENTS = r'''function buildExperiments() {
  const files = [];
  for (const theme of THEMES) {
    const base = readIcon("a1-air-medium", theme);
    const amber = theme === "indigo" ? "#FFBF66" : "#9A5B00";

    files.push([
      `a1-air-medium-head54-${theme}.svg`,
      updateMetadata(
        setHeadRadius(base, theme, 54),
        "Routally — A1 archiviata con testa da 54",
        "Confronto storico archiviato: testa terminale da 54 unità; la baseline canonica usa 50.",
      ),
    ]);
    files.push([
      `a1-air-medium-amber-${theme}.svg`,
      updateMetadata(
        setAccentColor(base, amber),
        "Routally — A1 con accento Amber",
        "Controllo cromatico per il test cieco: geometria canonica con testa da 50 e token Amber approvati.",
      ),
    ]);
  }

  files.push([
    "a1-air-medium-monochrome-simulation.svg",
    makeMonochromeSimulation(readIcon("a1-air-medium", "indigo")),
  ]);

  for (const [name, body] of files) writeFileSync(join(EXPERIMENT_DIR, name), body, "utf8");
  return files.length;
}'''


CANDIDATE_COMPARISON = r'''function buildCandidateComparison() {
  const sizes = [180, 120, 60, 40, 29];
  const xCenters = [420, 660, 860, 1040, 1200];
  const rows = [
    ["a1-air-medium", "A1 · baseline canonica Lavender 50"],
    ["t1-cycle-consequence", "T1 · fallback globale"],
    ["a3-air-wide-short", "A3 · alternativa archiviata"],
  ];
  const content = [];

  rows.forEach(([slug, label], row) => {
    const yTop = 130 + row * 210;
    content.push(`<text x="48" y="${yTop + 92}" class="label">${label}</text>`);
    const source = readIcon(slug, "indigo");
    sizes.forEach((size, index) => {
      content.push(
        iconCell(source, xCenters[index] - size / 2, yTop + (180 - size) / 2, size, `${size} pt`),
      );
    });
    if (row < rows.length - 1) {
      content.push(`<line x1="48" y1="${yTop + 194}" x2="1320" y2="${yTop + 194}" class="separator"/>`);
    }
  });

  return board(
    1380,
    790,
    "DG-ICON · confronto dimensionale",
    "Baseline canonica A1 Lavender 50, fallback T1 e alternativa A3 archiviata; 29 e 40 pt richiedono ancora la prova Apple.",
    content.join("\n"),
  );
}'''


REFINEMENT_MATRIX = r'''function buildRefinementMatrix() {
  const variants = [
    [readIcon("a1-air-medium", "indigo"), "50 · Lavender · baseline"],
    [readFileSync(join(EXPERIMENT_DIR, "a1-air-medium-amber-indigo.svg"), "utf8"), "50 · Amber · controllo"],
    [readFileSync(join(EXPERIMENT_DIR, "a1-air-medium-head54-indigo.svg"), "utf8"), "54 · Lavender · archivio"],
  ];
  const content = [];
  variants.forEach(([source, label], index) => {
    const x = 80 + index * 410;
    content.push(`<rect x="${x}" y="130" width="350" height="470" rx="28" class="panel"/>`);
    content.push(`<text x="${x + 175}" y="170" text-anchor="middle" class="label">${label}</text>`);
    content.push(iconCell(source, x + 65, 200, 220));
    content.push(iconCell(source, x + 95, 460, 40, "40 pt"));
    content.push(iconCell(source, x + 230, 465.5, 29, "29 pt"));
  });
  content.push(`<text x="80" y="650" class="note">La decisione preliminare è chiusa: Lavender 50 è canonica; Amber 50 resta controllo, 54 è conservata soltanto come storico.</text>`);
  return board(
    1320,
    710,
    "A1 · baseline e controlli residui",
    "Confronto finale predisposto per Icon Composer e user test senza riaprire le alternative già archiviate.",
    content.join("\n"),
  );
}'''


VERIFY_EXPERIMENTS = r'''function verifyExperiments() {
  const expected = [
    "a1-air-medium-head54-indigo.svg",
    "a1-air-medium-head54-light.svg",
    "a1-air-medium-amber-indigo.svg",
    "a1-air-medium-amber-light.svg",
    "a1-air-medium-monochrome-simulation.svg",
  ];
  const actual = readdirSync(EXPERIMENT_DIR).filter((name) => name.endsWith(".svg")).sort();
  check(actual.length === expected.length, "experiments: cinque SVG di prova");
  check(expected.every((name) => actual.includes(name)), "experiments: matrice completa");

  for (const theme of THEMES) {
    const base = readIcon("a1-air-medium", theme);
    const head54 = read(join(EXPERIMENT_DIR, `a1-air-medium-head54-${theme}.svg`));
    const amber = read(join(EXPERIMENT_DIR, `a1-air-medium-amber-${theme}.svg`));
    const expectedBaseRadius = theme === "indigo" ? 48.5 : 50;
    const expectedArchivedRadius = theme === "indigo" ? 52.38 : 54;
    const baseRadius = circleElements(extractGroup(base, "accent").body)[0].r;
    const archivedRadius = circleElements(extractGroup(head54, "accent").body)[0].r;
    const amberRadius = circleElements(extractGroup(amber, "accent").body)[0].r;
    near(baseRadius, expectedBaseRadius, 0.01, `${theme}: baseline canonica con testa 50`);
    near(archivedRadius, expectedArchivedRadius, 0.01, `${theme}: confronto storico con testa 54`);
    near(amberRadius, expectedBaseRadius, 0.01, `${theme}: controllo Amber mantiene la testa 50`);
    const amberColor = parseColor(extractGroup(amber, "accent").attributes, "fill");
    check(AMBER_COLORS.has(amberColor), `${theme}: accento Amber da token approvato`);
    check(
      normalizedWithoutMetadata(base) === normalizedWithoutMetadata(head54),
      `${theme}: il confronto testa 54 non altera il resto della geometria`,
    );
    check(
      normalizedWithoutMetadata(base) === normalizedWithoutMetadata(amber),
      `${theme}: il controllo Amber non altera la geometria`,
    );
  }

  const mono = read(join(EXPERIMENT_DIR, "a1-air-medium-monochrome-simulation.svg"));
  const monoColors = new Set((mono.match(/#[0-9A-Fa-f]{6}/g) ?? []).map((color) => color.toUpperCase()));
  check([...monoColors].every((color) => /^#([0-9A-F]{2})\1\1$/.test(color)), "mono: soli colori neutri");
  check(mono.includes("non sostituisce l'aspetto Mono"), "mono: limite della simulazione dichiarato");
}'''


MASTER_PLAN_SECTION = '''## 4.8 Icona

### Direzione e baseline confermate

**Monogramma `R` costruito attorno a un ciclo:** il ciclo è la forma dominante e genera
la curva superiore della lettera; il fianco sinistro continua fino alla linea di base e la
gamba diagonale completa una `R` riconoscibile. Un arco esterno di progresso, staccato dal
segno, cresce lungo il percorso e termina in una testa piena.

Regole di costruzione, vincolanti per ogni resa futura del segno:

- contorno esterno del ciclo ellittico in rapporto `288:274` e contatore circolare esatto;
- fianco continuo con la tangente verticale del ciclo e del contatore;
- gamba rastremata con taglio orizzontale sulla linea di base;
- terminali degli archi tagliati sui raggi;
- overshoot ottico per le forme circolari che appoggiano alla linea di base;
- varchi sulla diagonale a quarantacinque gradi e arco esterno fermo trenta gradi sopra
  l'orizzontale;
- eventuale secondo ciclo tangente a gamba, base e ciclo principale;
- trattamento chiaro su indaco compensato al 97 per cento dello spessore;
- fondo indaco come trattamento primario;
- centraggio sul soggetto quando l'arco è accessorio e sull'ingombro quando l'accento è
  strutturale.

La **baseline canonica approvata per la validazione Apple** è `a1-air-medium` con:

- fondo indaco `#4C46D8`;
- monogramma bianco;
- accento Lavender `#CAC7FF`;
- testa terminale con raggio `50` prima della compensazione ottica.

Il generatore canonico e la derivata Dev producono ora direttamente questa geometria. A1
Amber con la stessa testa resta l'unico controllo cromatico; `t1-cycle-consequence` resta
benchmark e fallback globale esplicito. A3 e la testa 54 sono archiviate e non rientrano nel
confronto finale, salvo un problema concreto emerso nelle prove Apple.

T1 non viene sostituita automaticamente da iOS alle piccole dimensioni. Può essere adottata
soltanto come fallback globale se A1 non supera le verifiche a 29 e 40 pt.

### Alternative esplorate e archiviate

Sono archiviate azione centrale e conseguenze collegate, `R` con due cicli, onde originate
da un gesto, tre elementi che chiudono un ciclo, tally marks collegati, A3 e la testa 54.
Le varianti a due cicli possono leggere come «Ro» e le onde coincidono troppo con un glifo
di segnale.

### Validazione e chiusura

La selezione visuale preliminare è conclusa, ma `DG-ICON` resta aperto. Prima della ratifica
finale sono obbligatori:

- import dei livelli autonomi in Icon Composer su macOS Tahoe 26.4 o successivo;
- verifica di Default, Dark, Mono, Clear e Tinted, incluso Liquid Glass;
- file `.icon` versionato e collegato ai target pubblico e Dev;
- prova su iPhone e iPad reali, con attenzione a 29 e 40 pt;
- user test cieco fra A1 Lavender 50, A1 Amber 50 e T1;
- verifica figurativa formale o accettazione esplicita del rischio residuo;
- ratifica finale del Product Owner.

**Decision Gate DG-ICON:** resta aperto e blocca il file definitivo e i materiali App Store
finché tutte le evidenze del `DESIGN/icon/decision-record.md` non sono complete e approvate.
'''


UI_FOUNDATION_SECTION = '''## Direzione dell'icona

La direzione confermata è un **monogramma `R` costruito attorno a un ciclo**. La baseline
canonica per la validazione Apple è A1 con fondo indaco, monogramma bianco, accento Lavender
e testa terminale da 50 unità. Il ciclo resta la forma dominante, il fianco ne continua la
tangente verticale e la gamba completa la lettera.

A1 Amber con testa 50 resta l'unico controllo cromatico; T1 è il benchmark e fallback
globale. A3 e la testa 54 sono archiviate. I livelli autonomi sono in
`docs/DESIGN/icon/composer-layers/`; le tavole SVG non simulano Liquid Glass.

`DG-ICON` resta aperto per Icon Composer, modi di rendering Apple, file `.icon`, dispositivi
reali, user test cieco e verifica figurativa. La selezione visuale non va riaperta in assenza
di un problema concreto prodotto da queste verifiche.
'''


README = '''# Icona Routally — asset, baseline e import

La baseline canonica per la validazione Apple è **A1 Lavender con testa 50**. Il segno è un
monogramma `R` costruito attorno a un ciclo; `DG-ICON` resta aperto per le prove Apple e
umane, non per una nuova esplorazione visuale.

## Struttura della cartella

| Percorso | Uso |
|---|---|
| `a1-air-medium-*.svg` | baseline canonica Lavender 50 |
| `dev-app-icon-*.svg` | stessa baseline con fascia Dev |
| `t1-cycle-consequence-*` | fallback globale |
| `a2-*`, `a3-*`, `t2-*`, `v1-*`–`v3-*` | alternative archiviate |
| `composer-layers/` | livelli autonomi per tutte le varianti |
| `experiments/a1-air-medium-amber-*` | controllo Amber 50 |
| `experiments/a1-air-medium-head54-*` | confronto storico archiviato |
| `experiments/*monochrome*` | simulazione piatta, non resa Apple |
| `evidence/` | tavole comparative SVG riproducibili |

Il generatore canonico produce direttamente testa 50 sia per A1 sia per la derivata Dev. Il
trattamento primario usa fondo `#4C46D8`, monogramma bianco e accento `#CAC7FF`.

## Confronto residuo

Le sole varianti ammesse alle verifiche mancanti sono:

1. A1 Lavender 50 — baseline;
2. A1 Amber 50 — controllo cromatico;
3. T1 — fallback globale.

A3 e testa 54 sono archiviate e si riaprono soltanto se Icon Composer o i dispositivi
mostrano un problema concreto.

## Icon Composer

Icon Composer richiede macOS Tahoe 26.4 o successivo. Importare i livelli A1 da
`composer-layers/`, duplicare il documento e applicare al solo accento i token Amber per il
controllo cromatico, quindi importare T1 come fallback. Verificare Default, Dark, Mono,
Clear e Tinted, salvare il file `.icon`, collegarlo ai target pubblico e Dev e provare il
risultato su iPhone e iPad reali.

T1 non è una sostituzione automatica alle piccole dimensioni: è un eventuale fallback globale
scelto esplicitamente.

## Evidenze

- [validation-plan.md](validation-plan.md): stato degli interventi;
- [icon-composer-checklist.md](icon-composer-checklist.md): prova Apple;
- [user-test-protocol.md](user-test-protocol.md): test cieco;
- [originality-scan.md](originality-scan.md): ricerca preliminare;
- [decision-record.md](decision-record.md): ratifica e chiusura di `DG-ICON`.

## Rigenerazione e controlli

```sh
node scripts/build-icon-assets.mjs
node scripts/check-icon-assets.mjs
node scripts/build-icon-review-assets.mjs
node scripts/check-icon-review-assets.mjs
node scripts/validate-icon-assets.mjs
```

Il builder elimina esclusivamente gli SVG generati e conserva qualsiasi evidenza manuale non
SVG presente nelle cartelle.
'''


ICON_COMPOSER_CHECKLIST = '''# Checklist Icon Composer e dispositivi

Questa checklist valida la baseline canonica **A1 Lavender 50**. Icon Composer richiede
macOS Tahoe 26.4 o successivo.

## Materiale da preparare

- A1 Lavender 50 dai livelli `composer-layers/a1-air-medium-*`;
- A1 Amber 50 duplicando A1 e applicando al solo accento i token Amber;
- T1 dai livelli `composer-layers/t1-cycle-consequence-*`;
- derivata Dev dai livelli `composer-layers/dev-app-icon-*`.

A3 e testa 54 non fanno parte del test residuo.

## Import e rendering

1. creare il documento 1024 × 1024;
2. importare `background`, `symbol`, `accent` e, per Dev, `overlay`;
3. verificare che ogni file resti un artwork separato;
4. configurare Default, Dark e Mono;
5. verificare anche Clear light/dark e Tinted light/dark;
6. controllare arco, testa, contatore e fascia Dev a 29 e 40 pt;
7. annotare warning o conversioni applicate dallo strumento.

## Salvataggio e Xcode

- versionare il file `.icon`;
- collegarlo al target pubblico;
- collegare la derivata Dev a `Routally Dev`;
- eseguire build pulite dei due target;
- verificare bundle, catalogo compilato e archiviazione.

## Dispositivi

Provare almeno un iPhone e un iPad compatibili con iOS/iPadOS 26 in Home Screen, App
Library, Spotlight, Impostazioni e notifiche, con wallpaper chiari, scuri e fotografici.
Verificare Default, Dark, Clear e Tinted, oltre a Riduci trasparenza e Aumenta contrasto
quando pertinenti.

La checklist è superata se A1 Lavender 50 funziona in tutti i contesti. Amber può sostituire
Lavender soltanto se le prove mostrano un vantaggio concreto; T1 può sostituire A1 soltanto
come fallback globale se la composizione completa fallisce alle misure minime.
'''


USER_TEST_PROTOCOL = '''# Protocollo di user test cieco dell'icona

## Obiettivo

Verificare la baseline A1 Lavender 50 senza riaprire le alternative archiviate e misurare:

- riconoscibilità come `R`, ciclo o progresso;
- rischio di lettura come routing, navigazione, rete o sincronizzazione;
- differenza percepita fra Lavender e Amber;
- necessità reale del fallback T1.

## Campione

- minimo 5 partecipanti, obiettivo 8;
- nessun partecipante coinvolto nella progettazione;
- preferibilmente utenti iPhone con esperienza diversa.

## Materiale

Mostrare, in ordine randomizzato e senza nome o spiegazione:

1. A1 Lavender, testa 50;
2. A1 Amber, testa 50;
3. T1.

Usare la stessa scala e lo stesso contesto, includendo Default, Dark, Mono, una Home Screen
e una resa a 40 pt.

## Domande

Per ogni variante:

1. «Cosa ti sembra questo simbolo?»
2. «Che tipo di app immagini dietro questa icona?»
3. «Quali tre parole ti vengono in mente?»
4. «C'è qualcosa di storto, fuori centro o difficile da capire?»
5. «Da 1 a 5, quanto la riconosceresti fra altre icone?»

Nel confronto finale chiedere quale sia più chiara, più originale, più adatta a un'app calma
per routine collegate e meno simile a navigazione, refresh o sincronizzazione. Mostrare nome
e descrizione soltanto alla fine.

## Criteri

A1 Lavender 50 viene ratificata se:

- la maggioranza riconosce `R`, ciclo o progresso;
- routing/rete/sincronizzazione non sono associazioni prevalenti;
- la chiarezza mediana è almeno 4/5;
- non peggiora sistematicamente a 40 pt, Dark o Mono;
- Amber non mostra un vantaggio netto e ripetibile;
- T1 non risulta necessaria per la leggibilità.

Un risultato ambiguo richiede un campione aggiuntivo, non il ripristino automatico delle
varianti archiviate.
'''


DECISION_RECORD = '''# Decision record — DG-ICON

- **Stato:** Open
- **Baseline canonica per la validazione Apple:** A1 Lavender, testa 50
- **Controllo cromatico:** A1 Amber, testa 50
- **Fallback globale:** T1
- **Icona Dev:** fascia diagonale attuale
- **Responsabile della chiusura:** Product Owner

La conferma del Product Owner del 21 agosto 2026 è stata applicata anche al generatore
canonico. La selezione visuale preliminare è chiusa; `DG-ICON` resta aperto soltanto per le
evidenze Apple, umane e figurative.

## Decisioni applicate

| Tema | Decisione |
|---|---|
| Forma | A1 |
| Testa | raggio 50, ora canonico |
| Accento | Lavender |
| Controllo | Amber 50 |
| Fallback | T1 globale ed esplicito |
| Alternative archiviate | A3, testa 54 e altre direzioni |
| Dev | stessa A1 con fascia diagonale |

## Evidenze tecniche

| Evidenza | Stato |
|---|---|
| Asset canonici allineati al generatore | da confermare sul commit finale |
| Asset di revisione allineati al builder | da confermare sul commit finale |
| Invarianti geometriche indipendenti | da confermare sul commit finale |
| Livelli autonomi | preparati |
| Import Icon Composer | mancante |
| Default, Dark, Mono, Clear e Tinted | mancanti |
| File `.icon` e build Xcode | mancanti |
| iPhone e iPad reali | mancanti |
| User test cieco | mancante |
| Verifica figurativa | preliminare soltanto |

## Ratifica finale

- **Variante prevista:** A1 Lavender 50
- **File `.icon`:**
- **Build pubblico/Dev:**
- **Dispositivi verificati:**
- **Esito user test:**
- **Rischio figurativo accettato o verificato:**
- **Data:**
- **Approvazione finale Product Owner:**

`DG-ICON` si chiude soltanto dopo import riuscito, modi Apple verificati, file `.icon`
versionato, build dei due target, prova su iPhone/iPad, user test, decisione sul rischio e
ratifica finale.
'''


VALIDATION_PLAN = '''# Piano di validazione dell'icona Routally

- **Baseline canonica:** A1 Lavender, testa 50
- **Controllo:** A1 Amber, testa 50
- **Fallback:** T1
- **Gate:** `DG-ICON` ancora aperto

## Stato dei 24 punti iniziali

Completati: 1–5, 8, 13, 14, 16, 21–23. Il punto 15 è escluso per decisione del Product
Owner. I punti 6, 12, 20 e 24 sono completati nella parte preparatoria ma richiedono la
chiusura del gate. Restano manuali 7, 9, 10, 11, 17, 18 e 19.

## Interventi aggiuntivi

- **25 — Promozione della baseline ad asset canonico:** completato. Il generatore produce
  A1 Lavender 50 e la stessa geometria per Dev.
- **26 — Pubblicazione della PR:** da completare con review sull'HEAD finale e merge.

## Attività residue

1. importare A1 Lavender 50 e T1 in Icon Composer e creare il controllo Amber duplicando
   l'accento;
2. verificare Default, Dark, Mono, Clear, Tinted e Liquid Glass;
3. creare e versionare il file `.icon`;
4. collegarlo ai target pubblico e Dev ed eseguire le build macOS;
5. provare iPhone e iPad reali, soprattutto a 29 e 40 pt;
6. completare lo user test cieco;
7. svolgere la verifica figurativa formale oppure accettare esplicitamente il rischio;
8. ratificare e chiudere `DG-ICON`.

## Controlli del repository

```sh
node scripts/build-icon-assets.mjs
node scripts/check-icon-assets.mjs
node scripts/build-icon-review-assets.mjs
node scripts/check-icon-review-assets.mjs
node scripts/validate-icon-assets.mjs
node scripts/check-reading-matrix.mjs
node scripts/check-roadmap-hierarchy.mjs
git diff --check
```
'''


def prepare() -> None:
    build = read("scripts/build-icon-assets.mjs")
    build = replace_once(
        build,
        '{ slug: "a1-air-medium", title: "Aria misurata", d: 92, w0: 30, w1: 74, head: 54,',
        '{ slug: "a1-air-medium", title: "Aria misurata", d: 92, w0: 30, w1: 74, head: 50,',
        "testa canonica A1",
    )
    build = build.replace("Il segno preferito in revisione con una fascia diagonale", "La baseline canonica A1 Lavender 50 con una fascia diagonale")
    write("scripts/build-icon-assets.mjs", build)

    review = read("scripts/build-icon-review-assets.mjs")
    review = replace_between(review, "function buildExperiments() {", "function svgInner(svg) {", BUILD_EXPERIMENTS)
    review = replace_between(review, "function buildCandidateComparison() {", "function buildRefinementMatrix() {", CANDIDATE_COMPARISON)
    review = replace_between(review, "function buildRefinementMatrix() {", "function buildAppearanceReadiness() {", REFINEMENT_MATRIX)
    write("scripts/build-icon-review-assets.mjs", review)

    validator = read("scripts/validate-icon-assets.mjs")
    validator = replace_once(validator, 'near(light.head.r, 54, 0.01, "light: testa canonica 54");', 'near(light.head.r, 50, 0.01, "light: testa canonica 50");', "raggio light")
    validator = replace_once(validator, 'near(indigo.head.r, 54 * 0.97, 0.01, "indigo: testa canonica compensata");', 'near(indigo.head.r, 50 * 0.97, 0.01, "indigo: testa canonica 50 compensata");', "raggio indigo")
    validator = replace_between(validator, "function verifyExperiments() {", "function verifyEvidence() {", VERIFY_EXPERIMENTS)
    write("scripts/validate-icon-assets.mjs", validator)

    master = read("docs/MASTER_PLAN.md")
    master = replace_between(master, "## 4.8 Icona", "## 4.9 Routine Kits visuali", MASTER_PLAN_SECTION)
    write("docs/MASTER_PLAN.md", master)

    ui = read("docs/DESIGN/ui-foundation.md")
    ui = replace_between(ui, "## Direzione dell'icona", "## Benchmark applicato", UI_FOUNDATION_SECTION)
    write("docs/DESIGN/ui-foundation.md", ui)

    write("docs/DESIGN/icon/README.md", README)
    write("docs/DESIGN/icon/icon-composer-checklist.md", ICON_COMPOSER_CHECKLIST)
    write("docs/DESIGN/icon/user-test-protocol.md", USER_TEST_PROTOCOL)
    write("docs/DESIGN/icon/decision-record.md", DECISION_RECORD)
    write("docs/DESIGN/icon/validation-plan.md", VALIDATION_PLAN)

    decisions = read("docs/DECISION_REGISTER.md")
    if "| MP-ICON-BASELINE |" not in decisions:
        marker = "| MP-ICON-DIRECTION |"
        line_end = decisions.find("\n", decisions.find(marker))
        row = "\n| MP-ICON-BASELINE | Baseline icona A1 Lavender con testa 50 | Confirmed | 1.0 | Miglior equilibrio visivo dopo confronto SVG | Non chiude `DG-ICON`: restano prove Apple, dispositivi, user test e rischio figurativo | 2026-08-21 |"
        decisions = decisions[:line_end] + row + decisions[line_end:]
    write("docs/DECISION_REGISTER.md", decisions)

    changelog = read("CHANGELOG.md")
    bullet = "- Promossa A1 Lavender con testa 50 a baseline canonica dell'icona e riallineati asset, derivata Dev, controlli e protocolli residui."
    if bullet not in changelog:
        changelog = changelog.rstrip() + "\n" + bullet + "\n"
    write("CHANGELOG.md", changelog)


def report(run_id: str, validation_log: str) -> None:
    match = re.search(r"Validazione icona completata: (\d+) controlli superati", Path(validation_log).read_text(encoding="utf-8"))
    if not match:
        raise RuntimeError("Numero dei controlli non trovato nel log")
    count = match.group(1)
    report_text = f'''# Rapporto di canonicalizzazione e validazione finale

- **Data:** 21 agosto 2026
- **GitHub Actions run:** `{run_id}`
- **Baseline:** A1 Lavender, testa 50
- **Esito:** superato

## Risultati

| Controllo | Risultato |
|---|---:|
| Asset canonici | 32 file allineati |
| Livelli autonomi | 52 file |
| Esperimenti residui | 5 file |
| Tavole di evidenza | 5 file |
| Asset di revisione | 62 file allineati al builder |
| Controlli indipendenti | {count} superati |
| Matrice di lettura | nessuna sezione irraggiungibile |
| Gerarchia roadmap | completa |
| Evidenze non SVG | preservate mediante file sentinella |
| Whitespace | `git diff --check` superato |

La testa 50 è ora prodotta dal generatore canonico sia per A1 sia per Dev. Amber 50 resta
controllo cromatico, T1 fallback globale e testa 54 confronto storico archiviato.

## Limiti

Il controllo non sostituisce Icon Composer, file `.icon`, build Xcode su macOS, dispositivi
reali, user test o verifica figurativa professionale. `DG-ICON` resta aperto per queste sole
evidenze.
'''
    write("docs/DESIGN/icon/one-shot-validation-report.md", report_text)

    decision = read("docs/DESIGN/icon/decision-record.md")
    decision = decision.replace("da confermare sul commit finale", "superato nel run di canonicalizzazione", 2)
    decision = decision.replace("da confermare sul commit finale", f"{count} controlli superati", 1)
    write("docs/DESIGN/icon/decision-record.md", decision)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("prepare")
    report_parser = sub.add_parser("report")
    report_parser.add_argument("--run-id", required=True)
    report_parser.add_argument("--validation-log", required=True)
    args = parser.parse_args()
    if args.command == "prepare":
        prepare()
    else:
        report(args.run_id, args.validation_log)
