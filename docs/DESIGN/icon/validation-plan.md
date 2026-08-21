# Piano di validazione dell'icona Routally

- **Stato:** preparazione tecnica completabile nel repository; `DG-ICON` ancora aperto
- **Candidata corrente:** `a1-air-medium`
- **Confronti obbligatori:** `a3-air-wide-short`, `t1-cycle-consequence`
- **Fonte canonica:** sezione 4.8 del [Master Plan](../../MASTER_PLAN.md)

Questo documento rende verificabili i ventiquattro interventi emersi dalla revisione della
PR #18. Nessuna attività manuale viene dichiarata eseguita senza evidenza prodotta su macOS,
Icon Composer o dispositivo reale.

## Matrice degli interventi

| # | Intervento | Stato in questa PR | Evidenza o uscita richiesta |
|---:|---|---|---|
| 1 | Correggere la terminologia obsoleta della PR #18 | Completato | corpo della PR #18 aggiornato |
| 2 | Indicare A1 soltanto come candidata preferita | Completato | Master Plan, UI Foundation, README e registro coerenti |
| 3 | Descrivere il segno come monogramma `R` costruito attorno a un ciclo | Completato | formulazione canonica aggiornata |
| 4 | Chiarire che T1 non sostituisce automaticamente A1 alle piccole dimensioni | Completato | T1 definita come benchmark della silhouette e fallback globale |
| 5 | Aggiornare i requisiti operativi di Icon Composer | Completato | checklist con macOS Tahoe 26.4 o successivo |
| 6 | Documentare la decisione e chiudere `DG-ICON` solo dopo le verifiche | Preparato | [decision-record.md](decision-record.md), stato ancora `Open` |
| 7 | Importare davvero gli asset in Icon Composer | Manuale bloccante | verbale di import con versione di macOS e Icon Composer |
| 8 | Esportare livelli SVG autonomi per le candidate | Completato | `composer-layers/`, matrice completa per tutte le varianti |
| 9 | Creare e versionare il file `.icon` | Manuale bloccante | file prodotto da Icon Composer |
| 10 | Configurare Default, Dark e Mono | Manuale bloccante | annotazioni e screenshot dei tre modi |
| 11 | Collegare il file `.icon` al target Xcode | Manuale bloccante | build del target Dev e pubblico con icona selezionata |
| 12 | Verificare l'icona Dev e la fascia diagonale | Preparato; verifica piatta completata | `evidence/dev-comparison.svg`, poi conferma su dispositivo |
| 13 | Aggiungere test geometrici indipendenti dal generatore | Completato | `scripts/validate-icon-assets.mjs` |
| 14 | Aggiungere test automatici dei contrasti | Completato | controllo WCAG sui colori letti dagli SVG |
| 15 | Aggiungere un workflow CI dedicato | Escluso dal Product Owner | nessun workflow permanente; solo controllo una tantum |
| 16 | Conservare tavole riproducibili a 180/120/60/40/29 pt | Completato | `evidence/candidate-comparison.svg` |
| 17 | Testare su iPhone e iPad reali | Manuale bloccante | checklist dispositivi e screenshot |
| 18 | Verificare Liquid Glass e riflessione speculare | Manuale bloccante | confronto in Icon Composer e su dispositivo |
| 19 | Eseguire uno user test cieco su 5–8 persone | Manuale bloccante | [user-test-protocol.md](user-test-protocol.md) compilato |
| 20 | Eseguire una ricerca preliminare di originalità | Completato in via preliminare | [originality-scan.md](originality-scan.md); clearance formale ancora richiesta |
| 21 | Creare A1 con testa terminale da 50 | Completato | `experiments/a1-air-medium-head50-*.svg` |
| 22 | Confrontare Lavender e Amber | Completato | varianti Amber con token esistenti e `evidence/refinement-matrix.svg` |
| 23 | Confrontare almeno A1, A3 e T1 | Completato sul piano SVG | tavola dimensionale; confronto finale in Icon Composer ancora richiesto |
| 24 | Scegliere soltanto dopo confronto completo | Manuale bloccante | decision record approvato dal Product Owner |

## Controllo una tantum

Non viene introdotto un workflow permanente dedicato all'icona. Prima della revisione finale
si eseguono, sullo stesso commit, questi comandi:

```sh
node scripts/build-icon-assets.mjs
node scripts/check-icon-assets.mjs
node scripts/build-icon-review-assets.mjs
node scripts/validate-icon-assets.mjs
node scripts/check-reading-matrix.mjs
node scripts/check-roadmap-hierarchy.mjs
git diff --check
```

Il controllo indipendente legge gli SVG versionati e non importa il generatore canonico. In
questo modo un errore introdotto nella sorgente parametrica non diventa automaticamente una
verifica verde.

## Condizioni per chiudere `DG-ICON`

Il gate resta aperto finché non esistono tutte le evidenze seguenti:

1. import riuscito dei livelli autonomi in Icon Composer;
2. file `.icon` versionato e collegato ai target;
3. Default, Dark e Mono verificati nelle sei rese di sistema;
4. prova su iPhone e iPad reali, incluse 29 e 40 pt;
5. esito dello user test cieco;
6. verifica figurativa professionale o decisione esplicita del Product Owner sul rischio;
7. decision record finale compilato e approvato.
