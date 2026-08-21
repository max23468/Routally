# Piano di validazione dell'icona Routally

- **Stato:** baseline visuale confermata; `DG-ICON` ancora aperto per le verifiche Apple e umane
- **Baseline:** A1 Lavender, testa 50
- **Controllo cromatico:** A1 Amber, testa 50
- **Fallback globale:** T1
- **Fonte canonica:** sezione 4.8 del [Master Plan](../../MASTER_PLAN.md)

Questo documento rende verificabili i ventiquattro interventi emersi dalla revisione della
PR #18. La conferma del Product Owner del 21 agosto 2026 chiude le scelte visuali
preliminari, ma nessuna attività manuale viene dichiarata eseguita senza evidenza prodotta
su macOS, Icon Composer o dispositivo reale.

## Matrice degli interventi

| # | Intervento | Stato attuale | Evidenza o uscita richiesta |
|---:|---|---|---|
| 1 | Correggere la terminologia obsoleta della PR #18 | Completato | corpo della PR #18 aggiornato |
| 2 | Indicare A1 soltanto come candidata preferita | Completato e superato dalla scelta della baseline | A1 Lavender testa 50 registrata nel decision record |
| 3 | Descrivere il segno come monogramma `R` costruito attorno a un ciclo | Completato | formulazione canonica aggiornata |
| 4 | Chiarire che T1 non sostituisce automaticamente A1 alle piccole dimensioni | Completato | T1 è soltanto benchmark/fallback globale |
| 5 | Aggiornare i requisiti operativi di Icon Composer | Completato | checklist con macOS Tahoe 26.4 o successivo |
| 6 | Documentare la decisione e chiudere `DG-ICON` solo dopo le verifiche | Decisione preliminare registrata; chiusura ancora aperta | [decision-record.md](decision-record.md) |
| 7 | Importare davvero gli asset in Icon Composer | **Aperto — manuale bloccante** | verbale di import con versioni di macOS, Icon Composer e Xcode |
| 8 | Esportare livelli SVG autonomi per le candidate | Completato | `composer-layers/`, matrice completa |
| 9 | Creare e versionare il file `.icon` | **Aperto — manuale bloccante** | file prodotto da Icon Composer |
| 10 | Configurare Default, Dark e Mono | **Aperto — manuale bloccante** | includere anche Clear e Tinted |
| 11 | Collegare il file `.icon` al target Xcode | **Aperto — manuale bloccante** | build dei target Dev e pubblico |
| 12 | Verificare l'icona Dev e la fascia diagonale | Verifica piatta completata; **prova Apple aperta** | `evidence/dev-comparison.svg` e conferma su dispositivo |
| 13 | Aggiungere test geometrici indipendenti dal generatore | Completato | 607 controlli superati |
| 14 | Aggiungere test automatici dei contrasti | Completato | controllo sui colori letti dagli SVG |
| 15 | Aggiungere un workflow CI dedicato | Escluso dal Product Owner | nessun workflow permanente; controllo una tantum completato |
| 16 | Conservare tavole riproducibili a 180/120/60/40/29 pt | Completato | `evidence/candidate-comparison.svg` |
| 17 | Testare su iPhone e iPad reali | **Aperto — manuale bloccante** | checklist dispositivi e screenshot |
| 18 | Verificare Liquid Glass e riflessione speculare | **Aperto — manuale bloccante** | confronto in Icon Composer e su dispositivo |
| 19 | Eseguire uno user test cieco su 5–8 persone | **Aperto — manuale bloccante** | A1 Lavender 50 / A1 Amber 50 / T1 |
| 20 | Eseguire una ricerca preliminare di originalità | Ricerca preliminare completata; **chiusura formale aperta** | verifica professionale oppure accettazione esplicita del rischio |
| 21 | Creare A1 con testa terminale da 50 | Completato e approvato come baseline | `experiments/a1-air-medium-head50-*.svg` |
| 22 | Confrontare Lavender e Amber | Completato; Lavender scelta, Amber mantenuta come controllo | `evidence/refinement-matrix.svg` |
| 23 | Confrontare almeno A1, A3 e T1 | Completato; A1 scelta, A3 archiviata, T1 fallback | tavole SVG e decision record |
| 24 | Scegliere soltanto dopo confronto completo | Scelta preliminare completata; **ratifica finale ancora aperta** | ratifica dopo tutte le evidenze residue |

## Cosa resta aperto dopo la conferma del Product Owner

1. importare A1 Lavender testa 50, A1 Amber testa 50 e T1 in Icon Composer;
2. verificare Default, Dark, Mono, Clear e Tinted, compreso Liquid Glass;
3. creare il file `.icon`, versionarlo e collegarlo ai target pubblico e Dev;
4. eseguire build e controlli del bundle su macOS;
5. provare l'icona su iPhone e iPad reali, soprattutto a 29 e 40 pt;
6. completare lo user test cieco;
7. svolgere la verifica figurativa formale oppure accettare esplicitamente il rischio residuo;
8. ratificare la baseline, aggiornare Master Plan/Decision Register e chiudere `DG-ICON`.

## Controllo una tantum

Non viene introdotto un workflow permanente dedicato all'icona. I seguenti controlli sono
già stati eseguiti con esito positivo; andranno ripetuti soltanto se cambiano gli SVG o gli
script:

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

## Condizioni per chiudere `DG-ICON`

Il gate resta aperto finché non esistono tutte le evidenze seguenti:

1. import riuscito dei livelli autonomi in Icon Composer;
2. file `.icon` versionato e collegato ai target;
3. tutti i modi di rendering Apple verificati;
4. prova su iPhone e iPad reali;
5. esito dello user test cieco;
6. verifica figurativa professionale o decisione esplicita del Product Owner sul rischio;
7. ratifica finale compilata nel decision record.
