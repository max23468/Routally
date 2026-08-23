# Routally — Master Plan

- **Stato:** approvato
- **Data:** 23 agosto 2026
- **Owner:** Matteo
- **Obiettivo:** pubblicare una 1.0 piccola, affidabile e commercializzabile che dimostri
  il valore delle routine collegate senza anticipare l'infrastruttura delle versioni future.

Questo documento contiene soltanto le decisioni che governano il prodotto attivo. La
roadmap successiva vive in [`docs/PRODUCT/ROADMAP.md`](PRODUCT/ROADMAP.md); la cronologia
Git conserva le revisioni precedenti senza creare altre fonti da consultare.

## Indice

- [0. Uso e governo](#0-uso-e-governo)
- [1. Prodotto](#1-prodotto)
- [2. Scope della 1.0](#2-scope-della-10)
- [3. Esperienza](#3-esperienza)
- [4. Motore delle routine](#4-motore-delle-routine)
- [5. Dati e architettura](#5-dati-e-architettura)
- [6. Privacy e sicurezza](#6-privacy-e-sicurezza)
- [7. Modello commerciale](#7-modello-commerciale)
- [8. Integrazioni e distribuzione](#8-integrazioni-e-distribuzione)
- [9. Roadmap operativa](#9-roadmap-operativa)
- [10. Qualità](#10-qualità)
- [11. Decision Gate](#11-decision-gate)

---

# 0. Uso e governo

## 0.1 Fonti

In caso di conflitto prevalgono, nell'ordine:

1. questo Master Plan;
2. ADR confermati in `docs/ADR/`;
3. specifiche attive in `docs/PRODUCT/`, `docs/DESIGN/` e `docs/ENGINEERING/`;
4. comportamento verificato dell'app;
5. backlog, pull request e note temporanee.

Il codice non trasforma automaticamente un comportamento accidentale in requisito. Se
l'implementazione contraddice il piano, si corregge il lato sbagliato e si riallineano le
fonti nello stesso intervento.

## 0.2 Change control

Gli agenti non cambiano autonomamente scope, pricing, UX fondamentale o architettura. Non
aggiungono dipendenze runtime, servizi esterni, analytics, AI o backend senza approvazione.
Una limitazione tecnica va dimostrata con una prova piccola e riproducibile; non giustifica
la costruzione preventiva di fallback o astrazioni generiche.

Decisioni rinviate non sono requisiti della 1.0. Devono essere preservate nella roadmap,
ma non possono imporre protocolli, schemi, capability o UI all'implementazione corrente.

## 0.3 Completezza proporzionata

Una funzione 1.0 è completa quando copre, dove applicabile:

- comportamento visibile, errore e recupero;
- persistenza locale e funzionamento offline;
- accessibilità, italiano e inglese;
- correzione o annullamento;
- privacy e permessi;
- comportamento Free/Plus;
- test del rischio reale.

Non sono obbligatori per ogni funzione una matrice, un ADR, un runbook o un documento
separato. Un ADR serve soltanto per una decisione costosa da invertire; una regressione
serve per un comportamento che potrebbe rompersi; un runbook nasce quando esiste il
relativo sistema operativo.

## 0.4 Principi di implementazione

- soluzione più semplice che preserva il comportamento approvato;
- framework Apple nativi e zero dipendenze runtime esterne nella 1.0;
- nessuna astrazione destinata soltanto a un backend, provider o feature futura;
- una sola fonte per roadmap, scope e criteri di uscita;
- misure osservate prima di cache, proiezioni o ottimizzazioni;
- niente retrocompatibilità interna quando il modello corretto può sostituire quello
  precedente senza consumatori esterni.

---

# 1. Prodotto

## 1.1 Promessa

**Le tue routine, finalmente collegate.**

Routally è un'app calma per ricordare attività ricorrenti e collegare le loro conseguenze.
L'utente registra una volta un fatto reale; Routally aggiorna il relativo obiettivo o ciclo
e, quando serve, prepara il passo successivo.

Esempio centrale:

> Registro un allenamento. Aumentano l'obiettivo settimanale e gli utilizzi
> dell'asciugamano. Al quarto utilizzo Routally prepara il promemoria per sostituirlo.

Routally non è un task manager, un life logger, un motore di workflow o un social habit
tracker.

## 1.2 Pubblico iniziale

Persone che gestiscono routine di casa, sport, studio o cura personale e vogliono:

- ricordare quando qualcosa torna utile;
- contare utilizzi, quantità o sessioni senza fogli separati;
- collegare una routine a una conseguenza semplice;
- correggere un dato senza perdere fiducia nello storico;
- evitare streak, colpa e notifiche continue.

Un caso d'uso entra nel prodotto quando è ricorrente, trae vantaggio dallo storico e può
produrre una conseguenza utile. Un'attività singola senza legame con una routine resta
fuori scope.

## 1.3 Principi

1. **Segna una volta, aggiorna ciò che dipende davvero.**
2. **La complessità non entra nell'interfaccia.**
3. **Precisione senza ossessione.**
4. **Automazioni visibili, spiegabili e annullabili.**
5. **Local-first e disponibile offline.**
6. **Apple-native prima di custom.**
7. **Affidabilità e accessibilità non sono paywall.**
8. **Nessun insight o reminder senza una decisione utile.**
9. **Una funzione incompleta viene rinviata.**
10. **Il comportamento quotidiano non dipende da rete o background execution.**

## 1.4 Non-scope permanente della 1.0

- task manager generico;
- account Routally, backend o condivisione;
- web, Android, macOS, Apple Watch e Apple Health;
- advertising, tracking, analytics esterni e AI;
- allegati, inventario completo o life logging ad alta frequenza;
- formule, scripting, catene multilivello e collegamenti circolari;
- notifiche remote promozionali;
- community GitHub.

---

# 2. Scope della 1.0

## 2.1 Funzioni obbligatorie

La 1.0 comprende:

- iPhone con iOS 26, SwiftUI e Swift 6;
- Oggi, Routine, Esplora e Profilo;
- attività dopo l'ultima registrazione;
- ricorrenze in giorni stabiliti;
- obiettivi entro un periodo;
- eventi semplici, durata e quantità;
- soglia per utilizzo, quantità o tempo e combinazione `uso OR tempo`;
- collegamenti diretti: un evento può aggiornare più routine;
- un follow-up generato da soglia e chiusura esplicita del ciclo;
- cronologia, annullamento immediato e correzione retroattiva;
- pausa, archivio, eliminazione e recupero recente;
- quattro Routine Kit: Palestra, Lenzuola, Piante e Studio;
- notifiche locali temporali;
- un widget Oggi e un App Intent essenziale per registrare una routine;
- persistenza SwiftData locale e funzionamento offline;
- backup lossless esportabile e reimportabile, più CSV leggibile;
- Free e un solo acquisto Plus Lifetime;
- italiano e inglese, Light/Dark e accessibilità completa.

## 2.2 Funzioni rinviate

Le seguenti funzioni non vengono eliminate: sono definite nella roadmap 1.1+ e non
vincolano lo schema o l'architettura della 1.0.

- sincronizzazione CloudKit e uso multi-device;
- geofencing, luoghi salvati e dispositivo promemoria principale;
- esperienza iPad ottimizzata e `NavigationSplitView` come requisito di release;
- tab Analisi e ricerca globale;
- otto Kit aggiuntivi;
- widget multipli, Lock Screen e App Intents estesi;
- Universal Links, Associated Domains e background task;
- Annual, trial, grace period, Family Sharing e downgrade da abbonamento;
- App Preview, Custom Product Pages e acquisizione strutturata;
- integrazioni Apple Watch, Health, NFC e Calendario.

Il dettaglio e la destinazione di ogni voce sono in
[`docs/PRODUCT/ROADMAP.md`](PRODUCT/ROADMAP.md). Una view o fixture già presente nella
Foundation può rimanere come prototipo Dev, ma non è una promessa della 1.0 e non deve
trascinare capability, persistenza o test di release.

## 2.3 Limite di complessità

La 1.0 non introduce:

- un framework generico di event sourcing;
- proiezioni materializzate o un Consistency Engine;
- adapter intercambiabili destinati a un backend futuro;
- servizi `Null` creati soltanto per feature assenti;
- gestione guidata dei conflitti multi-device;
- cache persistenti senza una misura che le richieda;
- più di un formato canonico di backup.

---

# 3. Esperienza

## 3.1 Navigazione

La navigazione pubblica 1.0 usa tre tab:

| Tab | Scopo | Azione principale |
| --- | --- | --- |
| Oggi | mostra soltanto ciò che è utile adesso o a breve | registra o completa |
| Routine | lista, dettaglio, cronologia e configurazione | crea una routine |
| Esplora | quattro Kit introduttivi | configura e aggiungi |

Profilo è una sheet aperta dalle toolbar e contiene preferenze, acquisto, backup, export,
privacy e supporto. Analisi e Cerca non occupano tab vuote o premature: entrano in 1.1
quando esistono dati e bisogni osservati.

## 3.2 Calm View

Oggi usa sezioni dinamiche:

- **Adesso:** routine e follow-up su cui l'utente può agire;
- **Più tardi:** elementi prossimi ma non urgenti;
- **Questa settimana:** riepilogo discreto degli obiettivi pertinenti;
- **Tutto sotto controllo:** stato positivo quando non serve agire.

Non mostra debito infinito, streak, percentuali ansiogene o elementi futuri senza utilità.
Ogni riga ha una sola azione primaria. Dopo una registrazione collegata, una sheet spiega
gli effetti e offre `Annulla` per l'operazione intera ed `Escludi` per un singolo effetto.

## 3.3 Creazione

Esiste un solo flusso progressivo:

1. nome e tipo di routine;
2. frequenza, obiettivo o misura minima;
3. eventuale collegamento e soglia;
4. reminder temporale facoltativo;
5. riepilogo in linguaggio naturale.

La routine può essere salvata appena esiste una configurazione valida. Le opzioni non
necessarie restano nascoste finché l'utente non le sceglie. Nessun permesso viene chiesto
nell'onboarding.

## 3.4 Accessibilità e localizzazione

Ogni flusso 1.0 deve funzionare con VoiceOver, Voice Control, Dynamic Type massimo,
Increase Contrast, Reduce Transparency e Reduce Motion. Stato, errore e progresso non
dipendono soltanto da colore, gesto, animazione o aptica. I target interattivi rispettano
le dimensioni di sistema e i controlli nativi forniscono focus e semantica.

Italiano e inglese vengono mantenuti durante l'implementazione, non aggiunti alla fine.
Stringhe UI in String Catalog; nomi tecnici e codice in inglese.

L'app può continuare a compilare e adattarsi su iPad, ma la 1.0 viene progettata,
verificata e commercializzata come esperienza iPhone. Layout a due colonne, tastiera e
pointer completi sono requisiti della 1.1.

---

# 4. Motore delle routine

## 4.1 Archetipi

Il modello deve rappresentare quattro archetipi senza esporli come prodotti separati:

1. **Dopo l'ultima volta:** la prossima necessità dipende dal completamento reale.
2. **Giorni stabiliti:** il calendario futuro non si sposta con la registrazione.
3. **Obiettivo periodico:** conta un risultato entro settimana o mese, senza carry-over.
4. **Ciclo collegato:** eventi sorgente accumulano progresso fino a una soglia e generano
   un follow-up.

Gli eventi possono valere `+1`, durata o quantità con unità. Giorni, settimane e mesi
usano `Calendar`; minuti e ore usano tempo effettivo. Le attività future seguono il fuso
locale corrente, mentre la cronologia conserva istante e giorno locale originari.

## 4.2 Collegamenti e cicli

La 1.0 consente collegamenti diretti e aciclici. Un evento sorgente può aggiornare più
routine, con un incremento per collegamento. Una soglia `uso`, `quantità`, `tempo` o
`uso OR tempo` genera al massimo un follow-up equivalente per ciclo.

Stati del ciclo:

1. attivo;
2. soglia raggiunta;
3. follow-up aperto;
4. follow-up completato;
5. nuovo ciclo.

La soglia e il reminder non azzerano il ciclo. Soltanto il completamento esplicito del
follow-up applica la chiusura configurata.

## 4.3 Journal e correzioni

Ogni registrazione crea un evento stabile con identificativo, istante, valore, origine e
effetti applicati. Una correzione aggiorna il journal con la nuova versione logica e
ricalcola soltanto le routine direttamente coinvolte. Non esiste un'infrastruttura
generica di proiettori, snapshot o replay dell'intera app.

Il reducer di dominio è una funzione deterministica testabile. Lo stato corrente può
essere memorizzato insieme ai record SwiftData nella stessa transazione; il journal serve
a cronologia, annullamento e ricalcolo mirato, non a costruire una piattaforma distribuita.

L'utente può:

- annullare subito una registrazione;
- modificare data, durata o quantità;
- eliminare un evento;
- escludere un effetto collegato;
- vedere quali routine dirette cambieranno.

## 4.4 Stati della routine

- **attiva:** valutata e aggiornabile;
- **in pausa:** niente reminder o aggiornamenti automatici in ingresso; registrazione
  manuale esplicita consentita;
- **archiviata:** fuori dall'uso quotidiano, storico conservato;
- **eliminata di recente:** recuperabile per 30 giorni;
- **eliminata definitivamente:** rimossa dal dispositivo e dai backup successivi.

L'eliminazione di una sorgente non elimina routine collegate. I link vengono disattivati e
l'impatto viene mostrato prima della conferma.

## 4.5 Invarianti

Test automatici proteggono almeno:

1. una registrazione non viene applicata due volte;
2. un ciclo genera un solo follow-up equivalente;
3. completare il follow-up chiude il ciclo una sola volta;
4. rinviare non cambia progresso;
5. correzione e annullamento producono lo stesso risultato a parità di dati;
6. un collegamento circolare è rifiutato;
7. pausa, archivio ed eliminazione non cancellano dati indirettamente;
8. un effetto escluso non modifica gli altri effetti della registrazione;
9. il downgrade o la revoca di Plus non cancella dati;
10. importare due volte lo stesso backup non duplica eventi.

---

# 5. Dati e architettura

## 5.1 Architettura

Routally è un monolite modulare Apple-native:

```text
SwiftUI features
      ↓
Domain reducer e use case
      ↓
SwiftData store locale
```

Il dominio contiene tipi e funzioni senza dipendere dalle view. La persistenza resta in
un confine concreto SwiftData; non viene frammentata in repository per ogni entità né
resa sostituibile per un backend ipotetico. `Clock` e `Calendar` sono iniettabili nei
calcoli sensibili al tempo; le altre astrazioni nascono soltanto da una seconda
implementazione reale.

Concorrenza Swift 6 strict dal primo commit. Actor e task vengono introdotti dove una
risorsa condivisa li richiede, non uno per sottosistema per convenzione.

## 5.2 Persistenza locale

- scrittura immediata sul dispositivo;
- schema SwiftData versionato dalla prima release pubblica;
- migrazioni testate fra schemi realmente distribuiti;
- nessuna operazione quotidiana attende rete o background task;
- nessuna cache persistente è fonte canonica;
- liste e cronologia usano query e paginazione soltanto quando i dati lo richiedono.

La baseline prestazionale rappresenta fino a 50 routine e 10.000 eventi. Un dataset da
100.000 eventi resta un test esplorativo utile, non un gate architetturale o di release.

## 5.3 Backup ed export

Profilo offre:

- **Crea backup Routally:** archivio lossless, versionato e reimportabile;
- **Ripristina backup:** anteprima, validazione e scelta esplicita fra unione e
  sostituzione;
- **Esporta CSV:** formato leggibile per portabilità, non reimportabile.

Il backup contiene profilo, routine, regole, eventi, correzioni, collegamenti, follow-up e
preferenze necessarie. Non include coordinate perché i luoghi non fanno parte della 1.0.
L'import verifica versione, integrità e identificativi prima di scrivere; la sostituzione
richiede conferma e produce prima un backup di sicurezza locale.

Il formato e la strategia concreta vengono chiusi da `TG-DATA`. CloudKit è una funzione
1.1 separata: non determina i tipi, i protocolli o le capability della 1.0.

---

# 6. Privacy e sicurezza

## 6.1 Baseline

Routally non include advertising, tracking, ATT, IDFA, SDK analytics, crash reporter
esterni o telemetria comportamentale. Usa soltanto strumenti Apple aggregati, TestFlight,
Xcode Organizer, MetricKit, OSLog con privacy redaction e feedback volontario.

Non esiste un `AnalyticsClient` finché non esiste analytics. Routine, note e cronologia
restano sul dispositivo; i backup vengono creati soltanto su richiesta e condivisi tramite
il foglio di sistema.

## 6.2 Dati sensibili

- log senza nomi routine, note o contenuto del backup;
- file temporanei rimossi dopo condivisione o import;
- widget marcato `privacySensitive` dove opportuno;
- nessun Face ID interno: si usano blocco e protezioni native dell'app;
- notifiche con testo discreto e controllato dall'utente;
- cancellazione completa disponibile nel Profilo.

## 6.3 Capability e permessi

Capability 1.0: App Group soltanto per widget/App Intent, In-App Purchase e le capability
strettamente richieste dai target effettivi. Niente iCloud, Associated Domains,
Background Modes o Location.

Le notifiche vengono richieste quando l'utente configura il primo reminder. Calendario,
Contatti, Health, microfono, fotocamera, Bluetooth, foto e tracking non vengono richiesti.
Un permesso negato non blocca le funzioni che non ne dipendono.

## 6.4 Rischi pratici

La review di sicurezza copre cinque famiglie:

1. perdita, corruzione o duplicazione durante modifica, eliminazione e import;
2. esposizione tramite log, notifiche, widget o file temporanei;
3. entitlement Plus errato dopo acquisto, rimborso o revoca;
4. input esterni non validi da backup, widget e App Intent;
5. secret e supply chain del repository pubblico.

Le mitigazioni sono test di round-trip e idempotenza, validazione degli input, privacy
redaction, minimo privilegio, secret scanning, push protection, branch protection e
dipendenze GitHub Actions bloccate. CodeQL analizza codice Swift su `main` e su richiesta
di release; non è un gate per modifiche esclusivamente documentali. Gli aggiornamenti
Actions vengono raggruppati per ridurre PR prive di valore indipendente.

Un'unica checklist di incidente viene preparata prima della beta. Runbook separati nascono
solo per sistemi realmente pubblicati.

---

# 7. Modello commerciale

## 7.1 Free

- fino a 10 routine attive;
- fino a 5 collegamenti attivi;
- quattro Kit introduttivi;
- tutti e quattro gli archetipi;
- Oggi, notifiche, widget, App Intent, backup e CSV;
- cronologia delle ultime quattro settimane;
- affidabilità, accessibilità e localizzazione complete.

Free deve dimostrare il ciclo collegato senza timer artificiali o funzioni di affidabilità
bloccate.

## 7.2 Plus Lifetime

La 1.0 offre un solo prodotto StoreKit 2 non consumabile:

- `plus_lifetime`;
- prezzo baseline 39,99 €;
- routine e collegamenti illimitati;
- cronologia completa;
- accenti colore aggiuntivi;
- tutti gli aggiornamenti locali del ciclo 1.X esplicitamente inclusi nella roadmap.

Non esistono nella 1.0 Annual, trial, grace period o logiche di rinnovo. Free svolge il
ruolo di prova permanente. Family Sharing viene valutato con la revisione commerciale
della 1.1 e non condiziona il lancio.

## 7.3 Entitlement e revoca

StoreKit è fonte dell'entitlement; una cache locale serve soltanto alla continuità UI.
Acquisto e ripristino sono espliciti, senza prezzo barrato falso o piano preselezionato.

In caso di rimborso o revoca:

- nessun dato viene eliminato;
- l'utente sceglie quali routine mantenere attive entro i limiti Free;
- le altre vengono messe in pausa;
- collegamenti sospesi ed effetti mancanti restano visibili;
- il ripristino dell'entitlement riattiva la configurazione precedente.

---

# 8. Integrazioni e distribuzione

## 8.1 Notifiche

La 1.0 usa notifiche locali temporali per routine e follow-up. Pianificazione e azioni sono
idempotenti; una notifica non è fonte di verità e l'elemento resta visibile in Oggi se la
delivery non avviene. Non si promette puntualità assoluta.

## 8.2 Widget e App Intent

Un solo widget Oggi mostra gli elementi più utili e apre l'app. Un App Intent essenziale
registra una routine scelta dall'utente e presenta un risultato comprensibile. Entrambi
usano lo stesso use case dell'app e non duplicano logica di dominio.

Lock Screen, configurazioni multiple, Shortcut avanzati e altre superfici restano in 1.1.

## 8.3 App Store e supporto

La release 1.0 richiede:

- identità sviluppatore e record App Store coerenti;
- Privacy Policy e supporto IT/EN;
- App Privacy e privacy manifest verificati sulla build finale;
- metadata e screenshot iPhone dalla Release Candidate reale;
- StoreKit production e restore verificati;
- export compliance, dati DSA e accordi commerciali compilati correttamente;
- TestFlight, feedback e canale supporto pronti.

App Preview, Custom Product Pages, preordine e paid acquisition non sono prerequisiti di
lancio. La release è manuale e controllata; TestFlight o App Store richiedono sempre
autorizzazione separata dalla pubblicazione del repository.

---

# 9. Roadmap operativa

Versioni (`0.x/1.0`), milestone (`Mnn`), epiche (`Enn`), Technical Gate (`TG-*`) e
Decision Gate (`DG-*`) restano namespace distinti. L'albero seguente è l'unica mappa
operativa canonica della 1.0; non viene duplicato in traceability, DoD e backlog separati.

```text
0.1 / M01 Foundation
├── E01 Repository & Governance
├── E02 Apple-native UI Direction
└── E03 Xcode & SwiftUI Foundation

0.2 / M02 Core & Local Data
├── E04 Routine Reducer & Journal
└── E05 SwiftData & Lossless Backup
    ├── TG-DATA
    └── TG-RECALC

0.3 / M03 Vertical Slice
└── E06 Connected Routine Integration

0.4 / M04 Product Experience
├── E07 Today & Routines
├── E08 Creation, History & Correction
└── E09 Explore & Four Kits

0.5 / M05 Release Foundations
├── E10 Notifications, Widget & App Intent
└── E11 Lifetime Commerce, Privacy & Support
    └── TG-STOREKIT

0.6–1.0 / M06 Validate & Release
└── E12 Alpha, Beta & App Store
    ├── DG-DEVELOPER-IDENTITY
    ├── DG-TRADEMARK
    ├── DG-ICON
    └── DG-LAUNCH
```

## M01 — Foundation

**Esito:** repository, design e Foundation SwiftUI eseguibile. E01–E03 restano concluse;
le view prototipali di funzioni rinviate non ne rendono attivo lo scope.

## M02 — Core & Local Data

### E04 — Routine Reducer & Journal

- tipi degli archetipi, eventi e collegamenti diretti;
- reducer deterministico, cicli, follow-up e invarianti;
- correzione, esclusione e annullamento mirati;
- test di calendario, fuso, soglie e idempotenza.

### E05 — SwiftData & Lossless Backup

- schema locale versionato e store concreto;
- transazioni fra journal e stato corrente;
- backup lossless, import con anteprima e CSV;
- dataset realistico e migrazione baseline.

`TG-DATA` verifica round-trip, import idempotente, sostituzione recuperabile e 10.000
eventi. `TG-RECALC` verifica che correzioni ripetute producano lo stesso stato e restino
fuori dal percorso UI immediato. Nessun gate autorizza un fallback framework preventivo.

## M03 — Vertical Slice

### E06 — Connected Routine Integration

Il percorso Palestra → Asciugamano funziona su dati locali reali: creazione, quarta
registrazione, follow-up temporale, riepilogo conseguenze, esclusione, annullamento,
completamento e nuovo ciclo. Il dominio resta generico e copre i quattro archetipi.

## M04 — Product Experience

### E07 — Today & Routines

Calm View, lista, dettaglio, stati attiva/pausa/archivio/eliminazione e cronologia.

### E08 — Creation, History & Correction

Flusso progressivo, validazione, reminder temporale, modifica ed effetti spiegabili.

### E09 — Explore & Four Kits

Palestra, Lenzuola, Piante e Studio installabili come copie indipendenti, modificabili e
compatibili con Free.

## M05 — Release Foundations

### E10 — Notifications, Widget & App Intent

Notifiche locali, un widget Oggi e un intento di registrazione condividono use case e
testano fallback senza geofencing o background dependency.

### E11 — Lifetime Commerce, Privacy & Support

Free/Plus Lifetime, restore, revoca protetta, paywall trasparente, privacy manifest,
supporto e metadata App Store baseline. `TG-STOREKIT` verifica acquisto, restore, offline,
rimborso/revoca e persistenza dei dati in Sandbox/TestFlight.

## M06 — Validate & Release

### E12 — Alpha, Beta & App Store

- audit accessibilità e IT/EN sui flussi 1.0;
- performance osservata su build Release e device supportato;
- backup/import, upgrade e StoreKit verificati;
- beta qualitativa su comprensione, utilità e perdita dati;
- legal, privacy, screenshot, supporto e review notes finali;
- feature freeze, Release Candidate e lancio manuale autorizzato.

---

# 10. Qualità

## 10.1 Strategia di test

I test proteggono valore e rischio, non una percentuale di coverage.

- **dominio:** archetipi, calendario, soglie, collegamenti, cicli, correzioni e invarianti;
- **dati:** transazioni, migrazioni distribuite, backup/import e idempotenza;
- **UI:** creazione, registrazione, riepilogo, correzione, stati vuoti/errore e paywall;
- **sistema:** notifiche, widget, App Intent e StoreKit;
- **manuale:** VoiceOver, Dynamic Type, permessi, export/import e device reale.

Ogni bug produce la più piccola regressione che falliva prima della correzione.

## 10.2 Gate di pull request

Per modifiche applicative:

- `swift format lint --strict`;
- build senza nuovi warning;
- test interessati;
- preview o evidenza Simulator per comportamento UI;
- `codex-review` sull'HEAD esatto;
- CodeQL quando cambia codice Swift o configurazione applicativa sensibile.

Modifiche solo documentali eseguono i checker documentali e il gate di review, senza
costruire l'app o avviare analisi di sicurezza non pertinenti.

## 10.3 Prestazioni

Prima esiste una baseline misurata, poi un budget. La Release Candidate non deve mostrare
blocchi percepibili nei flussi principali, hitch riproducibili nelle liste o operazioni di
backup senza progresso visibile. Le misure vengono registrate con dispositivo, build e
dataset; numeri non misurati non diventano requisiti.

Il dataset ordinario è 50 routine e 10.000 eventi. Il test da 100.000 eventi resta
esplorativo e non determina da solo l'architettura.

## 10.4 Quality bar 1.0

Routally è pronta quando:

1. il ciclo collegato funziona end-to-end;
2. nessuna azione duplica o cancella dati silenziosamente;
3. backup e ripristino sono verificati;
4. notifiche, widget e intento degradano senza perdere lo stato;
5. VoiceOver, Dynamic Type, IT/EN e Light/Dark sono completi;
6. Free dimostra il prodotto e Plus è trasparente;
7. non esistono capability o feature future nella build pubblica senza uso reale;
8. privacy, StoreKit, supporto e materiali App Store sono verificati sulla RC;
9. il Product Owner approva esperienza e rilascio.

---

# 11. Decision Gate

## DG-DEVELOPER-IDENTITY

Prima degli asset Apple definitivi: scegliere account individuale o entità propria,
developer name, proprietà di Bundle ID/App Group/StoreKit e dati DSA. Publisher o account
rental non sono baseline raccomandate.

## DG-TRADEMARK

Prima del lancio: verifica formale di Routally e Temisfera e decisione sull'eventuale
deposito.

## DG-ICON

La direzione resta il monogramma `R` costruito attorno a un ciclo; la variante definitiva
richiede Icon Composer, dispositivi reali, user test e verifica figurativa.

## DG-LAUNCH

Data, territori e rilascio manuale vengono decisi soltanto con Release Candidate stabile.

Decisioni future su dominio, CloudKit, Annual, analytics, backend e pricing cloud vivono
nella roadmap 1.1+ e non bloccano la 1.0 finché non rientrano nel prodotto attivo.
