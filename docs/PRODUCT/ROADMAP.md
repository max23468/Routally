# Roadmap successiva alla 1.0

- **Stato:** Confirmed come destinazione; priorità interne non equivalgono a impegni di data
- **Fonte dello scope 1.0:** [`docs/MASTER_PLAN.md`](../MASTER_PLAN.md)
Questo documento conserva le funzioni rimosse dal perimetro della 1.0. Una voce
rinviata non autorizza implementazione, capability o astrazioni preparatorie: torna attiva
soltanto con una decisione del Product Owner e una milestone dedicata.

## 1.1 — Continuità Apple

### CloudKit e multi-device

- sincronizzazione privata tramite CloudKit;
- comportamento offline e merge fra dispositivi;
- revisioni e tombstone necessari alla sincronizzazione;
- stato iCloud visibile e recupero dopo reinstallazione;
- continuità TestFlight → App Store;
- deduplica di eventi e completamenti;
- scelta del dispositivo principale per i reminder, se ancora necessaria dopo lo spike;
- migrazione dal backup locale senza perdita dati.

La 1.1 non assume che l'architettura 1.0 debba essere sostituibile. Prima si misura il
modello SwiftData distribuito; poi `TG-CLOUDKIT` decide schema, conflitti e recovery.

### iPad ottimizzato

- esperienza universale dichiarata e verificata;
- `NavigationSplitView` per Routine ed Esplora quando utile;
- finestre ridimensionabili, tastiera, pointer e focus completi;
- screenshot App Store iPad e matrice accessibilità dedicata.

La compatibilità adattiva già presente nella Foundation può essere mantenuta, ma la
qualità iPad non blocca la 1.0 iPhone.

### Ricerca e Analisi

- ricerca globale di routine e follow-up;
- Kit, Aree, sinonimi IT/EN e filtri soltanto se richiesti dall'uso reale;
- panoramica descrittiva del periodo;
- fatti osservati e routine da rivedere senza affermazioni causali;
- grafici accessibili e suggerimenti soltanto con dati sufficienti.

La ricerca deve dimostrare valore oltre la lista ordinata di 20–50 routine. Analisi nasce
da decisioni osservate nella beta, non dal desiderio di riempire una tab.

### Geofencing e contesto

- luoghi salvati;
- arrivo, uscita e visita successiva;
- fallback temporale obbligatorio;
- deduplica fra trigger geografico e fallback;
- revoca permesso e limiti di region monitoring;
- luogo + orario e ritardo dopo arrivo;
- eventuale dispositivo promemoria principale.

`TG-LOCATION` su device reale precede la promessa pubblica. Nessuna cronologia degli
spostamenti e nessuna posizione continua.

### Superfici di sistema

- widget aggiuntivi per routine, obiettivi e cicli;
- Lock Screen;
- App Intents e Comandi Rapidi avanzati;
- Universal Links e Associated Domains;
- Spotlight, Control Center e tasto Azione dove portano valore;
- background task soltanto per manutenzione non essenziale.

Dominio definitivo, DNS, email e AASA vengono chiusi con `DG-DOMAIN` prima degli
Universal Links, non prima della 1.0.

### Routine Kit aggiuntivi

I quattro Kit 1.0 restano Palestra, Lenzuola, Piante e Studio. Passano alla 1.1:

1. Corsa;
2. Tennis e padel;
3. Bicicletta;
4. Rasatura;
5. Acquario;
6. Strumento musicale;
7. Viaggi;
8. Prato.

Ogni Kit è una copia indipendente e modificabile, spiega beneficio, routine create,
collegamenti e costo rispetto ai limiti Free. Non abilita logiche assenti dal motore.

### Commerce ricorrente

- Plus Annual;
- trial;
- Billing Grace Period;
- Family Sharing;
- billing retry, scadenza e downgrade da abbonamento;
- scelta guidata delle routine attive senza perdita dati;
- prezzi e diritti Lifetime rivalutati senza ridurre acquisti esistenti.

`DG-ANNUAL` richiede evidenza di retention, disponibilità a pagare e costo operativo. La
Free permanente resta disponibile.

### Marketing successivo al traffico reale

- App Preview;
- Custom Product Pages per sport, casa, studio e hobby;
- Product Page Optimization soltanto con volume sufficiente;
- preordine soltanto con pubblico e Release Candidate stabili;
- creator, testate, community e paid acquisition dopo stabilità e retention.

## 1.2 — Integrazioni Apple

- app Apple Watch, complicazioni e registrazione dal polso;
- Apple Health;
- NFC;
- Calendario;
- ulteriori configurazioni di widget, Shortcut e tasto Azione;
- regole di viaggio e mantenimento opzionale dell'orario di casa.

Ogni integrazione deve ridurre attrito in un caso d'uso osservato e restare facoltativa.

## 1.3 — Kit e adattamento

- condivisione privata dei Kit;
- import tramite link o file di configurazione Kit, distinto dal backup dati;
- nuovi Kit e aggiornamenti facoltativi;
- vacanze, stagionalità e soglie adattive confermate dall'utente;
- varianti di contesto per palestra, corsa e casa;
- condizioni guidate semplici;
- esclusione rapida di un collegamento per singolo evento.

## 1.4+

- allegati utili;
- ulteriori unità;
- Analisi approfondita;
- automazioni multilivello guidate e sempre spiegabili;
- lingue aggiuntive;
- eventuali analytics privacy-first dopo `DG-FUTURE-ANALYTICS`;
- preparazione dell'account 2.0 soltanto quando la 2.0 viene approvata.

## 2.X — Ipotesi di lungo termine

### 2.0 — Account Routally

- backend proprietario e Sign in with Apple;
- migrazione locale/CloudKit con anteprima e verifica;
- sync multipiattaforma e modalità locale preservata se sostenibile;
- piano cloud separato dai diritti Lifetime 1.X;
- `DG-CLOUD-PRICING` prima di qualunque implementazione.

### 2.1 — Condivisione

- spazi coppia, famiglia o conviventi;
- routine private e condivise, ruoli, assegnazione e turnazione;
- notifiche coordinate e cronologia modifiche;
- Centro Attività.

### 2.2–2.3 — Web e Android

- consultazione, gestione, Analisi e Kit sul web;
- app Android con integrazioni native;
- account Routally obbligatorio per la sincronizzazione multipiattaforma.

### Successive

- libreria pubblica di Kit, creator, moderazione e versioni;
- API e integrazioni esterne;
- automazioni multilivello controllate;
- HomeKit o hardware soltanto con casi d'uso concreti;
- import assistito da altri tracker;
- AI facoltativa come interfaccia di configurazione, con anteprima strutturata e nessuna
  modifica automatica.

## Decision Gate futuri

| Gate | Quando | Decisione |
| --- | --- | --- |
| `DG-DOMAIN` | prima di Universal Links/supporto su dominio | dominio, DNS, email, ownership e recovery |
| `DG-ANNUAL` | dopo dati reali della 1.0 | Annual, trial, Family Sharing e prezzi |
| `DG-CLOUDKIT` | avvio 1.1 | modello sync, conflitti, recovery e schema Production |
| `DG-FUTURE-ANALYTICS` | se ricerca qualitativa e strumenti Apple non bastano | necessità, privacy e App Store |
| `DG-CLOUD-PRICING` | prima della 2.0 | costi backend, piani e diritti Lifetime |

## Regola di promozione

Per promuovere una voce in scope attivo servono:

1. problema o opportunità osservata;
2. risultato utente e criterio di accettazione;
3. costo e rischio proporzionati;
4. milestone e gate applicabili;
5. aggiornamento del Master Plan approvato.
