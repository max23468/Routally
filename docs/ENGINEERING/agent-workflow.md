# Workflow degli agenti

Questo documento è la fonte comune per Codex e Claude Code. `AGENTS.md` e `CLAUDE.md`
sono i rispettivi punti di ingresso; `docs/MASTER_PLAN.md` resta la fonte canonica delle
decisioni di progetto.

## Lettura del Master Plan

Il Master Plan non va letto integralmente prima di ogni attività. Leggi **sempre** la
sezione 0 (come usare il documento), i principi di prodotto (5), lo scope e i non-scope
della 1.0 (6), i technical spike e i validation gate (40), i Decision Gate aperti (50) e le
decisioni sostituite (51).

La sezione 40 è sempre letta perché un gate tecnico vincola il lavoro di altre sezioni:
TG-RECALC precede le feature che dipendono dal ricalcolo e TG-DATA precede lo schema.
TG-STOREKIT è differito alla 1.X e si apre dopo il checkpoint A di DG-PLUS-LAUNCH; non vincola la
1.0 gratuita. Prima di implementare, verifica che il gate applicabile sia chiuso; se è
aperto, l’esito dello spike precede l’implementazione.

Poi leggi soltanto le sezioni che il tuo intervento tocca:

| Intervento | Sezioni |
| --- | --- |
| Prodotto, posizionamento, brand, naming, tono | 1, 2, 3, 4 |
| Navigazione, Oggi, lista Routine, dettaglio | 8, 9, 10, 11 |
| Esplora, Routine Kits, catalogo editoriale | 12, 20 |
| Analisi, insight, grafici | 13 |
| Onboarding e flusso di creazione | 14 |
| Motore, regole, cicli, collegamenti, registro eventi | 15, 16, 17 |
| Follow-up, notifiche, luoghi, geofencing | 18 |
| Widget, App Intents, Universal Links, background | 19 |
| Persistenza, iCloud, schema, migrazioni, export | 21 |
| Privacy, sicurezza, permessi, threat model | 22 |
| Accessibilità e localizzazione | 23, 24 |
| Piattaforme, architettura, SwiftUI, toolchain, ambienti | 7, 25, 26, 30, 53 |
| Governance agenti, Git, pull request, documentazione | 27, 28, 29, 54 |
| Core gratuito, Premium Value Gate, Plus 1.X, prezzi e StoreKit futuro | 31 |
| Sito, supporto, legale, App Store, compliance | 32, 33, 46, 52 |
| Metriche, strategia di test, performance | 34, 35, 36 |
| Milestone, roadmap, technical spike e gate | 37, 38, 39, 40 |
| Casi limite, checklist operativa, rischi | 41, 42, 43 |
| Ownership di account e asset, budget | 44, 45 |
| Tracciabilità, Definition of Done, backlog per epiche | 47, 48, 49 |

In dubbio sulla sezione competente, consulta l'Indice del documento invece di leggerlo
tutto. Quando una richiesta sembra uscire dallo scope confermato o riproporre una scelta
già scartata, prevale la verifica delle sezioni 6 e 51.

**Invariante di copertura.** Ogni sezione di primo livello del Master Plan è raggiungibile:
0, 5, 6, 40, 50 e 51 sono sempre lette, tutte le altre compaiono in almeno una riga della
matrice. Quando il piano guadagna una sezione, la matrice va aggiornata nello stesso
intervento. Una sezione irraggiungibile è un difetto della matrice, non una sezione
facoltativa: si corregge prima di procedere.

Il controllo è eseguibile con `scripts/check-reading-matrix.mjs`.

Quando cambiano milestone, epiche, Definition of Done o tracciabilità, esegui
anche `node scripts/check-roadmap-hierarchy.mjs`. Il controllo richiede identificativi
contigui, una sola milestone primaria per epica, corrispondenza con le Definition of Done,
e copertura di tutti i Technical Gate. Requisiti e attività non vengono duplicati in
tassonomie parallele.

## Dimensioni trasversali

La matrice indica le sezioni che descrivono **l'oggetto** dell'intervento. Non basta: il
principio di completezza della sezione 0.4 stabilisce che una feature è completa solo
quando sono coperte anche le dimensioni che valgono per ogni feature, ovunque siano
documentate.

Quando l'intervento produce comportamento visibile all'utente, leggi anche le sezioni delle
dimensioni applicabili:

| Dimensione della sezione 0.4 | Sezioni |
| --- | --- |
| Garanzia del core gratuito e, dalla 1.X, comportamento Plus | 31 |
| Accessibilità | 23 |
| Localizzazione italiana e inglese | 24 |
| Privacy, sicurezza e permessi | 22 |
| Persistenza, offline e sincronizzazione | 21 |
| Correzione, annullamento e recupero | 16, 17 |
| Notifiche e integrazioni di sistema | 18, 19 |
| Test e criteri di accettazione | 35, 48 |

Esempio: un intervento sui widget della 1.0 legge la riga della matrice (19) e la
sezione 31 per verificare che non introduca limiti commerciali. Un intervento su una
capacità candidata Plus legge anche DG-PLUS-LAUNCH e TG-STOREKIT. Un intervento sul
motore legge 15–17 e, se tocca stato derivato o ricalcolo, il gate applicabile della
sezione 40.

Una dimensione non applicabile si dichiara tale; non si omette in silenzio.

## Avvio

1. Leggi il Master Plan secondo la matrice sopra, poi le specifiche o gli ADR pertinenti.
2. Conferma obiettivo, scope e criteri di accettazione.
3. Verifica branch, working tree e modifiche concorrenti prima di intervenire.
4. Non usare contemporaneamente Codex e Claude Code sullo stesso task.

## Lavoro

- Dopo il commit radice di bootstrap, usa un branch breve e una pull request.
- Prima della PR esegui `node scripts/verify-change.mjs --base origin/main`: il comando
  classifica il diff e lancia soltanto i controlli applicabili, rieseguendo la suite completa
  sull'HEAD finale quando cambia codice Swift.
- Ogni PR richiede anche `publication-gate`, sempre presente e aggregato. Classificazione,
  verifiche documentali, format e CodeQL vengono eseguiti in parallelo; build/test Simulator
  restano sul Mac controllato e sono registrati nel corpo con l'HEAD completo. I controlli
  costosi sono condizionali al contenuto del diff. Modifiche UI richiedono inoltre evidenza
  visuale proporzionata, che resta una prova umana e non viene simulata dalla CI: allegala e
  marca il relativo checkbox nel corpo prima di aprire la PR, altrimenti il gate fallisce.
  Ogni esecuzione invalida subito l'esito precedente; lo status viene pubblicato dal job
  finale trusted e i job sul merge proposto hanno permessi di sola lettura, così anche i PR
  Dependabot restano supportati senza affidarsi al workflow della PR.
  Per CodeQL, SwiftPM risolve il package graph prima dell'inizializzazione dell'estrattore;
  la build successiva usa lo stesso `DerivedData` e non aggiorna né risolve automaticamente
  i package. Il gate resta richiesto per Swift, configurazioni Xcode/SwiftPM e configurazione
  CodeQL dedicata, non per la sola orchestrazione CI priva di impatto sull'app.
- P0/P1 dell'HEAD corrente bloccano; P2/P3 vengono registrati come advisory e non richiedono
  la risoluzione della conversazione per il merge.
- Abilita lo squash auto-merge quando i gate sono in corso. Dopo il merge usa
  `node scripts/verify-merge-tree.mjs --pr-head <sha> --merge <sha>` e rileggi PR, `main`,
  `origin/main`, branch, worktree e stash. Se il tree coincide, build/test locali e CodeQL
  registrati nella PR restano evidenza del contenuto pubblicato e non vengono duplicati dopo
  il merge. CodeQL pianificato su `main` resta un monitor asincrono.
- Mantieni il cambiamento minimo coerente con lo scope approvato.
- Non aggiungere dipendenze o operare su servizi remoti senza autorizzazione.
- Esegui i controlli proporzionati al rischio e aggiungi una regressione per ogni bug.
- Non includere secret, credenziali o dati reali.

## Chiusura e handoff

- Commit e working tree pulito.
- Test eseguiti e risultati registrati.
- Decisioni, rischi residui e prossimo passo dichiarati.
- Nessun deploy o release senza approvazione esplicita.
