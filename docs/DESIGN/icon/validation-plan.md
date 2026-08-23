# Piano di validazione dell'icona Routally

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
- **26 — Pubblicazione della PR:** autorizzata dal Product Owner; il merge della PR #19
  completa il punto senza chiudere anticipatamente `DG-ICON`.

## Attività residue

Le attività residue non appartengono alla Foundation e non vanno anticipate:

1. `E20` / `M10` Alpha — provare la build feature-complete su iPhone e iPad reali,
   soprattutto a 29 e 40 pt;
2. `E20` / `M10` Alpha — completare lo user test cieco;
3. `E21` / `M11` Beta — svolgere la verifica figurativa formale oppure accettare
   esplicitamente il rischio;
4. `E21` / `M11` Beta — ratificare la candidata e chiudere `DG-ICON`.

Completati in questa fase: import A1 Lavender 50 e derivata Dev, configurazione Liquid Glass,
specializzazioni Dark e Mono, controllo a 29/40 pt, creazione dei pacchetti `.icon`,
collegamento esclusivo ai rispettivi target, build Simulator pubblico/Dev e verifica di
Clear/Tinted in modalità chiara e scura sulla Home Screen di iOS Simulator 26.5.
Queste attività chiudono la quota `E03` / `M01`; non costituiscono ratifica anticipata.

## Controlli del repository

```sh
node scripts/build-icon-assets.mjs
node scripts/check-icon-assets.mjs
node scripts/check-icon-composer-assets.mjs
node scripts/build-icon-review-assets.mjs
node scripts/check-icon-review-assets.mjs
node scripts/validate-icon-assets.mjs
node scripts/check-reading-matrix.mjs
node scripts/check-roadmap-hierarchy.mjs
git diff --check
```
