# Piano di validazione dell'icona Routally

- **Baseline canonica:** A1 Lavender, testa 50
- **Fallback:** T1
- **Gate:** `DG-ICON` ancora aperto

## Stato storico

La selezione visuale e la canonicalizzazione SVG sono concluse. Il run originario ha
validato A1 Lavender 50, il controllo Amber 50, il fallback T1, la derivata Dev e le
invarianti geometriche. Generatori, alternative e tavole di quel laboratorio restano
nella cronologia Git; nel repository corrente rimangono soltanto i pacchetti `.icon` di
prodotto e il fallback T1.

Import A1 e derivata Dev, configurazione Liquid Glass, specializzazioni Dark e Mono,
controllo a 29/40 pt, collegamento esclusivo ai rispettivi target, build Simulator
pubblico/Dev e verifica Clear/Tinted sulla Home Screen di iOS Simulator 26.5 sono
completati. Queste attività chiudono la quota `E03` / `M01`; non costituiscono ratifica
anticipata.

## Attività residue

Le attività residue non appartengono alla Foundation e non vanno anticipate:

1. `E20` / `M10` Alpha — provare la build feature-complete su iPhone e iPad reali,
   soprattutto a 29 e 40 pt;
2. `E20` / `M10` Alpha — completare lo user test cieco;
3. `E21` / `M11` Beta — svolgere la verifica figurativa formale oppure accettare
   esplicitamente il rischio;
4. `E21` / `M11` Beta — ratificare la candidata e chiudere `DG-ICON`.

## Controlli del repository

```sh
node scripts/check-icon-composer-assets.mjs
node scripts/check-reading-matrix.mjs
node scripts/check-roadmap-hierarchy.mjs
git diff --check
```
