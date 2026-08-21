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
