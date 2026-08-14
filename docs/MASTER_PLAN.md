# Routally — Master Plan

- **Documento canonico:** `docs/MASTER_PLAN.md`
- **Versione del piano:** 1.4 Operational Hierarchy Baseline
- **Stato:** approvato per l'avvio della progettazione e dello sviluppo
- **Data:** 14 agosto 2026
- **Audit di completezza rispetto alla chat:** completato prima dell'handoff a Codex
- **Owner di prodotto:** Matteo
- **Obiettivo primario:** pubblicare Routally 1.0 su App Store come prodotto completo, affidabile e commercializzabile, mantenendo una roadmap esplicita per le versioni 1.X, 2.X e successive.

---

## Indice

- [1. Executive summary](#1-executive-summary)
- [2. Visione, problema e opportunità](#2-visione-problema-e-opportunità)
- [3. Posizionamento competitivo e originalità](#3-posizionamento-competitivo-e-originalità)
- [4. Brand e identità](#4-brand-e-identità)
- [5. Principi di prodotto](#5-principi-di-prodotto)
- [6. Scope e non-scope della 1.0](#6-scope-e-non-scope-della-10)
- [7. Piattaforme ed esperienza Apple-native](#7-piattaforme-ed-esperienza-apple-native)
- [8. Architettura dell'informazione e navigazione](#8-architettura-dellinformazione-e-navigazione)
- [9. Schermata Oggi — Calm View](#9-schermata-oggi-calm-view)
- [10. Tab Routine](#10-tab-routine)
- [11. Pagina di dettaglio della routine](#11-pagina-di-dettaglio-della-routine)
- [12. Esplora e Routine Kits](#12-esplora-e-routine-kits)
- [13. Tab Analisi](#13-tab-analisi)
- [14. Onboarding e creazione](#14-onboarding-e-creazione)
- [15. Motore funzionale](#15-motore-funzionale)
- [16. Event sourcing, correzione e consistenza](#16-event-sourcing-correzione-e-consistenza)
- [17. Pausa, archiviazione ed eliminazione](#17-pausa-archiviazione-ed-eliminazione)
- [18. Smart Follow-ups, notifiche e luoghi](#18-smart-follow-ups-notifiche-e-luoghi)
- [19. Integrazioni Apple della 1.0](#19-integrazioni-apple-della-10)
- [20. Catalogo Routine Kits 1.0](#20-catalogo-routine-kits-10)
- [21. Dati, persistenza e iCloud](#21-dati-persistenza-e-icloud)
- [22. Privacy e sicurezza](#22-privacy-e-sicurezza)
- [23. Accessibilità](#23-accessibilità)
- [24. Localizzazione](#24-localizzazione)
- [25. Architettura tecnica](#25-architettura-tecnica)
- [26. Toolchain e dipendenze](#26-toolchain-e-dipendenze)
- [27. Codex e Claude Code](#27-codex-e-claude-code)
- [28. Repository e workflow Git](#28-repository-e-workflow-git)
- [29. Documentazione](#29-documentazione)
- [30. Ambienti e configurazioni](#30-ambienti-e-configurazioni)
- [31. Modello di business](#31-modello-di-business)
- [32. Sito, supporto e documenti legali](#32-sito-supporto-e-documenti-legali)
- [33. App Store](#33-app-store)
- [34. Metriche di successo](#34-metriche-di-successo)
- [35. Strategia di test](#35-strategia-di-test)
- [36. Performance e affidabilità](#36-performance-e-affidabilità)
- [37. Versioning e milestone interne](#37-versioning-e-milestone-interne)
- [38. Roadmap 1.X](#38-roadmap-1x)
- [39. Roadmap 2.X e lungo termine](#39-roadmap-2x-e-lungo-termine)
- [40. Technical spikes e validation gates](#40-technical-spikes-e-validation-gates)
- [41. Matrice delle eccezioni](#41-matrice-delle-eccezioni)
- [42. Runbook operativi](#42-runbook-operativi)
- [43. Risk register iniziale](#43-risk-register-iniziale)
- [44. Ownership di account, asset e credenziali](#44-ownership-di-account-asset-e-credenziali)
- [45. Budget e sostenibilità operativa](#45-budget-e-sostenibilità-operativa)
- [46. Compliance e checklist App Store](#46-compliance-e-checklist-app-store)
- [47. Requirement traceability baseline](#47-requirement-traceability-baseline)
- [48. Definition of Done per milestone](#48-definition-of-done-per-milestone)
- [49. Backlog iniziale per epiche](#49-backlog-iniziale-per-epiche)
- [50. Decision Gate aperti](#50-decision-gate-aperti)
- [51. Decisioni esplicitamente sostituite](#51-decisioni-esplicitamente-sostituite)
- [52. Quality bar finale](#52-quality-bar-finale)
- [53. Riferimenti esterni principali](#53-riferimenti-esterni-principali)
- [54. Approvazione della baseline](#54-approvazione-della-baseline)

---

## 0. Come usare questo documento

Questo Master Plan è la fonte canonica delle decisioni di prodotto, design, ingegneria, qualità, distribuzione e business di Routally. Deve permettere a Codex o Claude Code di comprendere il progetto senza accesso alla conversazione da cui è nato.

### 0.1 Gerarchia delle fonti

In caso di conflitto, prevalgono nell'ordine:

1. questo Master Plan e le sue revisioni approvate;
2. gli Architecture Decision Record approvati in `docs/ADR/`;
3. le specifiche operative derivate in `docs/PRODUCT/`, `docs/DESIGN/`, `docs/ENGINEERING/` e `docs/RELEASE/`;
4. l'implementazione SwiftUI, le preview eseguibili e il comportamento verificato su Simulator o dispositivo;
5. le evidenze visuali e di test approvate;
6. pull request, backlog personale, note di sessione e altri appunti temporanei.

Il comportamento nativo e accessibile dei framework Apple prevale su una riproduzione rigida delle specifiche visuali quando i due entrano in conflitto. In tal caso l'implementazione e le specifiche vengono riallineate.

### 0.2 Stati delle decisioni

Ogni decisione documentata deve usare uno di questi stati:

- **Confirmed:** decisione definitiva per il perimetro indicato.
- **Deferred:** decisione intenzionalmente rinviata a una versione o milestone futura.
- **Decision Gate:** scelta da prendere quando saranno disponibili prerequisiti specifici.
- **Superseded:** decisione sostituita da una successiva; non deve essere implementata.

### 0.3 Change control

Codex e Claude Code non possono autonomamente:

- modificare il posizionamento del prodotto;
- cambiare il perimetro della 1.0 o spostare funzioni tra versioni;
- aggiungere dipendenze esterne;
- cambiare prezzi, limiti Free o diritti Lifetime;
- sostituire framework Apple con servizi esterni;
- aggiungere analytics, AI, backend o tracciamento;
- reinterpretare una decisione per ridurre lo scope senza approvazione.

Una variazione richiede una motivazione verificabile, l'analisi dell'impatto e l'approvazione del Product Owner. Le incompatibilità tecniche devono essere prima dimostrate con uno spike, un test o una limitazione ufficiale della piattaforma.

### 0.4 Principio di completezza

Una feature non è completata quando esiste soltanto una schermata. È completa quando sono coperti, dove applicabili:

- dominio e invarianti;
- persistenza e sincronizzazione;
- stati offline e degradati;
- accessibilità;
- localizzazione italiana e inglese;
- notifiche e integrazioni di sistema;
- correzione, annullamento e recupero;
- test automatici e manuali;
- privacy e sicurezza;
- comportamento Free/Plus;
- documentazione e criteri di accettazione.

### 0.5 Benchmark obbligatorio

Prima di finalizzare un pattern di navigazione, creazione, completamento, notifiche, analisi, acquisti o integrazione di sistema, il lavoro deve:

1. verificare le Human Interface Guidelines e le API Apple correnti;
2. osservare le soluzioni già rodate nelle app Apple pertinenti;
3. confrontare i competitor più vicini alla specifica funzione;
4. adottare il pattern consolidato quando è coerente con Routally;
5. documentare l'eventuale deviazione e il vantaggio atteso.

Il benchmark serve a ridurre errori e attrito, non a copiare interfacce o a introdurre feature perché popolari. Il concept di Routally, la filosofia calma e i requisiti di accessibilità restano vincolanti.

### 0.6 Lettura selettiva

Questo documento non va letto integralmente prima di ogni attività. Un agente legge sempre
questa sezione 0, i principi di prodotto (5), lo scope e i non-scope della 1.0 (6), i
technical spike e i validation gate (40), i Decision Gate aperti (50) e le decisioni
sostituite (51); poi soltanto le sezioni che il proprio intervento tocca, secondo la
matrice in `docs/ENGINEERING/agent-workflow.md`.

La sezione 40 rientra fra quelle sempre lette perché un gate tecnico vincola il lavoro di
altre sezioni: TG-RECALC precede le proiezioni, TG-DATA precede lo schema, TG-LOCATION
precede i trigger geografici. Leggerla solo quando si lavora sulla roadmap significherebbe
scoprire il vincolo dopo averlo violato.

La matrice indica le sezioni che descrivono l'oggetto dell'intervento, non l'insieme
completo di ciò che lo vincola. Le dimensioni del principio di completezza della sezione
0.4 — comportamento Free/Plus, accessibilità, localizzazione, privacy, persistenza,
correzione, notifiche e test — restano obbligatorie anche quando la loro sezione non
compare nella riga usata, e `agent-workflow.md` ne riporta la corrispondenza. Una feature
non è completa perché la sua riga di matrice è stata letta.

In dubbio sulla sezione competente si consulta l'Indice, non l'intero documento. Se una
richiesta sembra uscire dallo scope confermato o toccare una decisione sostituita, prevale
la verifica delle sezioni 6 e 51.

---

# 1. Executive summary

Routally è un'app consumer di produttività e lifestyle per gestire routine, promemoria, obiettivi, cicli di utilizzo e passi successivi collegati. La sua promessa non è semplicemente raccogliere più tracker nella stessa app, ma trattare un evento reale come unica fonte di verità e propagare automaticamente tutte le conseguenze utili.

Esempio canonico:

1. l'utente registra un allenamento una sola volta;
2. Routally aggiorna l'obiettivo settimanale della palestra;
3. incrementa il ciclo dell'asciugamano e, se configurato, quello delle scarpe o dello shaker;
4. al quarto utilizzo crea il follow-up «Prepara un asciugamano pulito»;
5. lo presenta nel momento utile, per esempio al rientro a casa o a fine giornata;
6. soltanto quando il follow-up viene completato, il ciclo dell'asciugamano riparte.

La struttura distintiva è quindi:

> **evento reale → aggiornamenti collegati → soglia → passo successivo → completamento → nuovo ciclo**

Routally 1.0 sarà un'app universale nativa per iPhone e iPad, sviluppata in Swift 6 e SwiftUI per iOS/iPadOS 26, con Liquid Glass, dark mode nativa, dati local-first e sincronizzazione privata iCloud. Non richiederà un account Routally, non userà analytics esterni, pubblicità, AI o dipendenze runtime di terze parti.

La 1.0 dovrà essere un prodotto completo e vendibile, non un MVP dimostrativo. Comprenderà:

- ricorrenze dall'ultima esecuzione;
- ricorrenze calendariali;
- obiettivi periodici;
- cicli basati su eventi, durata o quantità;
- soglie «utilizzo oppure tempo»;
- Linked Routines a un livello;
- follow-up contestuali e cicli chiusi;
- Routine Kits curati;
- Calm View «Oggi»;
- Routine, Esplora, Analisi e ricerca globale;
- promemoria temporali e geografici con fallback;
- widget, App Intents, Siri, Spotlight, Centro di Controllo e tasto Azione;
- cronologia, correzione retroattiva e ricalcolo deterministico;
- StoreKit 2 con Free, Plus annuale e Lifetime;
- accessibilità e localizzazione completa IT/EN;
- TestFlight, App Store e sito `routally.com`.

La roadmap 1.X ridurrà ulteriormente l'attrito tramite varianti, calendario, Apple Watch, Apple Health, NFC, Kit condivisibili e suggerimenti sul ritmo reale. La 2.X introdurrà account Routally, backend, routine condivise, Centro Attività, web e Android.

---

# 2. Visione, problema e opportunità

## 2.1 Problema

Le persone utilizzano strumenti separati per rappresentare la stessa realtà:

- un habit tracker per l'obiettivo «palestra 3 volte a settimana»;
- un contatore per gli utilizzi dell'asciugamano;
- un'altra app per l'usura delle scarpe;
- Promemoria per il cambio dell'asciugamano;
- un calendario per le ricorrenze fisse.

Questo produce registrazioni duplicate, dati incoerenti e carico mentale. L'utente deve ricordarsi non soltanto di fare le cose, ma anche di aggiornare manualmente tutti i tracker che ne dipendono.

## 2.2 Tesi di prodotto

Un evento reale dovrebbe essere registrato una volta sola. Tutti gli obiettivi, cicli e passi successivi che ne derivano devono essere aggiornati automaticamente, in modo trasparente e controllabile.

## 2.3 Definizione del prodotto

> **Routally è un gestore calmo di routine e cicli personali che collega ciò che fai a ciò che viene dopo.**

Routally non è:

- un task manager generico;
- un'agenda o un time blocker;
- un life logger;
- un normale habit tracker basato su streak;
- un semplice contatore di usura;
- un'app domestica o sportiva verticale;
- un editor tecnico di automazioni.

## 2.4 Pubblico iniziale

Routally si rivolge a due profili compatibili:

1. persone che vogliono organizzarsi meglio senza dover ricordare e registrare più volte le stesse cose;
2. persone molto attente all'ordine, alle abitudini e alla precisione, che vogliono fare le cose per bene senza perdere passaggi.

Sintesi:

> **Persone che amano avere le proprie routine sotto controllo, ma non vogliono trasformare la vita quotidiana in un lavoro di registrazione.**

Il prodotto deve offrire **completezza senza ossessione**: abbastanza semplice per l'utente occasionale e abbastanza preciso per l'utente molto organizzato.

## 2.5 Criterio di ammissione dei casi d'uso

Una routine o un Kit è coerente con Routally quando:

1. la registrazione è naturale e non eccessivamente frequente;
2. produce almeno una conseguenza utile e concreta;
3. evita una registrazione o un promemoria separato;
4. modifica ciò che l'utente deve fare;
5. il risparmio mentale supera lo sforzo di registrazione;
6. l'app può restare silenziosa finché non serve attenzione.

Non va tracciato qualcosa soltanto perché è tecnicamente possibile contarlo.

---

# 3. Posizionamento competitivo e originalità

## 3.1 Benchmark sintetico

Il mercato contiene prodotti forti su singoli segmenti:

- **DoneAgo:** stato attuale, tempo trascorso, cambio di stato e nudges senza streak;
- **KountEm:** utilizzo e usura di oggetti, doppia scadenza per uso e tempo, cronologia;
- **Tody:** attività domestiche ordinate in base alla necessità reale;
- **ReDo Loop / task ricorrenti:** ricorrenze dall'ultima esecuzione o fisse;
- **habit tracker:** obiettivi periodici, streak e progressi;
- **counter/automation tools:** contatori e trigger tecnici;
- **Comandi Rapidi:** automazioni potenti ma da configurare manualmente.

Routally non deve sostenere che nessun prodotto al mondo possieda una funzione simile. Il posizionamento credibile è:

> **Nessuna delle applicazioni consumer benchmarkate combina con pari semplicità obiettivi periodici, ricorrenze dinamiche, cicli di utilizzo, conseguenze multiple, follow-up contestuali e riavvio del ciclo a partire da una sola registrazione reale.**

### 3.1.1 Validazione del mercato e natura dell'opportunità

La domanda generale è già validata da app di pulizie, routine, habit tracking, contatori e manutenzione personale. La disponibilità a pagare esiste, ma il mercato è frammentato e competitivo.

La tesi commerciale approvata è prudente:

- Routally è una buona opportunità per un prodotto consumer indipendente;
- non si presume che sia automaticamente una startup venture-scale;
- il costo di costruzione Apple-native è compatibile con una validazione lean;
- il rischio principale non è la fattibilità del motore, ma acquisizione, comprensione, abitudine alla registrazione e retention;
- la differenziazione deve derivare dall'insieme `single log + closed cycles + right-time follow-up + Kits + calm UX`, non da una sola feature facilmente replicabile.

### 3.1.2 Tre tipi di collegamento da non confondere

1. **Sequenziale:** fai A, poi B, poi C; tipico dell'habit stacking e di prodotti come ChainRoutine.
2. **A pacchetto:** un tap registra insieme più abitudini svolte nello stesso momento; presente in tracker come Habit Nova/HabitIt.
3. **Per conseguenze — Routally:** un evento reale aggiorna obiettivi, cicli, stato e passi successivi che possono manifestarsi in momenti diversi.

Routally presidia il terzo modello. Non deve essere descritta come una semplice catena di azioni o una routine composta.

### 3.1.3 Matrice dei pattern adottati e rifiutati

| Fonte | Pattern utile da adottare | Limite da non replicare |
|---|---|---|
| Tody | priorità basata sulla necessità reale | verticalità esclusiva sulle pulizie |
| DoneAgo | stato leggibile, tempo trascorso, assenza di pressione da streak | tracker indipendenti non orchestrati da un evento sorgente |
| KountEm/SparesBro | logging rapido, soglie uso/tempo, storico del ciclo | centralità dell'oggetto e aggiornamenti manuali separati |
| ReDo Loop | ricorrenza che riparte dall'esecuzione reale | modello limitato al task ricorrente |
| Tally/Amazing Marvin | obiettivi e contatori flessibili | secondo tap e reset manuali per gli elementi collegati |
| Habtik | sincronizzazione tra task e abitudine | relazione più semplice, non propagazione verso più cicli e follow-up |
| Counter | potenza di trigger e contatori derivati | formule, webhook e linguaggio tecnico |
| Habitify | pausa, skip e tracker in secondo piano | gamification, linguaggio di fallimento e streak centrali |
| Structured | chiarezza dell'agenda | timeline oraria completa, non coerente con Calm View |
| Promemoria Apple | controllo esplicito, undo e interazioni familiari | task manager generico |
| Comandi Rapidi/Casa | Galleria/Esplora separata dalla creazione strutturata, `+` contestuale | editor tecnico di automazioni |

## 3.2 Differenza rispetto a DoneAgo

DoneAgo parte da una scheda e dal suo stato:

> «In quale stato si trova e da quanto tempo?»

Routally parte da un evento reale e dalle sue conseguenze:

> «Dopo ciò che ho appena fatto, quali obiettivi, cicli e passi successivi devono aggiornarsi?»

Routally aggiunge:

- obiettivi periodici;
- aggiornamento automatico di più elementi;
- soglie per utilizzo, durata o quantità;
- creazione di un'attività successiva;
- momento utile diverso dal momento in cui nasce la necessità;
- completamento che chiude e riavvia il ciclo;
- Kit che installano sistemi collegati, non singole schede.

## 3.3 Differenza rispetto a KountEm

KountEm parte da un oggetto e dalla sua vita utile:

> «Quanto è stato usato e quando va sostituito?»

Routally parte dall'attività che alimenta il ciclo:

> «La corsa aggiorna l'obiettivo settimanale e i chilometri delle scarpe; alla soglia genera il controllo e, dopo la sostituzione, avvia il nuovo ciclo.»

Routally aggiunge:

- attività e obiettivi nello stesso sistema dell'oggetto;
- evento sorgente condiviso;
- propagazione a più cicli;
- follow-up operativo anziché solo alert;
- reminder nel contesto utile;
- reset legato al completamento reale del follow-up;
- Calm View e Kit consumer.

## 3.4 Selling point ufficiali

### 3.4.1 Linked Routines

Una registrazione aggiorna più routine, obiettivi e cicli collegati.

### 3.4.2 Routine Cycles

Routally gestisce l'intero ciclo:

> utilizzo → soglia → passo successivo → completamento → nuovo ciclo.

### 3.4.3 Smart Follow-ups

La necessità può nascere in un momento, ma il promemoria viene presentato quando l'utente può agire: a casa, a fine giornata, alla prossima visita o prima della prossima routine.

### 3.4.4 Routine Kits

I Kit installano attività, collegamenti, soglie, follow-up, reminder e reset già coerenti tra loro.

### 3.4.5 Calm View

Routally mostra ciò che richiede attenzione e non costruisce una lista permanente di debiti, streak rotte o punteggi di perfezione.

### 3.4.6 Automazioni trasparenti

Dopo una registrazione, l'utente vede cosa è stato aggiornato, può annullare tutto o correggere una singola conseguenza.

### 3.4.7 Completezza senza life logging

Routally supporta eventi, durata e quantità, ma promuove soltanto casi in cui la registrazione produce una decisione utile.

## 3.5 Promesse di comunicazione

Messaggi secondari approvati:

- **Log once. Routally handles what follows.**
- **Track less. Remember more.**
- **Only what matters, when it matters.**
- **Routally collega ciò che fai a ciò che viene dopo.**

Non usare nel marketing consumer termini come «trigger», «workflow», «dipendenza», «orchestrazione» o «automazione condizionale».

---

# 4. Brand e identità

## 4.1 Nome

**Brand definitivo:** `Routally`

Interpretazione concettuale:

- **routine:** attività ricorrenti;
- **tally:** conteggi, utilizzi e progressi;
- **ally:** assistente quotidiano.

Grafia ufficiale: **Routally**. Non usare `RouTally`, `RoutAlly` o altre capitalizzazioni interne.

Pronuncia di riferimento:

- italiano: **ru-tàl-li**;
- inglese: **roo-TAL-ee**.

Due diligence preliminare:

- non è emersa un'app attiva rilevante con il nome esatto;
- esiste un precedente esatto come progetto di product design pubblicato su Behance, non verificato come prodotto commercializzato;
- esistono nomi vicini legati a route/routing e routine tracker, ma non equivalgono a usi esatti di Routally;
- la disponibilità web non equivale a clearance del marchio.

Il nome esteso `Routally: Linked Routines` / `Routally: Routine collegate` ha anche il compito di eliminare l'eventuale lettura `route + ally` e chiarire subito la categoria. La verifica formale resta nel Decision Gate DG-TRADEMARK.

## 4.2 Nome App Store

### Inglese

- **Nome:** `Routally: Linked Routines`
- **Sottotitolo:** `Reminders, goals & progress`

### Italiano

- **Nome:** `Routally: Routine collegate`
- **Sottotitolo:** `Promemoria, goal e progressi`

## 4.3 Tagline

### Inglese

> **Your routines, working together.**

### Italiano

> **Le tue routine, finalmente collegate.**

## 4.4 Descriptor

### Inglese

> A calm routine manager that connects reminders, goals, usage cycles and follow-ups.

### Italiano

> Un gestore di routine che collega promemoria, obiettivi, cicli di utilizzo e passi successivi.

## 4.5 Tono

Il tono deve essere:

- calmo;
- preciso;
- concreto;
- incoraggiante senza essere motivazionale;
- non giudicante;
- breve;
- privo di gergo tecnico.

Esempi:

- «È il momento di cambiare l'asciugamano», non «Hai superato il limite».
- «2 allenamenti su 3 questa settimana», non «Obiettivo incompleto».
- «Vuoi rendere questa frequenza più realistica?», non «Prestazione sotto target».

## 4.6 Colore

Colore di brand predefinito: **indaco / blu-viola non eccessivamente saturo**.

Motivazioni:

- produttività e controllo;
- più consumer di un blu aziendale;
- più distintivo del verde tipico dei tracker;
- adatto a light, dark, high contrast e Liquid Glass;
- non collide con i colori semantici di completamento o attenzione.

Accenti Plus curati:

- Routally Indigo;
- Ocean;
- Teal;
- Amber;
- Coral;
- Violet.

Sistema, Chiaro e Scuro sono disponibili a tutti. I colori semantici non sono personalizzabili.

Non sono previsti:

- temi completi;
- sfondi decorativi;
- font alternativi;
- selettori cromatici illimitati;
- colori indipendenti per ogni card.

La personalità emerge da accento, Routine Cycles, microanimazioni native e feedback aptico, sempre compatibili con Reduce Motion.

## 4.7 Tipografia

- San Francisco tramite stili SwiftUI semantici;
- Dynamic Type obbligatorio;
- nessun font incluso nel bundle;
- SF Rounded soltanto come accento limitato in stati vuoti, numeri dei cicli o materiali promozionali.

## 4.8 Icona

### Direzione predefinita

**Azione centrale e conseguenze collegate:** un elemento centrale dal quale si propagano tre cicli o elementi, con composizione che suggerisce discretamente una `R`.

### Alternative da mantenere nell'esplorazione vettoriale

1. `R` formata da due cicli collegati;
2. un gesto che genera più onde;
3. tre elementi che chiudono un ciclo;
4. tally marks collegati.

La scelta finale avverrà dopo prove con asset SVG in Icon Composer e sui dispositivi target. Un piccolo user test deve mostrare le alternative senza spiegazione preventiva, per verificare riconoscibilità e associazioni spontanee.

Criteri:

- dimensioni piccole;
- aspetto standard, scuro e monocromatico;
- distinzione da reminder, navigatori, condivisione, reti, sincronizzazione e app di automazione;
- percezione consumer;
- leggibilità senza testo;
- coerenza con il nome.

**Decision Gate DG-ICON:** scelta definitiva prima della produzione dei materiali App Store.

## 4.9 Routine Kits visuali

- SF Symbols riconoscibili;
- piccolo accento cromatico;
- visualizzazione funzionale del collegamento o ciclo;
- niente fotografie stock;
- niente stile cartoon o 3D dominante;
- illustrazioni elaborate soltanto per onboarding e stati vuoti.

## 4.10 Dominio

Dominio principale previsto: **`routally.com`**.

Email previste:

- `support@routally.com`
- `hello@routally.com`
- eventuale `security@routally.com`

`routally.app` può essere acquistato come dominio difensivo e reindirizzato al `.com`, ma non è obbligatorio.

**Decision Gate DG-DOMAIN:** registrazione effettiva del dominio e configurazione DNS/email.

---

# 5. Principi di prodotto

1. **Segna una volta, aggiorna tutto.**
2. **La complessità resta nel motore, non nell'interfaccia.**
3. **Precisione senza ossessione.**
4. **Il momento della necessità e il momento utile possono essere diversi.**
5. **Le automazioni sono visibili, spiegabili e annullabili.**
6. **Le routine sono un unico concetto per l'utente, ma un dominio modulare nel codice.**
7. **Il prodotto è local-first, offline-capable e privacy-first.**
8. **Apple-native prima di custom.**
9. **Le funzioni di affidabilità non sono leve artificiali di paywall.**
10. **Nessun dato, grafico o reminder viene mostrato se non aiuta una decisione.**
11. **Una funzione incompleta viene rinviata, non pubblicata in forma fragile.**
12. **Il comportamento quotidiano non dipende da background task, rete o CloudKit.**

---

# 6. Scope e non-scope della 1.0

## 6.1 Scope funzionale obbligatorio

- attività «dopo l'ultima volta»;
- ricorrenze in giorni o date stabilite;
- obiettivi entro un periodo;
- eventi semplici `+1`;
- durata;
- quantità e unità personalizzabili;
- soglia per utilizzo;
- soglia per tempo;
- condizione `utilizzo OR tempo`;
- Linked Routines dirette;
- un evento che aggiorna più elementi;
- follow-up generato dalla soglia;
- follow-up temporale o geografico;
- riavvio del ciclo al completamento;
- correzione retroattiva;
- cronologia, revisioni e annullamento;
- Routine Kits;
- Oggi, Routine, Esplora, Analisi, Cerca e Profilo;
- notifiche locali;
- luoghi salvati;
- widget e App Intents;
- iCloud seamless;
- StoreKit 2;
- italiano e inglese;
- iPhone e iPad;
- light/dark mode;
- accessibilità completa.

## 6.2 Esclusioni 1.0

- task manager generico;
- account Routally;
- backend proprietario;
- condivisione tra utenti;
- Android, web o macOS;
- Apple Watch;
- Apple Health;
- NFC;
- allegati, foto o documenti negli eventi;
- AI;
- analytics esterni;
- advertising;
- notifiche remote promozionali;
- scripting o formule;
- catene multilivello;
- editor visuale di workflow;
- inventario domestico completo;
- life logging ad alta frequenza;
- backup manuale o file `.routally`;
- app lock Face ID interno;
- Live Activities o Dynamic Island;
- Centro Attività;
- community GitHub.

## 6.3 Confine rispetto ai task singoli

Routally accetta un'azione una tantum soltanto quando deriva da una routine o chiude un ciclo, per esempio:

- «Prepara un asciugamano pulito» generato dopo quattro allenamenti.

Non è destinata a:

- comprare un regalo;
- rispondere a una mail;
- prenotare un ristorante;
- finire una presentazione;
- gestire una lista generica di attività.

---

# 7. Piattaforme ed esperienza Apple-native

## 7.1 Target

- **Deployment target:** iOS 26 e iPadOS 26.
- **Linguaggio:** Swift 6.
- **UI:** SwiftUI, Observation e componenti Apple nativi.
- **Design:** Liquid Glass applicato attraverso controlli e superfici di sistema.
- **App universale:** un solo prodotto iPhone/iPad.

Non viene mantenuta una seconda UI per iOS precedenti: la scelta iOS 26 consente un unico linguaggio Liquid Glass, meno fallback e una matrice di test più controllabile. L'impatto sulla base installata viene monitorato nel risk register.

## 7.2 iPhone

- piattaforma primaria;
- esperienza completamente ottimizzata;
- priorità all'uso verticale e con una mano;
- supporto a tutte le dimensioni compatibili con iOS 26;
- landscape soltanto dove utile o richiesto dal sistema.

## 7.3 iPad

La 1.0 non deve essere una UI iPhone ingrandita. Deve supportare:

- finestre ridimensionabili;
- multitasking;
- portrait e landscape;
- layout a una o due colonne;
- `NavigationSplitView` dove migliora Routine ed Esplora;
- tastiera, puntatore e scorciatoie essenziali;
- Dynamic Type e accessibilità equivalenti all'iPhone.

Non sono previste funzioni esclusive iPad nella 1.0.

Rinviati:

- gestione avanzata di più finestre Routally;
- drag and drop complesso;
- menu bar estesa;
- dashboard esclusiva iPad;
- Catalyst/macOS.

## 7.4 Dark mode

Requisito bloccante della 1.0:

- modalità Sistema predefinita;
- selezione Chiaro o Scuro nel Profilo;
- colori semantici dinamici;
- asset adattivi;
- test con Aumenta contrasto e Riduci trasparenza;
- nessuna dipendenza da uno sfondo specifico.

## 7.5 Regola Liquid Glass

- tab bar, navigation bar, toolbar, sheet e controlli nativi adottano il materiale di sistema;
- nessuna barra custom disegnata manualmente;
- niente «vetro» applicato indiscriminatamente alle card di contenuto;
- il contenuto resta leggibile e gerarchicamente distinto dalla navigazione;
- eventuali componenti Routally personalizzati devono degradare correttamente con Riduci trasparenza.

---

# 8. Architettura dell'informazione e navigazione

## 8.1 Tab bar inferiore

### Italiano

> **Oggi · Routine · Esplora · Analisi** + **Cerca**

### Inglese

> **Today · Routines · Explore · Insights** + **Search**

Le quattro destinazioni principali sono tab native. Cerca usa il pattern di ricerca separata nella tab bar, non una quinta area equivalente.

L'ordine è stabile e non viene riordinato automaticamente in base all'uso, per preservare la memoria spaziale.

## 8.2 Navigation bar superiore

La navigation bar è minimale e non sostituisce la tab bar.

| Area | Titolo | Azioni permanenti |
|---|---|---|
| Oggi | Oggi | Profilo |
| Routine | Routine | `+`, Profilo |
| Esplora | Esplora | Profilo |
| Analisi | Analisi | Profilo |

Regole:

- il `+` appare soltanto in Routine;
- Profilo compare nelle radici delle tab, non necessariamente nei dettagli;
- nessun pulsante flottante;
- nessun `+` dentro la tab bar;
- nessuna tab Account, Impostazioni, Calendario, Cronologia, Notifiche o Altro.

## 8.3 Cerca

Cerca è una funzione globale e permanente della 1.0.

Contenuti indicizzati:

- routine attive, in pausa e archiviate;
- follow-up aperti e completati di recente;
- Aree e categorie;
- Routine Kits;
- parole chiave e sinonimi dei Kit.

Esclusioni iniziali:

- eventi storici molto vecchi come risultati singoli;
- testo interno di Analisi;
- impostazioni;
- note personali, salvo decisione futura esplicita.

Schermata iniziale:

- routine recenti;
- follow-up aperti;
- ricerche recenti;
- Kit suggeriti.

Filtri:

> **Tutto · Routine · Follow-up · Kit**

La ricerca:

- è on-device;
- conserva la tab di provenienza e, quando viene chiusa, riporta l'utente alla destinazione precedente;
- supporta sinonimi IT/EN;
- tollera piccoli errori;
- apre l'elemento al tocco;
- offre azioni rapide non distruttive con pressione prolungata;
- non diventa un editor complesso.

## 8.4 Profilo locale

La 1.0 possiede un **Profilo** locale, non un account remoto.

Il profilo ha un UUID stabile indipendente da SwiftData, CloudKit e Apple Account. Nella 2.0 la stessa schermata e lo stesso profilo locale potranno essere associati a un Account Routally senza riprogettare la navigazione o ricreare le routine.

Il Profilo contiene:

### Identità facoltativa

- nome o soprannome;
- iniziali, Memoji, simbolo o immagine;
- colore personale.

### Preferenze quotidiane

- primo giorno della settimana;
- orario indicativo di fine giornata;
- fascia silenziosa;
- unità metriche o imperiali;
- formato data e ora;
- riepilogo dopo registrazioni collegate;
- comportamento predefinito dei nuovi cicli e dei follow-up, sempre modificabile nella singola routine.

### Contesto

- Casa e altri luoghi salvati;
- giorni normalmente attivi o esclusi;
- fallback temporali;
- autorizzazioni.

### Aspetto e accessibilità

- Sistema, Chiaro, Scuro;
- accento Plus;
- feedback aptico;
- animazioni;
- link alle impostazioni native rilevanti.

### Dati e servizio

- stato iCloud;
- esportazione CSV;
- Eliminati di recente;
- eliminazione completa dei dati;
- piano Routally Plus;
- ripristino acquisti;
- supporto, privacy, termini e informazioni.

Nome e avatar non sono richiesti nell'onboarding. Non vengono richiesti età, genere, professione o altri dati di profilazione. Il nome può essere usato soltanto in formule discrete e disattivabili, per esempio «Tutto sotto controllo, Matteo».

## 8.5 Futuro Centro Attività

**Deferred 2.1.**

Il Centro Attività verrà introdotto quando account e routine condivise produrranno eventi di sistema, per esempio:

- completamento da parte di un'altra persona;
- assegnazione o riassegnazione;
- inviti;
- modifiche a spazi condivisi;
- problemi di sincronizzazione multipiattaforma.

Non sarà una cronologia delle notifiche e non duplicherà Oggi.

---

# 9. Schermata Oggi — Calm View

## 9.1 Obiettivo

Oggi risponde a una sola domanda:

> **Che cosa richiede davvero la mia attenzione adesso?**

Non mostra indiscriminatamente tutte le routine e non è una timeline oraria.

## 9.2 Sezioni dinamiche

### Adesso

- routine che è il momento di svolgere;
- follow-up diventati utili;
- elementi nello stato Da fare o Richiede attenzione.

### Più tardi

- elementi già previsti per il resto della giornata;
- reminder la cui finestra utile non è ancora iniziata.

### Questa settimana

- massimo 3 obiettivi;
- possibilità di fissare manualmente obiettivi preferiti;
- collegamento «Mostra tutti».

La selezione è deterministica, testabile e spiegabile: nessun punteggio opaco e nessun
modello. La regola è la seguente.

**Esclusioni.** Sono esclusi gli obiettivi di routine in pausa o archiviate, quelli il cui
periodo è già stato raggiunto e quelli il cui periodo è appena iniziato e non è a rischio.

**Ordine.** Gli obiettivi fissati manualmente occupano i primi posti, nel loro ordine.
I posti restanti seguono queste classi, nell'ordine:

1. **Non più raggiungibile:** le occorrenze mancanti superano le occasioni utili residue del periodo.
2. **A rischio:** le occorrenze mancanti sono pari alle occasioni utili residue.
3. **In corso:** almeno una registrazione nel periodo e obiettivo non ancora raggiunto.

A parità di classe l'ordine è: fine del periodo più vicina, poi quota mancante maggiore,
poi nome secondo il confronto locale. L'ordinamento è totale e stabile: a parità di tutti
i criteri l'ordine non cambia tra due valutazioni consecutive.

La classe determina anche il testo di contesto della riga, così che l'utente veda sempre
perché quell'obiettivo è lì. La classe 1 non usa linguaggio di fallimento e propone, quando
pertinente, di rivedere la frequenza.

### Tutto sotto controllo

Stato positivo quando non serve intervenire. Non deve forzare l'utente a creare lavoro per riempire la schermata.

## 9.3 Forma visiva

Preferenza per una **lista Apple evoluta**, compatta e leggibile:

- riga compatta per routine normale;
- riga leggermente espansa per soglie e follow-up;
- piccolo modulo riepilogativo per obiettivi settimanali;
- card grandi soltanto per riepiloghi o stati importanti.

Ogni riga contiene soltanto:

- icona;
- titolo;
- una riga di contesto;
- progresso quando utile;
- azione primaria.

## 9.4 Azioni

- `Registra` per un evento reale;
- `Fatto` per chiudere un follow-up;
- tocco sul corpo della riga per il dettaglio;
- swipe per Rinvia o Salta questa volta, dove semanticamente valido;
- pressione prolungata per azioni meno frequenti;
- nessuna funzione accessibile soltanto tramite gesto.

## 9.5 Riepilogo dopo la registrazione

### Caso semplice

- aggiornamento immediato;
- feedback aptico;
- messaggio discreto con `Annulla`.

### Caso collegato

Riepilogo compatto dal basso:

> **Allenamento registrato**  
> Palestra: 2/3  
> Asciugamano: 4/4  
> Creato: Prepara un asciugamano pulito
>
> `Annulla` · `Visualizza`

Il riepilogo:

- non blocca l'utente;
- si chiude automaticamente;
- consente di escludere una conseguenza;
- mostra sempre cosa è accaduto e perché.

## 9.6 Follow-up e momento utile

Soglia, creazione del follow-up, visibilità e reset sono eventi distinti.

Nel caso dell'asciugamano:

1. il quarto allenamento porta il ciclo a `4/4`;
2. il follow-up viene creato;
3. non entra necessariamente subito in Adesso;
4. diventa visibile al rientro a casa, a fine giornata o nel momento configurato;
5. il ciclo resta `4/4` finché il follow-up non viene completato;
6. solo allora riparte da zero.

---

# 10. Tab Routine

## 10.1 Struttura

Lista nativa compatta, non griglia di grandi card. Non esistono sezioni principali separate chiamate Obiettivi, Contatori o Promemoria: sono componenti dello stesso modello di Routine.

Ogni riga può mostrare:

- nome e icona;
- stato;
- prossimo momento;
- progresso;
- sorgente del collegamento;
- indicatore di attenzione.

## 10.2 Organizzazione

### Fissate

Routine che l'utente mantiene in alto.

### Aree

Categorie suggerite o personalizzabili, per esempio:

- Benessere;
- Casa;
- Cura personale;
- Studio;
- Sport;
- Hobby;
- area personalizzata.

I Kit propongono un'Area, ma non la impongono.

### Filtri

- Tutte;
- Attive;
- Collegate;
- In pausa;
- Archiviate.

Non esistono tab separate per habit, contatori e promemoria.

### Ordinamento

- manuale;
- alfabetico;
- usate di recente;
- prossime a richiedere attenzione.

Oggi gestisce le priorità dinamiche; Routine gestisce la struttura dell'utente.

## 10.3 Creazione

Il `+` in alto a destra apre **un solo flusso: Nuova routine**.

Non esistono tre modalità concorrenti chiamate rapida, guidata e Kit.

La creazione è:

- rapida per impostazione predefinita;
- progressivamente configurabile;
- collegata a Esplora tramite «Parti da un Kit».

---

# 11. Pagina di dettaglio della routine

## 11.1 Domande a cui deve rispondere

1. In che stato si trova?
2. Qual è l'azione primaria?
3. Che cosa succede quando viene registrata?
4. Come è configurata?

## 11.2 Struttura

### Header

- titolo;
- stato o progresso;
- ultima registrazione;
- azione primaria `Registra` o `Fatto`.

### Conseguenze

Sezione obbligatoria per le routine collegate:

> **Quando registri Palestra**
>
> - aggiorna l'obiettivo settimanale;
> - aggiunge 1 utilizzo ad Asciugamano palestra;
> - aggiunge 1 utilizzo a Scarpe palestra.

### Configurazione

Righe di navigazione:

- Frequenza e obiettivo;
- Collegamenti;
- Passo successivo;
- Promemoria;
- Visualizzazione.

### Cronologia

Timeline con:

- evento;
- data e ora;
- quantità o durata;
- note;
- conseguenze;
- soglie;
- follow-up;
- modifiche, annullamenti e ricalcoli.

### Comandi

- `Modifica` visibile;
- menu `…` per duplicare, mettere in pausa, archiviare o eliminare.

La registrazione manuale resta possibile anche per cicli normalmente alimentati da un'altra routine, per gestire eccezioni reali.

---

# 12. Esplora e Routine Kits

## 12.1 Ruolo

Esplora è una destinazione permanente, non un semplice onboarding. Serve a:

- insegnare il modello Routally;
- mostrare casi d'uso utili;
- installare sistemi già configurati;
- scoprire possibilità non ovvie.

## 12.2 Home di Esplora

Raccolte curate:

- Per iniziare;
- Routine collegate;
- Sport e benessere;
- Casa senza stress;
- Cura personale;
- Studio e apprendimento;
- Piante e animali;
- Più popolari;
- Nuovi Kit.

Le raccolte sono righe orizzontali compatte con «Mostra tutti».

## 12.3 Scheda Kit

Ogni Kit mostra:

- titolo basato sull'attività principale;
- beneficio in linguaggio naturale;
- cosa verrà creato;
- valori suggeriti;
- routine, collegamenti, follow-up e reminder;
- numero di routine e collegamenti consumati nel piano Free;
- disponibilità Free o Plus.

Esempio:

> **Palestra**  
> Registra ogni allenamento una sola volta. Routally aggiorna il tuo obiettivo e i cicli dell'attrezzatura collegata.

## 12.4 Azioni

- `Aggiungi Kit` quando i default sono sufficienti;
- `Configura e aggiungi` quando serve una scelta personale;
- `Personalizza` come azione secondaria.

## 12.5 Versionamento

Dopo l'installazione, il Kit diventa una copia indipendente e modificabile.

- nessun aggiornamento silenzioso;
- identificativo e versione di origine conservati;
- aggiornamenti facoltativi nella 1.3, con anteprima delle modifiche.

## 12.6 Regola dei titoli

I Kit prendono il nome dall'attività o ambito principale. Collegamenti e conseguenze appartengono al sottotitolo e all'anteprima.

---

# 13. Tab Analisi

## 13.1 Scopo

Analisi serve a comprendere e regolare il sistema, non a giudicare l'utente.

Non è una dashboard di performance, streak o perfezione.

## 13.2 Struttura

### In evidenza

Massimo tre osservazioni utili, deterministiche e spiegabili.

Esempi:

- «Lenzuola: impostate ogni 5 giorni, completate mediamente ogni 6,2.»
- «Il follow-up dell'asciugamano viene normalmente completato la sera stessa.»
- «Questa routine viene spesso rinviata; vuoi rivederne la frequenza?»

### Panoramica del periodo

Selettore:

> 4 settimane · 3 mesi · 6 mesi · 1 anno

Possibili metriche:

- eventi registrati;
- obiettivi raggiunti;
- cicli chiusi;
- tempo medio di chiusura dei follow-up;
- routine rinviate, saltate o messe in pausa.

### Routine da rivedere

Solo con segnale concreto:

- frequenza diversa da quella impostata;
- follow-up spesso aperti;
- routine quasi mai usata;
- soglia probabilmente troppo breve o lunga.

### Cronologia generale

Filtri per:

- registrazioni;
- cicli;
- follow-up;
- modifiche e correzioni.

## 13.3 Grafici

- Swift Charts;
- pochi grafici e soltanto quando chiariscono un andamento;
- barre per confronti;
- linee per intervalli nel tempo;
- riepilogo testuale sempre presente;
- VoiceOver e rappresentazione accessibile;
- niente anelli decorativi per ogni routine.

## 13.4 Gate di evidenza

### Dati descrittivi

Possono apparire quasi subito.

### Pattern semplici

Indicativamente dopo:

- almeno 4 registrazioni;
- almeno 2 cicli o periodi;
- intervallo sufficiente.

### Suggerimenti

Indicativamente dopo:

- almeno 6 registrazioni;
- almeno 3 cicli o 4 settimane;
- differenza coerente e materiale;
- assenza di pause o anomalie dominanti.

Ogni insight spiega la base:

> Basato su 7 registrazioni negli ultimi 42 giorni.

Routally:

- distingue fatti osservati, pattern possibili e suggerimenti;
- non trasforma correlazioni in affermazioni causali;
- non modifica mai frequenze, soglie o regole senza conferma esplicita.

Può mostrare serenamente «Servono ancora alcuni dati».

## 13.5 Nessuna AI

Le osservazioni della 1.0 sono basate su regole deterministicamente testabili. Nessun modello generativo, cloud o classificatore opaco.

---

# 14. Onboarding e creazione

## 14.1 Onboarding

Onboarding minimo, facoltativo e contestuale.

### Prima schermata

> **Routally**  
> Le tue routine, finalmente collegate.
>
> Registra ciò che fai una sola volta. Routally aggiorna obiettivi, cicli e prossimi passi.

Azioni:

- `Inizia`;
- `Esplora l'app`.

### Da cosa vuoi partire?

- Scegli un Kit;
- Crea una routine;
- Non sono sicuro — mostrami qualche esempio.

Gli esempi non creano dati senza conferma.

### Permessi

Non chiedere all'avvio:

- nome o avatar;
- notifiche;
- posizione;
- recensione;
- acquisto.

I permessi vengono richiesti nel momento d'uso.

TipKit insegna progressivamente:

- riepilogo degli aggiornamenti;
- follow-up;
- correzione;
- ricerca e widget.

## 14.2 Un solo flusso di creazione

Il flusso deve essere rapido per default.

1. **Che cosa vuoi gestire?**
2. **Come vuoi misurarlo o quando deve accadere?**
3. Quando sono presenti i dati minimi, appare `Crea routine`.
4. `Continua a configurare` aggiunge collegamenti, follow-up, luoghi e reset.

Risposte iniziali preimpostate:

- qualcosa da fare con regolarità;
- un obiettivo da raggiungere;
- qualcosa da cambiare, pulire o controllare dopo alcuni utilizzi;
- qualcosa che dipende da un'altra routine;
- non sono sicuro.

Per una routine semplice, il percorso rapido deve richiedere soltanto nome, regola essenziale e, quando utile, momento del promemoria.

Scorciatoia secondaria:

> Parti da un Kit

## 14.3 Domande e risposte preimpostate

Ogni domanda offre opzioni pronte, una scelta consigliata quando possibile e `Altro` o `Personalizza`.

Esempi:

> **Dopo quanti allenamenti?**  
> 3 · **4 consigliato** · 5 · Altro

> **Quando vuoi ricevere il promemoria?**  
> Subito · Questa sera · Quando arrivo a casa · Altro

> **Quando lo completi?**  
> Inizia un nuovo ciclo · Mantieni il conteggio · Chiedimelo ogni volta

## 14.4 Macro-fasi

1. **Routine** — che cosa gestire;
2. **Regola** — frequenza, obiettivo o soglia;
3. **Cosa succede dopo** — collegamenti e follow-up;
4. **Quando ricordartelo** — momento o contesto.

Non usare una sezione «Avanzate».

### 14.4.1 Domande minime per archetipo

**Dopo l'ultima volta**

1. che cosa ricordare;
2. quanto tempo deve passare;
3. quando avvisare.

**In giorni stabiliti**

1. attività;
2. giorni/data e periodicità;
3. orario e comportamento delle occasioni non registrate.

**Obiettivo periodico**

1. attività;
2. quantità e periodo;
3. eventuale promemoria quando il periodo sta terminando.

**Ciclo basato su utilizzo/durata/quantità**

1. cosa cambiare, pulire o controllare;
2. quale evento lo alimenta oppure come registrarlo manualmente;
3. soglia;
4. passo successivo;
5. momento del follow-up;
6. riavvio del ciclo.

**Routine collegata**

1. quali elementi aggiornare;
2. incremento applicato a ciascuno;
3. riepilogo delle conseguenze.

Le varianti condizionali per singola esecuzione appartengono alla 1.1; la 1.0 mantiene link diretti comprensibili.

## 14.5 Riepilogo finale

Durante il flusso, un riepilogo in linguaggio naturale si aggiorna progressivamente con le risposte. Prima del salvataggio mostra la versione completa:

> Quando completi **Palestra**, aggiorna il tuo obiettivo settimanale e aggiungi un utilizzo ad **Asciugamano palestra**. Dopo **4 utilizzi**, crea **Prepara un asciugamano pulito** e ricordalo **quando arrivi a casa**. Quando lo completi, **inizia un nuovo ciclo**.

Schede modificabili:

- Frequenza;
- Collegamenti;
- Passo successivo;
- Promemoria.

Le stesse schede restano disponibili nel dettaglio.

---

# 15. Motore funzionale

## 15.1 Un solo concetto per l'utente

Nell'interfaccia esiste una sola idea: **Routine**.

L'utente non deve scegliere tra mondi separati chiamati habit, counter, maintenance e reminder.

## 15.2 Dominio modulare nel codice

La Routine è un aggregato concettuale composto da tipi forti, non una classe monolitica con decine di proprietà opzionali.

Componenti indicativi:

- `RoutineDefinition`
- `FrequencyRule`
- `GoalRule`
- `MeasurementRule`
- `UsageCycle`
- `RoutineLink`
- `ThresholdRule`
- `FollowUpPolicy`
- `ReminderPolicy`
- `LocationContext`
- `CycleState`
- `RoutineEvent`
- `EventRevision`
- `ProjectionSnapshot`
- `SyncMetadata`
- `Tombstone`

La nomenclatura finale potrà essere adattata tramite ADR, senza cambiare il modello approvato.

## 15.3 Modalità di misurazione

### Evento semplice

Ogni registrazione vale `+1`.

Esempi:

- allenamento;
- rasatura;
- annaffiatura;
- sessione di studio.

### Durata

Valore temporale:

- 15 min;
- 30 min;
- 45 min;
- valore personalizzato.

### Quantità

Valore e unità:

- chilometri;
- pagine;
- litri;
- cicli;
- unità personalizzata.

L'utente può configurare:

- incremento fisso;
- valori rapidi;
- ultimo valore;
- input manuale.

Esempio corsa:

- obiettivo settimanale `+1`;
- scarpe `+6,4 km`.

## 15.4 Modalità temporali

### Dopo l'ultima volta

La prossima necessità riparte dal completamento reale.

> Lava le lenzuola 5 giorni dopo l'ultimo lavaggio.

### In giorni stabiliti

Il calendario non cambia con il completamento.

> Martedì e giovedì alle 19:00.

Supporto 1.0:

- giorni della settimana;
- ogni X settimane;
- giorno del mese;
- intervallo calendariale semplice;
- orario.

### Entro un periodo

Conta il risultato complessivo.

> Palestra 3 volte a settimana.

Il periodo si azzera senza carry-over.

## 15.5 Semantica del tempo

- minuti e ore = tempo effettivo;
- giorni, settimane, mesi e anni = unità di calendario;
- necessità e notifica sono separate.

Esempio:

- completamento il 5 agosto alle 22:30;
- frequenza ogni 5 giorni;
- reminder alle 19:00;
- nuova necessità il 10 agosto, reminder alle 19:00.

Le ricorrenze mensili mantengono il giorno desiderato quando possibile, evitando deriva permanente dopo mesi più corti: 31 gennaio → ultimo giorno di febbraio → 31 marzo.

I calcoli usano `Calendar` e componenti di calendario, non secondi fissi.

## 15.6 Fusi orari

### Attività future

Seguono il fuso locale corrente.

> «Alle 20:00» resta alle 20:00 durante un viaggio.

### Cronologia

Ogni evento conserva:

- istante assoluto;
- fuso originale;
- data e ora locali originarie;
- giorno locale usato per attribuire settimana o mese.

Un evento non cambia retroattivamente periodo tornando in un altro fuso.

## 15.7 Obiettivi periodici

Alla fine del periodo:

- risultato reale conservato;
- nuovo periodo a zero;
- nessun carry-over;
- extra oltre il target conservati nello storico, senza credito futuro;
- periodo in pausa escluso dalle analisi ordinarie;
- nessun linguaggio di fallimento.

## 15.8 Ricorrenze fisse non completate

- le occorrenze passate sono conservate;
- Oggi mostra un solo elemento attivo;
- sintesi: «Non registrata nelle ultime 2 occasioni»;
- `Registra` si associa all'occorrenza più recente;
- le precedenti restano «non registrate»;
- il calendario futuro non si sposta;
- l'utente può correggere la data.

## 15.9 Soglie

La 1.0 supporta:

- utilizzo;
- durata;
- quantità;
- tempo;
- `utilizzo/quantità OR tempo`.

La regola scatta alla **prima condizione raggiunta**.

Esempio:

> Cambia la lama dopo 8 rasature oppure 30 giorni, quale condizione arriva prima.

Esclusioni 1.0:

- `AND` complessi;
- condizioni annidate;
- più di due soglie principali;
- formule;
- percentuali tecniche esposte all'utente.

## 15.10 Linked Routines

### Consentito 1.0

- un evento aggiorna più obiettivi o cicli;
- ogni link applica un incremento diverso;
- una soglia genera un follow-up;
- il follow-up modifica o riavvia il ciclo;
- più cicli possono raggiungere soglia dallo stesso evento;
- tutte le conseguenze sono spiegate e annullabili.

### Rinviato 1.X

- catene multilivello;
- «quarto cambio asciugamano → pulizia borsa»;
- ramificazioni più articolate;
- condizioni sulle varianti;
- conseguenze che generano ulteriori conseguenze senza azione esplicita.

### Vietato strutturalmente

- collegamenti circolari;
- aggiornamenti infiniti;
- automazioni senza origine visibile;
- catene non spiegabili o non annullabili.

## 15.11 Routine Cycles

Stato canonico:

1. ciclo attivo;
2. progresso;
3. soglia raggiunta;
4. follow-up creato;
5. follow-up pronto;
6. follow-up completato;
7. nuovo ciclo.

La soglia non azzera il ciclo. Il reminder non azzera il ciclo. Soltanto la conseguenza configurata lo chiude.

## 15.12 Azioni quotidiane

| Azione | Semantica |
|---|---|
| Registra | Crea un evento reale e propaga le conseguenze |
| Fatto | Completa un follow-up e applica la chiusura prevista |
| Rinvia | Cambia quando l'elemento viene riproposto, senza modificare il ciclo |
| Salta questa volta | Salta un'occorrenza calendariale; non è completamento |
| Metti in pausa | Sospende valutazione, notifiche e aggiornamenti automatici |
| Archivia | Rimuove dall'uso attivo mantenendo configurazione e storico |

Per una routine dall'ultima esecuzione non esiste un vero «salta»: la necessità rimane e può essere rinviata. Un follow-up che chiude un ciclo non supporta `Salta questa volta`: può essere rinviato oppure completato/chiuso con una scelta esplicita sul ciclo.

## 15.13 Stati di attenzione

### Non ancora necessario

Sotto controllo; non occupa Oggi.

### In arrivo

Vicino al momento previsto; può apparire in Più tardi o Presto.

### Da fare

Momento o soglia raggiunti.

### Richiede attenzione

Ulteriore tempo trascorso o follow-up aperto oltre il periodo ragionevole.

L'utente può scegliere quando la routine inizia a comparire:

- Un po' prima;
- Quando è il momento — consigliato;
- Solo quando richiede attenzione;
- Personalizza.

## 15.14 Note e metadati dell'evento

Ogni evento conserva automaticamente:

- UUID;
- data e ora effettive;
- fuso e contesto locale;
- routine sorgente;
- tipo;
- valore e unità;
- origine: app, widget, intent, notifica;
- conseguenze applicate;
- soglie raggiunte;
- follow-up generati;
- revisioni, annullamenti e tombstone.

Facoltativi:

- nota breve;
- data/ora corretta;
- quantità o durata diversa.

Allegati rinviati alla 1.X.

---

# 16. Event sourcing, correzione e consistenza

## 16.1 Fonte canonica

Lo stato corrente non è un contatore mutato direttamente. La fonte canonica è il registro degli eventi e delle revisioni.

Esempio:

- Allenamento 1 agosto;
- Allenamento 3 agosto;
- Allenamento 6 agosto;
- Asciugamano sostituito 7 agosto.

Da questi eventi vengono derivate:

- stato;
- progressi;
- soglie;
- follow-up;
- Analisi;
- cronologia;
- notifiche pertinenti.

## 16.2 Proiezioni materializzate

Per prestazioni, Routally mantiene proiezioni ricostruibili:

- stato corrente della routine;
- Oggi;
- follow-up aperti;
- indice di ricerca;
- metriche di Analisi;
- snapshot per widget.

Le proiezioni non sono canoniche e possono essere rigenerate.

## 16.3 Correzione retroattiva

L'utente può:

- annullare subito l'intera operazione;
- modificare data, ora, durata o quantità;
- eliminare un evento;
- escludere una conseguenza specifica;
- ripristinare entro 30 giorni;
- vedere gli elementi che verranno ricalcolati.

Esempio:

> Modificare Corsa da 8 km a 6 km mantiene `+1` sull'obiettivo ma riduce il chilometraggio delle scarpe di 2 km e può rimuovere un follow-up generato erroneamente.

Una modifica rilevante mostra:

> Questa modifica aggiornerà 3 elementi collegati e potrebbe rimuovere un follow-up.

## 16.4 Modifica delle regole

- cambiare soglia, frequenza o obiettivo ricalcola il ciclo corrente sugli eventi esistenti;
- cambiare la routine sorgente di un collegamento vale per eventi futuri;
- gli eventi passati non vengono attribuiti retroattivamente a una nuova sorgente;
- nessun «ricalcola tutta la storia con il nuovo link» nella 1.0.

## 16.5 Consistency Engine

Componente interno responsabile di:

1. verificare proiezioni e indice;
2. ricostruire lo stato dagli eventi;
3. individuare follow-up mancanti o duplicati;
4. riallineare notifiche;
5. aggiornare widget e ricerca;
6. produrre esito diagnostico redatto.

Nella build Dev:

- Verifica integrità;
- Ricostruisci proiezioni;
- Simula evento duplicato;
- Simula conflitto;
- Simula notifica mancante;
- Genera dataset di stress.

Questi strumenti sono esclusi a compilazione da TestFlight e App Store.

## 16.6 Invarianti di dominio

Le seguenti proprietà non possono essere violate:

1. un evento non viene applicato due volte;
2. una soglia non genera due follow-up equivalenti nello stesso ciclo;
3. un follow-up non riavvia il ciclo prima del completamento;
4. rinviare non modifica progresso o soglia;
5. modificare un evento produce un risultato deterministico;
6. eliminare la sorgente non elimina le routine dipendenti;
7. un link circolare è rifiutato;
8. quantità e durata non generano stati impossibili;
9. le proiezioni sono ricostruibili dagli eventi canonici;
10. l'ordine di consegna CloudKit non cambia il risultato finale;
11. retry e riconciliazioni sono idempotenti;
12. un follow-up completato su un dispositivo non viene completato due volte altrove;
13. il fallback temporale e il trigger geografico non generano due follow-up;
14. il downgrade Plus non cancella dati;
15. una routine archiviata non riceve aggiornamenti automatici;
16. una routine in pausa non viene incrementata da link, salvo registrazione manuale esplicita della routine stessa secondo le regole approvate;
17. ogni modifica che altera conseguenze conserva una traccia revisionale;
18. nessuna cache può diventare fonte di verità.

Ogni invariante deve avere test automatici.

---

# 17. Pausa, archiviazione ed eliminazione

## 17.1 Pausa

Sospende:

- Oggi;
- notifiche;
- valutazione degli obiettivi;
- scadenze future;
- aggiornamenti automatici in ingresso.

La registrazione manuale esplicita resta possibile e può propagare verso elementi attivi.

Se è in pausa il ciclo dipendente, gli eventi sorgente non lo incrementano.

## 17.2 Archivio

- rimuove dall'uso quotidiano;
- disattiva notifiche e link automatici;
- conserva configurazione, eventi, cronologia e collegamenti;
- non archivia altri elementi;
- ripristina i link quando possibile.

## 17.3 Eliminazione

Prima dell'eliminazione, mostra l'impatto.

- disattiva link in ingresso e uscita;
- non elimina altre routine;
- non cancella il loro storico;
- sposta in Eliminati di recente;
- offre Annulla immediato.

## 17.4 Eliminati di recente

- permanenza 30 giorni;
- ripristino;
- eliminazione definitiva;
- svuota tutto;
- conto dei giorni restanti.

Percorso:

> Profilo → Dati e iCloud → Eliminati di recente

Dopo 30 giorni, vengono mantenuti soltanto tombstone tecnici necessari alla sincronizzazione.

## 17.5 Eliminazione completa dei dati

Voce:

> **Elimina tutti i dati Routally**

Elimina:

- profilo locale;
- routine;
- eventi;
- note;
- luoghi;
- preferenze;
- dati CloudKit privati.

Non elimina acquisti StoreKit.

Distinta da:

- Ripristina preferenze;
- elimina da questo dispositivo;
- futura eliminazione Account Routally 2.0.

---

# 18. Smart Follow-ups, notifiche e luoghi

## 18.1 Principio

Routally distingue:

- quando nasce la necessità;
- quando il follow-up viene creato;
- quando diventa visibile;
- quando viene notificato;
- quando viene completato;
- quando il ciclo riparte.

## 18.2 Categorie di notifica

### Follow-up pronto

> È il momento di preparare un asciugamano pulito.

Azioni:

- Fatto;
- Più tardi;
- Apri.

### Routine da fare

> È il momento di lavare le lenzuola.

Azioni:

- Registra;
- Rinvia;
- Apri.

### Obiettivo da tenere presente

> Manca un allenamento per l'obiettivo di questa settimana.

Facoltativa, configurabile e non giudicante.

### Riepilogo Routally

> 2 elementi richiedono attenzione questa sera.

Facoltativo, raggruppato, non duplicativo.

### Promemoria contestuale

> Ora che sei a casa, prepara un asciugamano pulito.

## 18.3 Comportamenti

- niente notifica per semplici incrementi;
- niente marketing push;
- niente critical alerts;
- fasce silenziose;
- raggruppamento;
- azioni dirette quando non ambigue;
- completamento da notifica identico a quello in-app;
- Routally resta corretta anche quando Focus o Riepilogo programmato di iOS ritardano o nascondono la notifica: lo stato rimane in Oggi;
- badge disattivato di default;
- badge, se attivo, conta soltanto Richiede attenzione.

## 18.4 Luoghi salvati

L'utente può creare più luoghi:

- Casa;
- casa del partner;
- famiglia;
- ufficio;
- coworking;
- università;
- biblioteca;
- palestra;
- piscina;
- campo sportivo;
- supermercato;
- farmacia;
- lavanderia;
- posta;
- punto ritiro;
- garage;
- stazione;
- aeroporto;
- veterinario;
- luogo personalizzato.

Ogni luogo possiede:

- nome;
- categoria;
- indirizzo o coordinate;
- icona;
- raggio;
- arrivo o uscita;
- fallback.

L'interfaccia mostra scelte contestuali, non una lista infinita.

## 18.5 Trigger 1.0

- all'arrivo;
- all'uscita;
- alla prossima visita;
- luogo personalizzato;
- fallback temporale.

1.X:

- ritardo dopo l'arrivo;
- combinazione luogo/orario;
- qualsiasi luogo di una categoria;
- calendario;
- Bluetooth/CarPlay;
- contesto suggerito.

## 18.6 Affidabilità geografica

- i luoghi salvati possono essere numerosi;
- i trigger attivi vengono limitati e prioritizzati; il technical spike deve rispettare il limite di piattaforma, attualmente tipicamente 20 regioni monitorate per app;
- i trigger one-shot vengono rimossi dopo l'uso;
- nessuna localizzazione continua;
- permesso richiesto nel momento d'uso e non riproposto insistentemente dopo un rifiuto;
- fallback temporale sempre disponibile;
- trigger e fallback condividono un identificativo di deduplicazione;
- la comunicazione non promette un istante esatto.

## 18.7 Dispositivo promemoria principale

Per evitare duplicazioni tra iPhone e iPad:

- un solo dispositivo principale programma notifiche temporali, geografiche, badge e riepiloghi;
- il primo dispositivo autorizzato diventa principale;
- se compare un iPhone, Routally può proporlo;
- nessun passaggio silenzioso;
- opzione facoltativa «Avvisami su tutti i dispositivi»;
- completamenti da qualsiasi dispositivo sincronizzano e cancellano richieste pendenti quando possibile;
- nessun failover automatico che rischi doppie notifiche.

Profilo:

> **Dispositivo per i promemoria**  
> iPhone di Matteo  
> Cambia dispositivo

---

# 19. Integrazioni Apple della 1.0

## 19.1 Widget Oggi

Dimensioni media e grande:

- elementi rilevanti;
- massimo 2–4 righe;
- follow-up;
- «Tutto sotto controllo»;
- Registra, Fatto, apri Oggi.

## 19.2 Widget Routine rapida

Configurabile su una routine:

- evento predefinito con un tocco;
- se serve quantità, variante o conferma, apre il percorso minimo pertinente.

## 19.3 Widget Obiettivo/Ciclo

Mostra un solo elemento in forma discreta:

- Palestra 2/3;
- Asciugamano 3/4.

Niente anello ossessivo permanente come unico linguaggio.

## 19.4 Lock Screen

- prossimo elemento;
- routine rapida;
- numero di follow-up che richiedono attenzione.

## 19.5 App Intents

- `LogRoutineIntent` / Registra routine;
- `CompleteFollowUpIntent` / Completa follow-up;
- `ShowTodayIntent`;
- `ShowRoutineIntent`;
- `CreateQuickRoutineIntent`.

Disponibili, secondo supporto di sistema, in:

- Siri;
- Comandi Rapidi;
- Spotlight;
- widget;
- Centro di Controllo;
- tasto Azione.

## 19.6 Universal Links

Dominio: `routally.com`.

Esempi:

- `/app/today`
- `/app/explore`
- `/kits/gym`
- `/kits/plants`
- `/support/icloud`

Regole:

- app installata → destinazione nativa;
- app assente → pagina web;
- nessun dato sensibile nel link;
- gli UUID locali non autorizzano accesso;
- routine personali apribili soltanto dove già presenti;
- nessun URL scheme pubblico `routally://` nella baseline.

## 19.7 Background tasks

Il background è opportunistico e non essenziale.

Può:

- riconciliare CloudKit;
- aggiornare proiezioni;
- riprogrammare notifiche;
- aggiornare widget e ricerca;
- ripulire cache;
- completare migrazioni non urgenti.

Non può essere necessario per:

- registrare;
- completare;
- consegnare notifiche già programmate;
- evitare perdita dati;
- usare l'app offline.

Ogni task è idempotente, cancellabile e testato con Background App Refresh disattivato.

## 19.8 Integrazioni rinviate

1.X:

- Apple Watch;
- complicazioni;
- Apple Health;
- NFC;
- Calendario;
- allegati;
- integrazioni più profonde con Centro di Controllo e tasto Azione.

---

# 20. Catalogo Routine Kits 1.0

## 20.1 Regole editoriali

Un Kit viene incluso soltanto se:

- dimostra il valore specifico di Routally;
- usa un evento naturale;
- produce conseguenze utili;
- non promuove tracciamento fine a sé stesso;
- non offre consigli medici, tecnici o di sicurezza prescrittivi;
- presenta ogni soglia come valore modificabile;
- resta utilizzabile con creazione rapida.

Ogni Kit possiede una scheda editoriale con:

- obiettivo;
- motivazione;
- eventi sorgente;
- routine e cicli creati;
- valori suggeriti;
- alternative preimpostate;
- domande obbligatorie;
- domande omissibili;
- follow-up;
- momento consigliato;
- reset;
- Free/Plus;
- microcopy IT/EN;
- avvertenze;
- versione;
- test di accettazione.

I Kit sono inclusi e versionati nell'app 1.0, non scaricati da server.

Tutti gli utenti possono esplorare e vedere l'anteprima completa di tutti i 12 Kit. Plus sblocca l'installazione immediata degli otto Kit premium, non le logiche di dominio: un utente Free può ricrearne manualmente una configurazione equivalente entro i limiti di 10 routine e 5 collegamenti.

## 20.2 Kit Free

### 1. Palestra

Dimostra:

- obiettivo settimanale;
- Linked Routines;
- ciclo dell'asciugamano;
- eventuali scarpe/shaker;
- Smart Follow-up al rientro;
- chiusura e riavvio.

Perché è adatto: è il caso più chiaro di registrazione unica con più conseguenze e ciclo completo.

### 2. Lenzuola

Dimostra:

- ricorrenza dall'ultima esecuzione;
- ciclo più lungo del coprimaterasso;
- frequenze collegate diverse.

Perché è adatto: supera il semplice reminder creando un secondo ciclo utile senza richiedere registrazioni aggiuntive.

### 3. Piante

Dimostra:

- prossima annaffiatura dalla data reale;
- fertilizzante ogni X annaffiature;
- reset indipendente.

Perché è adatto: una singola azione alimenta due cicli con ritmi differenti.

### 4. Studio

Dimostra:

- obiettivo settimanale;
- durata facoltativa;
- ripasso programmato;
- verifica dopo X sessioni.

Perché è adatto: dimostra che Routally non è limitata a casa, sport o oggetti.

Regola editoriale: il default non deve generare un nuovo follow-up dopo ogni breve sessione se ciò produce rumore; ripassi e verifiche devono usare una cadenza moderata e configurabile.

## 20.3 Kit Plus

### 5. Corsa

- uscite settimanali;
- chilometri;
- ciclo delle scarpe;
- controllo per distanza oppure tempo;
- nuovo ciclo dopo sostituzione.

Perché è adatto: un evento aggiorna obiettivo e usura con unità differenti.

### 6. Tennis e padel

- partite;
- overgrip;
- palline;
- corde;
- soglie indipendenti.

Perché è adatto: una sola partita alimenta più cicli con frequenze diverse.

### 7. Bicicletta

- uscita o chilometri;
- pulizia;
- lubrificazione catena;
- manutenzione per distanza o tempo.

Perché è adatto: combina obiettivo personale e più manutenzioni senza doppia registrazione.

### 8. Rasatura

- utilizzi della lama;
- soglia tempo oppure rasature;
- follow-up di cambio;
- reset.

Perché è adatto: esempio semplice e immediato di ciclo chiuso, pur vicino ai tracker di usura.

### 9. Acquario

- cambio acqua dalla data reale;
- filtro ogni X cambi;
- follow-up e reset indipendente.

Perché è adatto: attività frequente che alimenta una manutenzione meno frequente.

### 10. Strumento musicale

- pratica settimanale;
- durata;
- ciclo corde/manutenzione;
- follow-up per utilizzo oppure tempo.

Perché è adatto: collega progresso personale e cura dell'attrezzatura.

### 11. Viaggi

Evento principale: «Viaggio concluso».

Follow-up selezionabili:

- ricarica power bank;
- reintegra beauty;
- lava accessori da viaggio quando necessario;
- completa nota spese per trasferta;
- ripristina il kit.

Perché è adatto: non conta gli utilizzi della valigia; trasforma un evento naturale in conseguenze concrete al rientro.

Il Kit deve far scegliere pochi follow-up, non installare una checklist enorme.

### 12. Prato

- prossimo taglio dall'ultimo reale;
- pulizia tagliaerba;
- controllo lama;
- cicli indipendenti.

Perché è adatto: una stessa attività aggiorna ricorrenza e manutenzioni con intervalli diversi.

## 20.4 Casi non promossi

Non diventano Kit iniziali:

- utilizzi della valigia;
- ogni caffè;
- ogni bicchiere d'acqua;
- ogni singolo capo;
- lettiera se richiede logging quotidiano eccessivo;
- riunione → follow-up scontato;
- medicinali o scadenze sanitarie critiche;
- backup fotografico semplice;
- lingua come duplicato di Studio.

Possono essere creati manualmente soltanto quando l'utente ne vede il valore.

## 20.5 Use-case discovery backlog — non scope automatico

Gli esempi emersi durante l'ideazione vengono conservati come repertorio, non come impegno di roadmap. Ogni candidato deve superare i criteri della sezione 2.5.

**Sport e outdoor**

- yoga/pilates e pulizia del tappetino;
- escursionismo e cura di scarponi/zaino;
- sci/snowboard e manutenzione stagionale;
- nuoto e kit piscina.

**Studio, apprendimento e creatività**

- corso online con ripasso e test di modulo;
- lettura con obiettivo e note finali;
- certificazioni con rinnovo futuro;
- fotografia con backup e pulizia attrezzatura;
- stampa 3D, cucito, produzione audio/video.

**Casa, oggetti e manutenzioni**

- robot aspirapolvere con panno e filtro;
- lavatrice/lavastoviglie con cicli di pulizia differenti;
- barbecue, lievito madre, macchina del caffè;
- automobile o camper con uso e manutenzioni, senza sostituire indicazioni del produttore.

**Animali e giardino**

- passeggiate e pulizia accessori;
- toelettatura;
- lettiera soltanto se la registrazione resta leggera;
- manutenzioni del giardino oltre il prato.

**Vita personale e condivisione futura**

- volontariato;
- diario o revisione periodica;
- sport dei figli e lavaggio divise;
- turnazioni domestiche;
- auto condivisa.

**Da trattare con cautela o non promuovere**

- relazioni trasformate in punteggi;
- inventari completi;
- ogni utilizzo di vestiti o oggetti comuni;
- eventi ad altissima frequenza;
- follow-up professionali ovvi;
- qualunque caso medico o di sicurezza critica.

## 20.6 Inventario esteso degli esempi discussi

Questo inventario conserva le idee emerse senza trasformarle automaticamente in feature o Kit.

| Ambito | Esempio | Stato |
|---|---|---|
| Casa | asciugamani del bagno ogni X giorni dall'ultimo cambio | manuale semplice |
| Casa | asciugamano dopo X utilizzi oppure Y giorni | esempio di soglia OR |
| Casa | lenzuola dopo X notti effettive, ignorando notti fuori casa | candidato futuro con variante/contesto |
| Casa | frigorifero ogni X giorni dall'ultima pulizia | manuale semplice |
| Cura personale | testina spazzolino ogni X mesi | manuale semplice, non medicale |
| Cura personale | accappatoio dopo X utilizzi | cautela: logging leggero |
| Cura personale | jeans/maglioni/pigiami dopo X utilizzi | manuale, non promosso per evitare life logging |
| Cura personale | scarpe da lavoro: pulizia/lucidatura dopo X usi | candidato futuro |
| Cura personale | pennelli e spugnette: lavaggio dopo X usi | candidato futuro |
| Cura personale | taglio capelli o trattamento dalla data reale | manuale semplice |
| Sport | yoga/pilates: sessioni + pulizia tappetino | candidato Kit futuro |
| Sport | escursionismo: uscite + scarponi, zaino e sacca idrica | candidato futuro |
| Sport | sci/snowboard: giornate + sciolinatura e abbigliamento | candidato stagionale |
| Sport | nuoto: sessioni + kit piscina/asciugamano | candidato futuro |
| Sport | borsa palestra: pulizia dopo X allenamenti | collegamento opzionale, non default |
| Sport | borraccia/shaker: pulizia profonda dopo X allenamenti | collegamento opzionale |
| Mobilità | automobile: chilometri/tempo → manutenzione | manuale con disclaimer produttore |
| Mobilità | rifornimento → chilometraggio e consumo | non centrale nella 1.0 |
| Mobilità | tragitti in bici → obiettivo e manutenzione | coperto dal Kit Bicicletta |
| Mobilità | camper → ripristino kit e manutenzioni | candidato futuro |
| Studio | lingua: lezioni + ripasso vocaboli + verifica | variante del Kit Studio |
| Studio | corso online: lezione + ripasso + test modulo | candidato futuro |
| Studio | prova presentazione X volte + checklist finale | candidato manuale |
| Studio | lettura: sessioni + libro + note finali/restituzione | candidato futuro |
| Studio | certificazione: studio + rinnovo dopo superamento | candidato futuro |
| Lavoro | riunione → invia riepilogo | escluso come caso rappresentativo, troppo ovvio |
| Lavoro | networking → follow-up | cautela: rischio task manager/CRM |
| Creator | contenuto pubblicato → obiettivo + revisione risultati | candidato futuro |
| Creator | podcast/registrazione → montaggio, pubblicazione e cura attrezzatura | candidato futuro |
| Freelance | sessioni progetto → obiettivo + fattura | cautela: non diventare time tracker/contabilità |
| Finanze | fattura inviata → scadenza e sollecito | fuori dal posizionamento iniziale |
| Viaggi | trasferta conclusa → nota spese, lavanderia, ricarica, beauty | coperto dal Kit Viaggi |
| Viaggi | volo → utilizzi bagaglio/accessori | non promosso: valore limitato |
| Piante | annaffiatura → prossima data + fertilizzante | Kit Piante |
| Animali | lettiera → pulizie ordinarie e cambio completo | cautela per alta frequenza |
| Animali | passeggiata cane → obiettivo + pulizia accessori | candidato futuro |
| Animali | toelettatura dalla data reale | manuale semplice |
| Giardino | taglio prato → pulizia macchina e lama | Kit Prato |
| Casa smart | robot aspirapolvere → panno e filtro con soglie diverse | candidato forte futuro |
| Elettrodomestici | lavatrice/lavastoviglie → pulizia/filtro a cicli diversi | candidato futuro |
| Cucina | macchina caffè → decalcificazione/filtro | valido solo con logging o automazione a basso attrito |
| Cucina | barbecue → pulizia e controllo bombola | candidato futuro |
| Cucina | lievito madre → alimentazione e pulizia barattolo | candidato futuro |
| Hobby | fotografia → backup + pulizia attrezzatura | candidato futuro; backup da solo è debole |
| Hobby | video/musica → backup, montaggio e attrezzatura | candidato futuro |
| Hobby | stampa 3D → filamento, ugello, manutenzione | candidato futuro |
| Hobby | cucito → pratica/progetto + pulizia/lubrificazione | candidato futuro |
| Relazioni | chiamare familiari X volte | manuale, non gamificare |
| Vita sociale | uscite o attività di coppia/mese | cautela: non trasformare relazioni in KPI |
| Benessere | meditazione/diario | possibile obiettivo, ma poco distintivo senza conseguenze |
| Volontariato | turni + abbigliamento/follow-up amministrativi | candidato futuro |
| Famiglia 2.X | sport figli → allenamento + lavaggio divisa | candidato shared |
| Famiglia 2.X | turnazione attività domestiche | candidato Centro Attività/condivisione |
| Famiglia 2.X | lettura bambini + progresso libro/restituzione | candidato shared |
| Famiglia 2.X | automobile condivisa | candidato shared |

Esempi strutturali discussi ma non ammessi nella 1.0:

- soglie `AND` o condizioni annidate;
- cicli dentro altri cicli senza azione esplicita;
- stati completi degli oggetti `pulito / in uso / da lavare / disponibile`;
- inventario domestico e consumo delle scorte;
- rilevamento automatico esteso da servizi terzi;
- logging di ogni caffè, bicchiere, pasto o micro-evento.

---

# 21. Dati, persistenza e iCloud

## 21.1 Principio local-first

- dati scritti subito sul dispositivo;
- tutte le azioni quotidiane disponibili offline;
- sincronizzazione iCloud automatica;
- nessun account obbligatorio;
- nessun backend proprietario nella 1.0;
- se iCloud non è configurato, è temporaneamente indisponibile o ha quota insufficiente, l'app continua integralmente in locale e mostra uno stato comprensibile;
- nessun pulsante ordinario «Sincronizza ora»;
- `Riprova` soltanto in caso di problema.

## 21.2 Persistenza

Default:

- SwiftData;
- `ModelConfiguration` con App Group e CloudKit;
- dopo DG-DEVELOPER-IDENTITY, preferibilmente un unico container iCloud Routally definitivo con ambienti CloudKit Development e Production separati, associato agli App ID necessari; prima del gate gli spike usano container e identificativi di sviluppo provvisori e sacrificabili;
- schema versionato dalla prima release;
- `SchemaMigrationPlan` esplicito;
- adapter separato dal dominio.

Architettura:

```text
SwiftUI
  ↓
Feature state / use case
  ↓
Domain engine
  ↓
Repository protocols
  ↓
SwiftData + CloudKit adapter
```

Futuro:

```text
Repository
  ├── SwiftData/iCloud
  └── Routally Backend
```

## 21.3 Indipendenza dal framework

- i tipi di dominio non sono direttamente modelli SwiftData esposti alla UI;
- gli UUID sono indipendenti da `PersistentIdentifier`;
- CloudKit non viene chiamato dalla feature;
- l'adapter è sostituibile;
- import/export del futuro account non dipende da dettagli iCloud.

## 21.4 Schema V1

Il primo schema è formalmente versionato. I modelli persistenti indicativi comprendono:

- profilo locale;
- routine;
- componenti di regola;
- eventi;
- revisioni;
- link;
- follow-up;
- occorrenze;
- luoghi;
- Aree;
- Kit origin;
- proiezioni;
- tombstone;
- device preference;
- entitlement cache non canonica.

La struttura finale viene fissata dopo gli spike tecnici e documentata in ADR.

Prima della beta esterna, lo schema CloudKit viene promosso in Production. Da quel momento le evoluzioni devono essere additive, backward-compatible e accompagnate da migrazioni; nessun reset generale o cancellazione distruttiva dello schema Production è ammesso.

## 21.5 Stato iCloud visibile

- Aggiornato;
- Sincronizzazione in corso;
- Offline;
- Richiede attenzione.

Lo stato appare nel Profilo e soltanto quando utile altrove.

La comunicazione può descrivere i dati come privati e sincronizzati tramite iCloud, ma non deve promettere crittografia end-to-end garantita in ogni configurazione Apple senza una verifica specifica aggiornata.

## 21.6 Conflitti

- nuovi eventi: merge e deduplica UUID;
- modifica evento: nuova revisione;
- eliminazione: tombstone;
- configurazione routine: revisione più recente, precedente recuperabile;
- stato corrente: sempre ricalcolato;
- conflitto non risolvibile: entrambe le versioni conservate, scelta guidata;
- errore: app continua localmente.

## 21.7 Recupero

Non esiste un backup manuale `.routally`.

I livelli di recupero sono:

1. Annulla immediato;
2. revisioni;
3. Eliminati di recente 30 giorni;
4. versioni precedenti di configurazione;
5. sincronizzazione iCloud.

iCloud è sincronizzazione e conservazione seamless, non viene descritto come snapshot storico separato.

## 21.8 Esportazione CSV

Voce:

> **Esporta i tuoi dati**

CSV leggibile con:

- data e ora;
- routine;
- evento;
- quantità/durata;
- unità;
- nota;
- conseguenze;
- follow-up.

Il CSV:

- non è un backup;
- non è reimportabile;
- non include coordinate di default;
- serve a trasparenza e portabilità.

## 21.9 Continuità TestFlight → App Store

- Routally Dev resta isolata;
- dalla prima beta esterna, TestFlight usa CloudKit Production e i dati dei tester vengono trattati come reali;
- non è previsto un reset generale al lancio;
- routine, cronologia e configurazioni devono sopravvivere all'aggiornamento dalla release candidate TestFlight alla build App Store;
- il percorso RC → App Store con dati e sincronizzazione intatti è un release gate obbligatorio.

## 21.10 Migrazione futura 2.0

1. creazione account;
2. rilevamento dati locali/iCloud;
3. anteprima;
4. copia nel backend;
5. verifica integrità;
6. attivazione sync multipiattaforma;
7. possibilità di mantenere modalità locale se prevista.

---

# 22. Privacy e sicurezza

## 22.1 Privacy baseline

La 1.0 pubblica non include:

- pubblicità;
- vendita dati;
- tracciamento cross-app;
- ATT;
- IDFA;
- SDK analytics;
- Sentry;
- Firebase;
- Crashlytics;
- Mixpanel/Amplitude;
- telemetria comportamentale Routally;
- server di push marketing.

Strumenti consentiti:

- App Store Connect Analytics;
- TestFlight;
- Xcode Organizer;
- MetricKit;
- OSLog con privacy redaction;
- feedback volontario.

`AnalyticsClient` esiste con `NullAnalyticsClient`, per evitare accoppiamenti futuri.

## 22.2 Dati sensibili

- routine, note, luoghi e profilo restano sul dispositivo/iCloud privato;
- nessuna cronologia spostamenti;
- nessun invio continuo posizione;
- nome/avatar facoltativi;
- log senza nomi routine, note o coordinate;
- file temporanei redatti e rimossi.

## 22.3 App lock

Nessun Face ID interno. Routally usa:

- blocco/nascondi app nativo iOS;
- `privacySensitive` per widget e contenuti;
- autenticazione di sistema per azioni da dispositivo bloccato;
- guida nel Profilo.

Il blocco/nascondi app è una scelta per singolo dispositivo e non viene sincronizzata da Routally. Quando attivo, si rispettano anche le protezioni di sistema per anteprime, ricerca e suggerimenti. Routally non aggiunge un secondo selettore proprietario per le anteprime delle notifiche.

## 22.4 Privacy manifest e App Privacy

- `PrivacyInfo.xcprivacy` dal primo rilascio;
- inventario Required Reason APIs;
- audit della build finale;
- App Privacy aggiornata;
- obiettivo «Dati non raccolti» soltanto se verificato correttamente;
- Privacy Policy IT/EN.

## 22.5 Repository pubblico

Il repository è pubblico ma proprietario.

- nessuna licenza open source;
- `COPYRIGHT.md` e All rights reserved;
- README chiarisce che non accetta contributi, issue, feature request o supporto;
- Issues, Discussions, Wiki e community features disattivate/non usate;
- asset visuali non approvati esclusi dal repository;
- nessun secret o dato reale.

## 22.6 GitHub security

- secret scanning;
- push protection;
- CodeQL per Swift;
- Dependabot per Actions e package futuri;
- branch protection;
- revisione delle modifiche a workflow, entitlement, privacy manifest e firma;
- `SECURITY.md` con email privata;
- nessun bug bounty formale iniziale.

## 22.7 Threat model

Deve coprire almeno:

- file o input corrotti;
- sincronizzazione ostile/incoerente;
- duplicazione eventi;
- perdita o riapparizione di dati eliminati;
- escalation Free/Plus;
- esposizione di luoghi e note;
- Universal Link manipolati;
- widget su lock screen;
- secret nel repository;
- abuso di App Intents;
- denial of service locale con dataset enorme;
- supply chain GitHub Actions.

## 22.8 Principio del minimo privilegio

Capability 1.0:

- iCloud/CloudKit;
- App Groups;
- In-App Purchase;
- Associated Domains;
- Background Modes soltanto se implementati;
- WidgetKit/App Intents.

Permessi nel momento d'uso:

- notifiche quando viene configurato il primo reminder;
- posizione quando viene scelto il primo promemoria basato su luogo;
- foto limitate solo per avatar, preferendo il picker di sistema.

Non richiesti:

- Calendario;
- Health;
- Contatti;
- microfono;
- fotocamera generale;
- Bluetooth;
- tracking.

Se negati, l'app continua, offre fallback, non ripete la richiesta in modo insistente e apre le Impostazioni di iOS soltanto quando l'utente tenta nuovamente la funzione.

La 1.0 non usa un server per inviare push. Qualunque meccanismo remoto richiesto internamente da CloudKit non deve essere trasformato in un canale promozionale o di tracciamento.

---

# 23. Accessibilità

## 23.1 Release gate

L'accessibilità è requisito bloccante, non rifinitura.

Obiettivi da verificare per le Accessibility Nutrition Labels:

- VoiceOver;
- Voice Control;
- Larger Text / Dynamic Type;
- Dark Interface;
- Differentiate Without Color Alone;
- Sufficient Contrast;
- Reduced Motion.

Le dichiarazioni vengono pubblicate soltanto dopo audit reale per iPhone e iPad.

## 23.2 Flussi accessibili obbligatori

- onboarding;
- creazione rapida;
- configurazione completa;
- installazione Kit;
- registrazione;
- comprensione delle conseguenze;
- completamento/rinvio follow-up;
- correzione;
- ricerca;
- modifica/pausa/archivio;
- acquisto/ripristino;
- esportazione dati;
- eliminazione dati.

## 23.3 Requisiti

- nessuna funzione solo swipe o long press;
- etichette VoiceOver specifiche;
- progressi e grafici con descrizione accessibile;
- layout fino alle dimensioni di testo di accessibilità;
- colori accompagnati da testo/simbolo;
- Reduce Motion;
- Increase Contrast;
- Reduce Transparency;
- target touch adeguati;
- focus e ordine lettura controllati;
- feedback aptico non unico segnale;
- test con tastiera/puntatore su iPad.

## 23.4 QA

- Accessibility Inspector;
- VoiceOver Simulator e device;
- Voice Control;
- tutte le categorie Dynamic Type;
- light/dark/high contrast;
- Reduce Motion/Transparency;
- matrice per dispositivo e flusso.

---

# 24. Localizzazione

## 24.1 Lingue 1.0

- inglese sorgente tecnica;
- inglese completo;
- italiano completo e curato manualmente;
- pari dignità di UI, sito e App Store.

## 24.2 Implementazione

- Xcode String Catalogs;
- riferimenti tipizzati;
- commenti contestuali;
- plurali;
- formattazione locale di date, ore, distanze e quantità;
- unità indipendenti dalla lingua;
- pseudolocalizzazione;
- test stringhe lunghe;
- preview IT/EN.

## 24.3 Lingua dell'app

Nessun selettore proprietario. La voce Lingua nel Profilo apre le impostazioni native per-app di iOS.

## 24.4 Lingue future

1.X, in base a domanda e qualità disponibile:

- spagnolo;
- tedesco;
- francese.

---

# 25. Architettura tecnica

## 25.1 Stile architetturale

**Monolite modulare Apple-native.**

Non un unico target disordinato, ma nemmeno decine di package prematuri.

```text
RoutallyApp
│
├── RoutallyDomain
│   ├── Routine
│   ├── Events
│   ├── Rules
│   ├── Cycles
│   ├── Links
│   └── FollowUps
│
├── RoutallyData
│   ├── SwiftData
│   ├── CloudKit
│   ├── Repositories
│   ├── Migration
│   └── Projections
│
├── RoutallyFeatures
│   ├── Today
│   ├── Routines
│   ├── Explore
│   ├── Insights
│   ├── Search
│   ├── Creation
│   └── Profile
│
├── RoutallySystem
│   ├── Notifications
│   ├── Locations
│   ├── AppIntents
│   ├── Widgets
│   ├── StoreKit
│   └── Diagnostics
│
└── RoutallyDesign
    ├── BrandTokens
    ├── Components
    ├── CycleVisualizations
    └── Accessibility
```

`RoutallyDomain` e `RoutallyData` devono avere confini forti. Le feature possono iniziare nello stesso package applicativo con moduli interni chiari.

## 25.2 Swift 6 e concorrenza

- strict concurrency dal primo commit;
- `async/await`;
- actor per persistenza, ricalcolo, notifiche e sync;
- tipi `Sendable` quando appropriato;
- niente callback legacy senza necessità;
- nessun singleton globale come scorciatoia;
- warning di concorrenza trattati come errori progettuali.

## 25.3 SwiftUI e stato

- `@State` per stato locale;
- `@Binding` per mutazione di valore posseduto dal parent;
- `@Observable` per modelli di feature;
- initializer injection per dipendenze locali;
- `@Environment` per servizi app-wide ben definiti;
- `NavigationStack` per ogni tab;
- routing tipizzato;
- `.sheet(item:)` per presentazioni basate su modello;
- view piccole e composte;
- niente `AnyView` come scorciatoia;
- niente logica business in `body`.

## 25.4 Repository protocols

Interfacce minime indicative:

```swift
protocol RoutineRepository: Sendable { ... }
protocol EventRepository: Sendable { ... }
protocol ProjectionRepository: Sendable { ... }
protocol ReminderScheduler: Sendable { ... }
protocol LocationReminderService: Sendable { ... }
protocol EntitlementProvider: Sendable { ... }
protocol AnalyticsClient: Sendable { ... }
protocol Clock: Sendable { ... }
protocol IdentifierGenerator: Sendable { ... }
```

`Clock`, calendario e ID devono essere iniettabili per test deterministici.

## 25.5 Design system

Principio: **system-native, brand-distinctive**.

Apple components first.

Routally customizza soltanto:

- token di brand;
- visualizzazione Routine Cycle;
- riga collegamenti;
- riepilogo conseguenze;
- anteprima Kit;
- stato «Tutto sotto controllo»;
- indicatori discreti.

Non ricrea pulsanti, picker, tab, navigation bar, sheet o search se esiste un equivalente nativo.

## 25.6 Fallback tecnico SwiftData

Default confermato: SwiftData + CloudKit.

**Technical Gate TG-DATA:** uno spike deve verificare event store, migrazioni, App Group, widget, sync offline e dataset esteso.

Se il gate fallisce per limiti dimostrati, il dominio e i repository restano invariati e viene valutato un adapter Apple-native alternativo, preferibilmente Core Data + `NSPersistentCloudKitContainer`. Il fallback non modifica l'esperienza né autorizza dipendenze esterne.

---

# 26. Toolchain e dipendenze

## 26.1 Strumenti ufficiali

| Area | Scelta |
|---|---|
| Repository | GitHub pubblico, proprietario |
| Design | SwiftUI, Xcode Previews e Apple Design Resources |
| IDE | Xcode |
| Linguaggio | Swift 6 |
| Agent coding | Codex o Claude Code |
| Simulator/build agent | XcodeBuildMCP |
| Formatter | `swift-format` della toolchain |
| Package manager | Swift Package Manager, package locali |
| CI/CD Apple | Xcode Cloud |
| CI complementare | GitHub Actions leggere |
| Beta | TestFlight |
| Distribuzione | App Store Connect |
| Test dominio | Swift Testing |
| Test UI/sistema | XCTest/XCUITest |
| Performance | Instruments, MetricKit |
| Crash | TestFlight, Xcode Organizer |
| Prototipo | Xcode Previews + Simulator |
| Icona | SVG + Icon Composer |

## 26.2 Dipendenze runtime

Baseline 1.0: **zero dipendenze runtime esterne**.

Non usare inizialmente:

- Firebase;
- Supabase;
- Realm;
- TCA/Redux;
- DI framework;
- navigation framework;
- Lottie;
- chart library;
- RevenueCat;
- Sentry/Crashlytics;
- date library;
- keychain wrapper;
- networking library;
- mocking framework.

Strumenti di sviluppo non inclusi nella baseline:

- CocoaPods e Carthage;
- Fastlane;
- Tuist e XcodeGen;
- Appium e BrowserStack/device farm;
- formatter esterni alternativi;
- generatori di progetto.

Possono essere rivalutati soltanto quando un problema misurabile non è coperto dalla toolchain Apple.

Ogni futura dipendenza richiede:

- problema concreto;
- alternativa Apple valutata;
- licenza;
- manutenzione;
- rischio supply chain;
- costo;
- piano di rimozione;
- approvazione.

## 26.3 SwiftLint

Non incluso inizialmente. Si usano:

- compilatore Swift 6;
- strict concurrency;
- `swift format lint --strict`;
- test;
- Xcode Analyze;
- code review.

Può essere aggiunto soltanto se emergono regole ad alto valore non coperte.

## 26.4 XcodeBuildMCP

Usato per:

- build;
- test;
- avvio Simulator;
- UI inspection;
- screenshot;
- tap/type/gesture;
- log e console;
- verifica autonoma dell'agente.

Telemetria dello strumento disattivata quando configurabile.

## 26.5 Design SwiftUI-first

Fonti operative:

- Master Plan e specifiche `docs/DESIGN/` per IA, flussi e criteri di accettazione;
- SwiftUI come rappresentazione eseguibile dell'interfaccia;
- `#Preview` accanto alle view per stati, dati fittizi e varianti;
- Asset Catalog per colori e asset semantici;
- componenti Apple nativi e Apple Design Resources;
- Simulator e dispositivi reali per comportamento, accessibilità e layout adattivo;
- screenshot della release candidate reale per i materiali App Store.

Le preview coprono, dove pertinente:

- iPhone e iPad;
- portrait, landscape e finestre ridimensionabili;
- Light e Dark Mode;
- Dynamic Type, contrasto e riduzione della trasparenza;
- stati vuoti, caricamento, errore e dati rappresentativi.

Metodo per vertical slice:

1. flusso e criteri di accettazione approvati nelle specifiche;
2. implementazione SwiftUI con fixture locali;
3. verifica interattiva in Xcode Previews;
4. verifica su Simulator e dispositivo;
5. riallineamento delle specifiche quando il comportamento nativo richiede un adattamento approvato;
6. approvazione prima della slice successiva.

Prototipo canonico minimo:

- crea Palestra;
- collega Asciugamano;
- registra quarto allenamento;
- follow-up a casa;
- completa;
- ciclo riavviato.

Questo è un vertical slice, non l'unico scenario di validazione.

## 26.6 Policy versioni

Documentare e bloccare per milestone:

- Xcode;
- Swift;
- SDK;
- target OS;
- swift-format;
- XcodeBuildMCP;
- fixture e matrice delle Xcode Previews;
- GitHub Actions;
- schema SwiftData;
- formato Kit;
- formato eventi;
- StoreKit config.

Regole:

- release solo con toolchain stabile;
- beta Apple soltanto in spike/branch dedicati;
- niente upgrade toolchain durante milestone critica senza necessità;
- upgrade seguito da build e regressione completa;
- Actions bloccate a versioni/commit affidabili;
- feature flag obsolete rimosse.

## 26.7 Ripartizione CI

**Xcode Cloud** è la fonte primaria per build Apple, test, archivi e TestFlight.

**GitHub Actions** resta complementare e limitata a:

- `swift-format`;
- documentazione e file di configurazione;
- CodeQL e controlli di sicurezza;
- verifiche che non richiedono firma, Simulator o infrastruttura Apple completa.

Non duplicare inutilmente la pipeline Xcode Cloud.

---

# 27. Codex e Claude Code

## 27.1 Ruolo

Codex e Claude Code sono **agenti alternativi e pienamente intercambiabili**.

Entrambi possono:

- implementare;
- progettare architettura;
- refactor;
- testare;
- fare debugging;
- lavorare con Simulator;
- documentare;
- preparare branch e PR;
- lavorare su StoreKit, CloudKit, notifiche, widget e migrazioni.

Non hanno ruoli fissi complementari.

## 27.2 Esclusività

- un solo agente lavora su un'attività alla volta;
- non lavorano mai assieme sullo stesso task;
- nessuno dei due agenti ha il ruolo di revisore dell'altro;
- il cambio richiede handoff documentato.

## 27.3 La review non è un ruolo di agente

Il gate `codex-review` della sezione 28.3.1 è un controllo di integrazione continua della
repository, non un intervento dell'agente Codex sul task dell'agente Claude Code. Vale allo
stesso modo per ogni pull request, indipendentemente da quale interfaccia l'abbia prodotta,
esattamente come CodeQL o `swift-format`.

Di conseguenza:

- il gate non viola l'esclusività della sezione 27.2, perché non assegna un task a un secondo agente;
- l'agente che ha aperto la pull request resta l'unico a lavorarci e a rispondere ai finding;
- un finding non trasferisce il task all'altra interfaccia né richiede un handoff;
- la sostituzione futura del gate con un altro strumento di review non cambia le regole di questa sezione.

Registrato in `docs/ADR/0005-review-gate-ci.md`.

## 27.4 Handoff

Prima del passaggio:

- working tree pulito;
- modifiche committate;
- obiettivo e criteri aggiornati;
- test eseguiti e risultati;
- problemi aperti;
- decisioni prese;
- prossimo passo.

Il nuovo agente legge:

- Master Plan;
- specifica;
- ADR;
- branch;
- handoff.

## 27.5 Istruzioni canoniche

- `docs/ENGINEERING/agent-workflow.md` — fonte comune;
- `AGENTS.md` — ingresso Codex;
- `CLAUDE.md` — ingresso Claude Code.

Entrambi richiamano le stesse regole.

---

# 28. Repository e workflow Git

## 28.1 Visibilità

- pubblico dal primo commit;
- codice proprietario;
- nessuna licenza open source;
- uso personale;
- niente Issues, Discussions, Wiki o community support;
- contributi esterni non richiesti.

## 28.2 Workflow

Trunk-based con branch brevi:

- `main` protetto, sempre compilabile e potenzialmente distribuibile;
- un branch breve per feature/fix, idealmente chiuso in una singola sessione coerente;
- PR obbligatoria;
- squash merge;
- branch eliminato dopo merge;
- nessun commit diretto salvo emergenza documentata;
- unica eccezione di bootstrap: il commit radice **Repository & Governance** può essere
  creato direttamente su `main`, perché una pull request richiede una base già esistente;
  dal commit successivo si applica il workflow ordinario;
- Conventional Commits non obbligatori: il titolo della PR diventa il commit squash leggibile.

Esempi:

```text
feature/today-calm-view
feature/usage-cycle-engine
fix/daylight-saving-recalculation
test/location-follow-up
docs/data-model-v1
```

## 28.3 Pull request

Ogni PR include:

- obiettivo;
- comportamento atteso;
- schermate/flussi;
- test;
- screenshot/video UI;
- rischi e migrazioni;
- accessibilità/localizzazione;
- documenti aggiornati.

### 28.3.1 Gate review Codex

Ogni PR richiede lo status `codex-review` sull'HEAD corrente. Il gate osserva soltanto
la review Codex nativa: un finding P0/P1 dell'HEAD fallisce lo status; P2/P3 restano
advisory dopo la conclusione della review e un breve assestamento dei segnali. Una
reaction positiva della review iniziale o un verdetto pulito con `Reviewed commit`
coincidente lo completano. Segnali relativi a commit precedenti non vengono riutilizzati.

Il workflow usa `pull_request_target`, esegue esclusivamente il codice già presente su
`main`, ha Issues in sola lettura e non pubblica commenti o richieste `@codex review`.
Lo status resta pending mentre la review è in corso e diventa failure su finding, limite
o errore, mentre il job Actions termina senza mostrare un falso errore del workflow.

All'apertura o al passaggio da draft a ready si usa la review nativa senza commenti
di richiesta. Dopo un nuovo commit o per un retry l'agente pubblica una sola riga
`@codex review`; `workflow_dispatch` resta disponibile per bootstrap e retry manuali.
La PR che introduce il gate è l'unica eccezione tecnica: viene revisionata da Codex
prima del merge e lo status diventa required subito dopo, quando il workflow è presente
su `main`.

Il gate è un controllo di integrazione continua della repository e non assegna il lavoro a
un secondo agente: si applica la sezione 27.3.

## 28.4 Primo commit

```text
README.md
COPYRIGHT.md
SECURITY.md
AGENTS.md
CLAUDE.md
CHANGELOG.md
.swift-format
.gitignore
.gitattributes
.github/
docs/
```

Il commit radice è **Repository & Governance** e costituisce l'eccezione di bootstrap
definita nella sezione 28.2; la prima modifica successiva passa da branch e PR. Non crea
ancora il progetto Xcode. `Routally/` e i target applicativi arrivano nella successiva epic
Xcode & SwiftUI Foundation, dopo la baseline documentale e l'approvazione della direzione UI Apple-native.

Non includere:

- `CONTRIBUTING.md`;
- `CODE_OF_CONDUCT.md`;
- issue template;
- community roadmap.

## 28.5 README

- nome e tagline;
- concept;
- stato pre-1.0;
- piattaforme;
- roadmap sintetica senza date;
- build instructions;
- copyright;
- nessuna richiesta di contributi/supporto.

---

# 29. Documentazione

## 29.1 Struttura

```text
docs/
├── MASTER_PLAN.md
├── PRODUCT/
│   ├── vision.md
│   ├── terminology.md
│   ├── market-research.md
│   ├── competitive-benchmark.md
│   ├── use-case-inventory.md
│   ├── feature-matrix.md
│   ├── routine-kits.md
│   ├── business-model.md
│   └── roadmap.md
├── DESIGN/
│   ├── navigation.md
│   ├── creation-flow.md
│   ├── accessibility.md
│   └── ui-foundation.md
├── ENGINEERING/
│   ├── architecture.md
│   ├── domain-model.md
│   ├── event-engine.md
│   ├── persistence-sync.md
│   ├── notifications.md
│   ├── consistency-engine.md
│   ├── testing-strategy.md
│   └── agent-workflow.md
├── RELEASE/
│   ├── app-store.md
│   ├── privacy-checklist.md
│   ├── testflight.md
│   ├── review-evidence.md
│   └── release-checklist.md
├── RUNBOOKS/
│   ├── cloudkit-sync.md
│   ├── projection-repair.md
│   ├── notifications.md
│   ├── storekit.md
│   ├── app-review.md
│   └── security-incident.md
└── ADR/
    ├── 0001-ios-26-minimum.md
    ├── 0002-event-sourced-domain.md
    ├── 0003-swiftdata-cloudkit.md
    ├── 0004-swiftui-first-ui-design.md
    └── ...
```

## 29.2 Regole

- Master Plan = visione e decisioni;
- specifiche = implementazione operativa;
- ADR = scelte tecniche difficili da invertire;
- ogni PR aggiorna i documenti pertinenti;
- niente duplicazioni inutili del codice;
- dati fittizi;
- roadmap pubblica distinta dal backlog personale;
- decisioni scartate conservate quando spiegano la scelta;
- Master Plan e documenti di prodotto in italiano;
- nomi di tipi Swift, API, branch, milestone e identificativi tecnici in inglese;
- `AGENTS.md`, `CLAUDE.md` e istruzioni operative per agenti possono essere in inglese purché fedeli alla fonte italiana;
- nessuna stima di calendario o promessa in settimane prima della UI Foundation eseguibile e dei technical spike; usare dipendenze, complessità relativa e gate.

## 29.3 Decision Register

Tabella minima:

| ID | Decisione | Stato | Versione | Motivazione | Impatto | Data |
|---|---|---|---|---|---|---|

## 29.4 Traceability

Ogni requisito deve poter essere collegato a:

> requisito → UI → dominio → persistenza → integrazione → test → accettazione → milestone

La matrice completa vive in `docs/PRODUCT/feature-matrix.md` e viene generata dalla baseline contenuta in questo piano.

---

# 30. Ambienti e configurazioni

## 30.1 Prodotti installabili

Non esistono tre app pubbliche.

### Routally Dev

- bundle ID distinto;
- installabile localmente;
- dati sintetici;
- prima del gate identità, CloudKit Development su un container provvisorio e sacrificabile del team corrente; dopo il gate può usare l'ambiente Development del container definitivo se la configurazione Apple lo consente senza rischi di trasferimento;
- StoreKit locale;
- strumenti diagnostici;
- icona DEV;
- mai pubblicata.

### Routally

Unica identità definitiva:

- stesso bundle ID per TestFlight e App Store;
- un record App Store Connect;
- CloudKit Production dello stesso container;
- dati TestFlight preservati nella versione App Store;
- StoreKit Sandbox su TestFlight e produzione su App Store.

Gli asset Apple definitivi — Bundle ID, App Groups, container CloudKit Production, prodotti StoreKit e record App Store — vengono creati soltanto dopo DG-DEVELOPER-IDENTITY. La Foundation può usare identificativi provvisori esplicitamente non trasferibili e non destinati alla produzione.

## 30.2 Configurazioni

```text
Configuration/
├── Base.xcconfig
├── Development.xcconfig
├── ReleaseCandidate.xcconfig
└── Release.xcconfig
```

Schemes:

- Routally Dev;
- Routally;
- Routally Tests.

## 30.3 Xcode Cloud

Workflow:

- PR Validation;
- Nightly;
- TestFlight Candidate;
- App Store Release manuale.

## 30.4 Feature flags

Locali e tipizzate:

- funzioni Dev;
- funzioni TestFlight complete ma in validazione;
- alternative UX;
- esclusione prima della release.

Nessun remote config.

In App Store:

- feature 1.0 attiva o rimossa;
- niente funzione incompleta nascosta;
- flag obsolete eliminate.

## 30.5 Fixture e demo

Scenari canonici:

- EmptyProfile;
- NewUser;
- TypicalUser;
- HighlyOrganizedUser;
- ThresholdReached;
- OfflineWithPendingChanges;
- CloudConflict;
- FreeLimitReached;
- PlusUser;
- LargeHistory.

Launch arguments Dev:

```text
-launchMode demo
-demoScenario connectedGymCycle
```

Usati da:

- preview;
- test;
- screenshot;
- performance;
- preview e verifiche visuali.

Mai presenti nell'app pubblica.

---

# 31. Modello di business

## 31.1 Routally Free

- nessuna scadenza;
- nessuna pubblicità;
- nessuna vendita dati;
- fino a **10 routine attive**;
- fino a **5 collegamenti attivi**;
- tutti i modelli fondamentali: tempo, obiettivi, utilizzi, durata e quantità;
- Linked Routines e ciclo completo disponibili;
- un luogo salvato, normalmente Casa;
- installazione dei 4 Kit introduttivi;
- anteprima di tutti i 12 Kit;
- possibilità di ricreare manualmente logiche equivalenti entro i limiti Free;
- Oggi;
- ricerca globale;
- notifiche e Smart Follow-ups;
- una sola istanza di widget attiva alla volta, di qualunque tipo e dimensione, Lock Screen inclusa;
- Analisi limitata al periodo di 4 settimane;
- iCloud;
- esportazione CSV;
- light/dark, accessibilità e affidabilità complete.

### 31.1.1 Perché 10 routine e 5 collegamenti

I limiti Free devono essere coerenti con la promessa che li accompagna: se Free installa i
4 Kit introduttivi, deve poterlo fare davvero.

Nella configurazione predefinita i Kit introduttivi consumano:

| Kit Free | Routine | Collegamenti |
|---|---|---|
| Palestra | obiettivo Palestra, Asciugamano palestra | 1 |
| Lenzuola | Lenzuola, Coprimaterasso | 1 |
| Piante | Annaffiatura, Fertilizzante | 1 |
| Studio | Studio, Ripasso | 1 |
| **Totale** | **8** | **4** |

Con i precedenti 5 e 2 un utente Free si bloccava al secondo Kit e la vetrina destinata a
dimostrare il valore distintivo si chiudeva prima di dimostrarlo. I valori 10 e 5 lasciano
margine per almeno una routine personale oltre ai Kit, che è il momento in cui l'utente
smette di provare il prodotto e inizia a usarlo.

I collegamenti opzionali di un Kit — scarpe, shaker, borsa palestra — restano opzionali e
non sono inclusi nel conteggio predefinito. La scheda Kit mostra sempre il costo effettivo
in routine e collegamenti prima dell'installazione, secondo la sezione 12.3.

Questi valori restano soggetti alla revisione a 90 giorni prevista nella sezione 43 per il
rischio «Free troppo generoso»: una loro riduzione futura non può però tornare sotto la
soglia che rende installabili i 4 Kit introduttivi.

### 31.1.2 Comportamento ai limiti

- **Analisi:** i periodi oltre le 4 settimane restano visibili nel selettore e mostrano un paywall contestuale; nessun dato già registrato viene nascosto o eliminato.
- **Widget:** il limite è sull'istanza configurata, non sul tipo. L'utente Free sceglie liberamente quale widget attivare e può cambiarlo quando vuole.
- **Luoghi:** oltre il primo luogo salvato il paywall è contestuale alla creazione del secondo.

## 31.2 Routally Plus

- routine illimitate;
- collegamenti illimitati;
- luoghi illimitati;
- 12 Kit completi;
- widget e Lock Screen senza limiti previsti;
- cronologia e Analisi complete;
- insight avanzati;
- Aree e filtri estesi;
- personalizzazione cromatica;
- funzioni Plus 1.X: Watch, Health, varianti, contesto avanzato e Kit.

## 31.3 Prezzi 1.0–1.X

Razionale:

- Routally acquista valore nel corso di settimane e mesi, non come servizio occasionale;
- il mensile renderebbe il confronto economico sproporzionato per una utility personale;
- l'annuale sostiene lo sviluppo;
- il Lifetime è coerente con un prodotto local-first e con l'avversione agli abbonamenti, ma ha un perimetro esplicito.

Prezzi:

- **Annual:** 14,99 € / anno;
- prova gratuita: 14 giorni;
- **Lifetime:** 39,99 € una tantum, stabilmente disponibile per tutto il ciclo 1.0–1.X;
- nessun mensile;
- Family Sharing per Annual e Lifetime; condivide l'entitlement, non routine o dati tra familiari;
- prezzi invariati per tutto il ciclo 1.X;
- rivalutazione soltanto dalla 2.0.

## 31.4 Perimetro Lifetime

Comprende permanentemente:

- funzioni Plus Apple-locali;
- iPhone/iPad;
- iCloud;
- aggiornamenti 1.X;
- Watch, Health e integrazioni Apple previste nella 1.X;
- manutenzione delle funzioni acquistate.

Non comprende automaticamente:

- account Routally;
- backend;
- web/Android sync;
- spazi condivisi cloud;
- servizi AI/cloud con costi ricorrenti.

Questi saranno piani distinti dalla 2.0, senza ridurre i diritti esistenti.

## 31.5 Paywall

- nessun paywall obbligatorio all'avvio;
- l'utente sperimenta prima il valore;
- Plus presentato nel Profilo e in Esplora;
- paywall contestuale quando si supera un limite o si seleziona una feature Plus;
- chiusura chiara;
- Free sempre utilizzabile;
- nessun timer artificiale, prezzo barrato falso o dark pattern;
- trial e piano non preselezionati in modo ambiguo;
- prezzo, rinnovo, annullamento, restore, Family Sharing e cosa resta Free sempre visibili.

Card non modale possibile dopo un ciclo di valore:

> Ti piace come Routally collega le tue routine? Scopri Plus.

## 31.6 StoreKit 2

Prodotti:

- `plus_annual` — auto-renewable subscription;
- `plus_lifetime` — non-consumable;
- entitlement interno unico: `plus`.

Comportamento:

- `Transaction.currentEntitlements`;
- `Transaction.updates`;
- verifica on-device;
- ripristino acquisti;
- gestione abbonamento;
- niente booleano locale canonico;
- cache solo per continuità UI;
- rimborsi/revoche gestiti;
- stato `inGracePeriod` trattato come Plus.

## 31.7 Billing Grace Period

- 16 giorni;
- solo paid-to-paid;
- test Sandbox prima della produzione.

## 31.8 Downgrade

Alla scadenza Plus:

### 7 giorni di transizione

- tutto continua;
- niente nuove creazioni oltre Free;
- spiegazione chiara;
- scelta delle routine da mantenere.

### Dopo 7 giorni

- massimo 10 routine e 5 collegamenti attivi;
- le altre vengono messe in pausa;
- nessun dato cancellato;
- follow-up aperti completabili;
- cronologia oltre le 4 settimane conservata ma non consultabile;
- configurazioni widget salvate e una sola istanza widget Free resta attiva;
- luoghi salvati conservati; oltre il primo restano configurati ma non attivano trigger, e i follow-up collegati usano il fallback temporale;
- l'accento visivo torna a Routally Indigo, conservando la preferenza Plus;
- riattivazione immediata con Plus.

### 31.8.1 Le conseguenze interrotte devono essere visibili

Una routine in pausa non riceve aggiornamenti automatici dai collegamenti in ingresso,
secondo la sezione 17.1 e l'invariante 16 della sezione 16.6. Il downgrade mette in pausa
le routine oltre il limite: senza un avviso esplicito, una registrazione smetterebbe
silenziosamente di aggiornare i propri elementi collegati.

Questo violerebbe il principio 5 e il divieto di automazioni senza origine visibile della
sezione 15.10. Il downgrade deve quindi rispettare le regole seguenti.

- La schermata di scelta delle routine da mantenere mostra, per ogni routine candidata alla pausa, quali collegamenti si interrompono e quali routine ne dipendono. La scelta non è mai cieca.
- Le routine che fanno parte di una catena attiva vengono proposte per prime tra quelle da mantenere, perché metterle in pausa produce l'effetto meno prevedibile per l'utente.
- Dopo la pausa, il dettaglio della routine sorgente indica nella sezione Conseguenze quali collegamenti sono sospesi e perché.
- Il riepilogo dopo la registrazione della sezione 9.5 elenca la conseguenza sospesa invece di ometterla, così l'utente non deve dedurre l'assenza di un aggiornamento.
- La comunicazione resta non giudicante e non usa la conseguenza interrotta come leva di riacquisto: è un'informazione di stato, non un promemoria commerciale.
- La riattivazione di Plus ripristina i collegamenti senza richiedere una riconfigurazione manuale.

## 31.9 Matrice commerciale obbligatoria

La specifica StoreKit deve coprire:

- Free;
- trial;
- annuale attivo;
- lifetime;
- Family Sharing;
- periodo di grazia;
- billing retry;
- scadenza;
- rimborso;
- revoca;
- acquisto non sincronizzato;
- offline;
- downgrade;
- collegamenti sospesi dal downgrade e loro visibilità;
- luoghi oltre il limite Free e fallback temporale;
- superamento limiti;
- Kit oltre limite;
- widget Plus;
- Beta Plus;
- Commerce QA.

## 31.10 TestFlight commerce

- Beta Plus automatico per tester normali;
- gruppo Commerce QA senza sblocco automatico;
- test Free, trial, Annual, Lifetime, Family Sharing, restore, expiry, downgrade;
- acquisti TestFlight non trasferiti in produzione;
- al lancio i dati restano, Beta Plus termina;
- eventuali offer code Lifetime per tester selezionati.

---

# 32. Sito, supporto e documenti legali

## 32.1 Sito

Dominio: `routally.com`.

Hosting iniziale: GitHub Pages, sito statico bilingue e senza tracker.

Il sito non usa form server-side nella 1.0: i contatti aprono il client email o permettono di copiare l'indirizzo, evitando raccolte aggiuntive di dati.

Pagine:

- Home;
- Come funziona;
- Routine Kits;
- Prezzi;
- Supporto;
- Privacy;
- Termini;
- Routally Plus;
- Accessibilità;
- Changelog;
- App Store;
- GitHub.

## 32.2 Supporto

### Alpha/beta

- TestFlight Feedback come canale ufficiale;
- screenshot, commenti e crash tramite App Store Connect;
- nessuna issue GitHub.

### Pubblico

- `support@routally.com`;
- compositore email nativo MessageUI;
- sito supporto e FAQ;
- recensioni gestite in App Store Connect;
- GitHub non è helpdesk.

Dati tecnici precompilati, con consenso:

- versione/build;
- OS;
- modello generale;
- lingua;
- categoria feedback.

Mai inclusi automaticamente:

- routine;
- note;
- luoghi;
- cronologia;
- ID iCloud.

L'utente può allegare facoltativamente uno screenshot. Il pacchetto diagnostico redatto è anch'esso facoltativo e deve essere mostrato in anteprima prima dell'invio.

## 32.3 Recensioni

Prompt nativo soltanto dopo valore reale:

- almeno 7 giorni;
- almeno 5 eventi;
- almeno un ciclo collegato completato;
- nessun errore recente;
- nessun paywall appena mostrato;
- nessun feedback negativo nella sessione.

La richiesta nativa non viene chiamata come risposta diretta a un pulsante, perché iOS decide se mostrarla. Il link permanente «Valuta Routally» nel Profilo apre invece la pagina App Store.

## 32.4 Legale

- EULA standard Apple;
- Privacy Policy IT/EN;
- Termini IT/EN;
- Termini Plus;
- Accessibilità;
- nessun checkbox legale bloccante nell'onboarding;
- revisione legale prima della 0.9.

I Termini chiariscono:

- strumento organizzativo, non medico/professionale/di sicurezza;
- soglie confermate dall'utente;
- notifiche soggette a iOS, Focus, permessi e dispositivo;
- geofencing non istantaneo garantito;
- perimetro Lifetime;
- controllo utente dei dati.

---

# 33. App Store

## 33.1 Distribuzione

- mondiale dalla 1.0;
- inglese default;
- italiano localizzato;
- esclusioni territoriali soltanto per obblighi non risolti.

## 33.2 Categoria e rating

- primaria: **Productivity**;
- secondaria: **Lifestyle**;
- target rating: **4+**, subordinato al questionario finale;
- non Kids.

## 33.3 Metadata

Definiti nella sezione Brand.

Keywords e descrizione devono rappresentare:

- routine;
- reminders;
- goals;
- usage cycles;
- connected routines;
- follow-ups;
- productivity;
- lifestyle;
- no streak pressure.

Nessun claim di unicità assoluta o affidabilità geolocalizzata garantita.

## 33.4 Screenshot

### iPhone — 7 schermate IT/EN

1. Le tue routine, finalmente collegate;
2. Registra una volta;
3. Tutto si aggiorna insieme;
4. Promemoria quando puoi agire;
5. Cicli che si chiudono;
6. Parti da un Kit;
7. Comprendi le routine senza ossessioni.

### iPad

Set dedicato:

- Routine a due colonne;
- Esplora;
- Analisi;
- dettaglio e cronologia.

## 33.5 App Preview

- 20–25 secondi;
- IT e EN;
- app reale;
- evento → aggiornamenti → follow-up → reset;
- non un'animazione astratta;
- registrazione prodotta dalla release candidate reale, non da un prototipo statico.

## 33.6 Custom Product Pages

Pagina generale più:

1. Sport e benessere;
2. Casa e cura quotidiana;
3. Studio e hobby.

Ognuna con screenshot, testo e link specifici.

Screenshot e composizioni devono usare schermate della build reale finale, non ricostruzioni statiche.

Dopo aver raccolto traffico sufficiente, usare Product Page Optimization per testare fino a tre varianti della pagina principale. Non eseguire A/B test privi di volume statistico.

Gli In-App Events non fanno parte del lancio ordinario e non devono promuovere normali routine o sconti. Possono essere valutati soltanto per un vero evento temporaneo e sostanziale futuro.

## 33.7 Preordine

Non di default. Decisione in 0.9:

- soltanto se esiste pubblico concreto;
- 2–3 settimane;
- RC già stabile;
- nessuna data prematura.

## 33.8 Release

### Fase A — rilascio controllato

Prime 2–3 settimane:

- tester e primi interessati;
- monitoraggio;
- eventuale 1.0.1;
- niente paid acquisition significativa.

### Fase B — promozione

Dopo stabilità:

- contenuti sito;
- creator/testate;
- community produttività e Apple;
- custom pages;
- Product Hunt facoltativo;
- test di acquisizione soltanto dopo retention e conversione.

## 33.9 App Review evidence package

- note dettagliate;
- script di verifica;
- Kit consigliati;
- StoreKit Sandbox;
- posizione/fallback;
- iCloud senza account;
- widget/intents;
- Free/Plus/Lifetime;
- screencast interno EN;
- quattro archetipi, non soltanto Palestra;
- nessun account demo richiesto: il revisore può usare la modalità Free locale, installare un Kit e testare gli acquisti nell'ambiente Apple;
- istruzioni precise per raggiungere ogni funzione soggetta a permesso.

## 33.10 Identità dello sviluppatore

**Decision Gate DG-DEVELOPER-IDENTITY — fase 0.8.**

Alternative da valutare:

- **account individuale:** percorso più semplice, ma App Store mostra il nome legale personale; non fare affidamento su una futura conversione per cambiare liberamente il developer name senza conferma scritta Apple;
- **entità giuridica propria idonea Apple:** può rendere Temisfera il developer name, richiede D‑U‑N‑S, sito/email aziendali, dati DSA e costi amministrativi;
- **forma societaria italiana:** S.r.l.s./S.r.l. unipersonale come soluzione più lineare; altre partnership soltanto con socio reale e verifica preventiva Apple/D&B;
- **publisher reale:** possibile con contratto e licenza IP, ma lascia controllo contrattuale ultimo, pagamenti e trasferimento all'Account Holder del publisher;
- **account rental:** opzione ad alto rischio di controllo, credenziali e conformità; non raccomandata come baseline, ma la decisione finale resta nel gate.

La preferenza attuale è account individuale o organizzazione propria; publisher eventualmente come partner di crescita dopo la validazione. Non creare il primo record definitivo, il Bundle ID finale, i container definitivi o i prodotti StoreKit finché il gate non è chiuso o finché Apple non conferma la trasferibilità desiderata.

---

# 34. Metriche di successo

## 34.1 Beta privata

### Natura delle soglie

Queste soglie sono **qualitative**, non statistiche. Routally non usa analytics (sezione
22.1) e la beta privata conta 20–40 tester: i valori sotto derivano da questionari
auto-riferiti e da osservazione diretta su un campione piccolo e non rappresentativo.

Vanno quindi lette come segnali di allineamento, non come misure. Un valore sotto soglia
apre un'indagine qualitativa sul motivo; non è di per sé un blocco aritmetico, e un valore
sopra soglia non certifica il prodotto. La decisione di procedere alla 0.9 resta del
Product Owner e si basa sui problemi osservati, non sulla percentuale.

Nessuna di queste percentuali va usata in comunicazione esterna, materiali App Store o
affermazioni pubbliche: non hanno la solidità per sostenerle.

### Soglie

Senza analytics nascosti, tramite TestFlight e questionari:

- almeno 80% dei percorsi assegnati completato senza assistenza;
- nessuno dei quattro archetipi con problema strutturale;
- almeno 60% crea una routine reale propria;
- almeno 50% usa l'app alla quarta settimana;
- almeno 40% dichiara disponibilità a pagare Annual o Lifetime;
- zero perdita/duplicazione irreversibile;
- nessun flusso principale sistematicamente frainteso.

Archetipi:

1. ricorrenza dall'ultima esecuzione;
2. obiettivo periodico;
3. ciclo utilizzo/durata/quantità;
4. routine collegata con follow-up e reset.

Tester:

- utenti normali;
- utenti habit tracker;
- persone molto organizzate;
- IT/EN;
- iPhone/iPad.

## 34.2 Primi 90 giorni

Target interni, da rivedere con dati reali:

- retention 7/28 giorni almeno in linea con peer benchmark;
- conversione pagina almeno mediana;
- crash rate pari o migliore del peer group;
- trial → annuale almeno 25%;
- refund rate sotto 5%;
- volume supporto sostenibile;
- nessun problema ricorrente sul motore fondamentale.

## 34.3 Metriche non usate

- DAU come fine a sé stesso;
- streak;
- tempo in app da massimizzare;
- numero di notifiche;
- logging più frequente come successo.

Successo significa ridurre il carico mentale e chiudere cicli utili.

---

# 35. Strategia di test

## 35.1 Principio

Non usare la code coverage percentuale come unico obiettivo. Privilegiare comportamenti critici, invarianti ed edge case.

## 35.2 Swift Testing — dominio

Copertura obbligatoria:

- tre modalità temporali;
- calendario vs tempo effettivo;
- obiettivi e reset;
- eventi, durata e quantità;
- `usage OR time`;
- links multipli;
- soglia e follow-up;
- reset;
- pause/archive/delete;
- modifica retroattiva;
- revisioni e tombstone;
- timezone e DST;
- settimane/mesi/anni;
- ricorrenze mensili;
- deduplica;
- conflitti;
- downgrade;
- esportazione CSV;
- migrazioni;
- invarianti.

Ogni bug produce un regression test.

## 35.3 XCTest/XCUITest

Flussi obbligatori:

1. onboarding;
2. creazione rapida;
3. configurazione completa;
4. Kit;
5. quattro archetipi;
6. link e follow-up;
7. geofencing/fallback;
8. correzione;
9. search;
10. StoreKit;
11. downgrade;
12. iCloud;
13. widget/intents;
14. CSV;
15. delete/recover;
16. accessibility;
17. localization;
18. iPad.

## 35.4 Pull request gate

- build;
- zero nuovi warning;
- `swift format lint --strict`;
- domain tests;
- migration tests;
- concurrency checks;
- secret scan;
- preview/fixture per UI;
- documentazione.

## 35.5 Release gate 1.0

- suite verde;
- nessun crash blocker;
- nessun bug Critical/High;
- device reali;
- accessibility audit;
- privacy audit;
- StoreKit audit;
- iCloud recovery;
- offline;
- upgrade dalla build precedente;
- App Review checklist;
- performance budget;
- legal review;
- App Store assets finali.

Una funzione senza test adeguato viene rinviata.

## 35.6 TestFlight

### Alpha interna

5–10 persone, focus su motore, crash e dati.

### Beta privata

20–40 tester selezionati, focus comprensione, utilità e attrito.

### Beta ampliata

100–300, dopo stabilità, feedback TestFlight e scenari settimanali.

### 1.0

Release manuale dopo approvazione.

Dalla 1.1: phased release di default.

---

# 36. Performance e affidabilità

## 36.1 Budget

- first useful content ≤ 1,5 s cold launch su dispositivo minimo supportato;
- feedback visivo/aptico ≤ 100 ms;
- aggiornamento ordinario UI/proiezioni ≤ 300 ms;
- scroll fluido;
- nessun blocco su CloudKit;
- azioni offline;
- ricalcoli pesanti fuori dal percorso immediato;
- cronologia paginata.

## 36.2 Dataset di stress

- 300 routine attive;
- 1.000 archiviate;
- 100.000 eventi;
- 500 link;
- 2.000 follow-up;
- più anni e fusi;
- revisioni/tombstone;
- conflitti multi-device.

## 36.3 Strategie

- proiezioni;
- ricalcolo dipendenze coinvolte;
- paginazione;
- cache ricostruibili;
- actor dedicati;
- cancellation;
- indici;
- niente full scan all'avvio;
- niente location continua;
- trigger geografici prioritizzati.

## 36.4 Gate

- launch instruments;
- hitch/scroll;
- memory/leaks;
- energy;
- stress database;
- export grande;
- ricalcolo retroattivo;
- offline lungo;
- sync;
- widget/intents;
- Debug vs Release.

---

# 37. Versioning e milestone interne

## 37.1 Versioni pre-1.0

Le versioni `0.x` sono fasi interne verso una 1.0 completa, non un MVP commerciale.

### 0.1 — Foundation

Ordine obbligatorio:

1. repository e governance documentale;
2. direzione UI Apple-native e flussi iniziali nelle specifiche;
3. progetto Xcode, target e SwiftUI UI Foundation;
4. technical spike.

Include:

- repository e documentazione;
- brand foundations in Asset Catalog e SwiftUI;
- progetto Xcode;
- Routally Dev;
- CI;
- architettura base;
- spike dati, StoreKit, location, navigation/search e iPad/accessibilità.

### 0.2 — Core Routine Engine

- eventi;
- regole temporali;
- misure;
- obiettivi;
- cicli;
- proiezioni;
- invarianti;
- test dominio;
- spike TG-RECALC sul ricalcolo retroattivo, prima di costruire proiezioni e interfaccia sopra il motore.

### 0.3 — Vertical slice

Flusso completo:

- routine sorgente;
- collegamento;
- soglia;
- follow-up;
- reminder contestuale;
- completamento;
- reset;
- cronologia/correzione.

Il caso di sviluppo può usare Palestra, ma il motore deve essere generico e testato sui quattro archetipi.

### 0.4 — Today & Routines

- shell navigazione;
- Oggi;
- lista Routine;
- dettaglio;
- creazione rapida/progressiva;
- pause/archive/delete.

### 0.5 — Explore & System

- 12 Kit;
- Esplora;
- notifiche;
- luoghi;
- widget;
- App Intents;
- Universal Links;
- Profilo/iCloud.

### 0.6 — Insights, Search & Commerce

- Analisi;
- search;
- StoreKit;
- paywall;
- downgrade;
- support/legal;
- App Store foundations.

### 0.7 — Feature complete / freeze

- tutte le feature 1.0 implementate;
- nessuna nuova feature;
- soltanto bug, accessibilità, UX indispensabile, localizzazione, performance e App Review.

### 0.8 — Alpha

- test interni;
- revisione UI, accessibilità e implementazione;
- identity gate;
- legal/privacy/security audit;
- stabilization.

### 0.9 — Beta / Release Candidate

- beta privata/ampliata;
- success criteria;
- StoreKit Sandbox;
- schema CloudKit production;
- App Review evidence;
- final assets;
- launch date gate.

### 1.0 — App Store

- release manuale;
- worldwide;
- controlled launch;
- support ready.

## 37.2 Milestone operative

Gli identificativi distinguono livelli diversi e non formano numeri decimali:

- `0.x` e `1.0` identificano la fase/versione interna complessiva del prodotto;
- `Mnn` identifica una milestone, cioè un risultato integrato con una Definition of Done;
- `Enn` identifica un'epica, cioè un'area di lavoro implementabile attraverso attività e PR;
- `TG-*` identifica una validazione tecnica vincolante;
- `DG-*` identifica una decisione del Product Owner.

Una sigla come `M1.2` non viene usata: potrebbe essere letta sia come sotto-milestone sia
come versione Routally 1.2. Le milestone usano identificativi interi e stabili:

- `M01` — Foundation;
- `M02` — Core Routine Engine;
- `M03` — Vertical Slice;
- `M04` — Today & Routine;
- `M05` — Explore & Kits;
- `M06` — System Integrations;
- `M07` — Insights & Search;
- `M08` — Commerce & Release Foundations;
- `M09` — Accessibility & Localization;
- `M10` — Alpha;
- `M11` — Beta;
- `M12` — App Store 1.0.

### Mappa canonica fase → milestone → epiche → gate

Ogni epica appartiene a una sola milestone primaria e gli ID delle epiche seguono l'ordine
delle milestone, non una gerarchia decimale. I gate non sono figli organizzativi della
milestone: sono condizioni che ne precedono o vincolano il completamento.

| Fase/versione | Milestone | Epiche primarie | Gate e prerequisiti principali |
|---|---|---|---|
| `0.1` | `M01` Foundation | `E01`–`E03` | spike `TG-DATA`, `TG-LOCATION`, `TG-STOREKIT`, `TG-SEARCH`, `TG-IPAD-ACCESSIBILITY` |
| `0.2` | `M02` Core Routine Engine | `E04`–`E05` | esito `TG-DATA`; `TG-RECALC` prima delle proiezioni |
| `0.3` | `M03` Vertical Slice | `E06` | `M01` e `M02` concluse; gate dati, ricalcolo e location applicati tramite adapter testabili, senza anticipare le integrazioni di sistema complete |
| `0.4` | `M04` Today & Routine | `E07`–`E10` | vertical slice reale verificata su device e offline |
| `0.5` | `M05` Explore & Kits | `E11` | motore, creazione e comportamento Free/Plus disponibili |
| `0.5` | `M06` System Integrations | `E12`–`E14` | `DG-DOMAIN` chiuso; esiti `TG-LOCATION` e `TG-IPAD-ACCESSIBILITY`; iCloud Development verificato |
| `0.6` | `M07` Insights & Search | `E15`–`E16` | esito `TG-SEARCH`; gate di evidenza degli insight |
| `0.6` | `M08` Commerce & Release Foundations | `E17`–`E18` | esito `TG-STOREKIT`; matrice commerciale, supporto, legale e App Store foundations completi |
| `0.7` | `M09` Accessibility & Localization | `E19` | `M01`–`M08` feature complete; avvio del feature freeze |
| `0.8` | `M10` Alpha | `E20` | `DG-DEVELOPER-IDENTITY` chiuso; `TG-PERFORMANCE`; audit privacy e sicurezza |
| `0.9` | `M11` Beta | `E21` | RC stabile, schema CloudKit production; `DG-TRADEMARK`, `DG-ICON` e `DG-LAUNCH` chiusi |
| `1.0` | `M12` App Store 1.0 | `E22` | release gate delle sezioni 35, 46 e 52; submission approvata e rilascio manuale autorizzato |

La fase `0.7` non rende accessibilità e localizzazione attività finali: `E19` conduce
l'audit complessivo, mentre ogni epica precedente deve già rispettare le dimensioni
trasversali della sezione 0.4 durante la propria implementazione.

La mappa copre il percorso verso la 1.0. `DG-CLOUD-PRICING` e `DG-FUTURE-ANALYTICS`
restano fuori da queste milestone perché appartengono rispettivamente alla 2.0 e a una
valutazione futura, come definito nelle sezioni 39 e 50.

Le milestone vengono mantenute nel backlog personale e nella documentazione del repository. GitHub non viene usato per raccogliere issue o richieste pubbliche; branch e PR restano strumenti tecnici personali.

## 37.3 Feature freeze

Dalla 0.7 sono consentiti:

- bug fix;
- accessibilità;
- microcopy/localizzazione;
- performance;
- compliance;
- UX indispensabile emersa dai test.

Ogni nuova idea va in 1.1+.

## 37.4 Data di lancio e stime

Nessuna data pubblica prima della 0.9 e dei release gate. Nessuna stima in settimane deve essere trattata come affidabile prima di aver completato la SwiftUI UI Foundation e i technical spike della 0.1.

**Decision Gate DG-LAUNCH:** data e possibile preordine dopo RC stabile.

## 37.5 Linea di galleggiamento della 1.0

Il rischio «Scope 1.0 troppo ampio» della sezione 43 è classificato con probabilità e
impatto alti, ma la sua unica mitigazione era finora un processo — milestone, freeze e
rinvio esplicito — non una scelta. Con un solo sviluppatore la decisione di taglio verrà
comunque presa: questa sezione la prende in anticipo, a mente fredda, invece di lasciarla
maturare sotto pressione alla 0.7.

Questa sezione non riduce lo scope della sezione 6 e non autorizza un agente a ridurlo. È
un elenco pre-approvato di rinunce che il **Product Owner** può attivare, una alla volta e
in quest'ordine, quando una milestone slitta in modo materiale. Ogni attivazione viene
registrata nel Decision Register con data e motivo.

### Ordine di sacrificio

1. **Catalogo Kit da 12 a 6.** Restano i 4 introduttivi più Corsa e Rasatura, che coprono i quattro archetipi. Gli altri sei passano alla 1.1. Esplora resta, con meno raccolte.
2. **Analisi ridotta alla sola panoramica descrittiva.** Restano «In evidenza» con fatti osservati e la panoramica del periodo; «Routine da rivedere» e i suggerimenti passano alla 1.1. I gate di evidenza della sezione 13.4 restano validi per ciò che resta.
3. **iPad a parità di layout adattivo senza `NavigationSplitView`.** L'app resta universale, ridimensionabile, accessibile e conforme alla sezione 7.3 per Dynamic Type, tastiera e puntatore; le due colonne di Routine ed Esplora passano alla 1.1.
4. **Ricerca globale ridotta a routine e follow-up.** Kit, Aree e sinonimi estesi passano alla 1.1. La ricerca resta presente: la sezione 40.5 conferma che è un requisito, non un'opzione.

### Non sacrificabile

Non entrano in questo elenco, in nessuna circostanza e a nessuna milestone:

- il motore e le sue invarianti, incluse correzione retroattiva e ricostruibilità;
- l'affidabilità dei dati, iCloud, offline e recupero;
- accessibilità e localizzazione IT/EN complete;
- privacy, sicurezza e assenza di telemetria;
- la trasparenza e l'annullabilità delle conseguenze;
- la correttezza commerciale di Free, Plus, downgrade e ripristino acquisti.

Se il taglio necessario dovesse toccare uno di questi punti, la risposta corretta è
spostare la data, non pubblicare una 1.0 fragile: vale la sezione 52.

---

# 38. Roadmap 1.X

## 38.1 Routally 1.1 — Più contesto

- varianti: palestra, corsa, casa;
- esclusione rapida di un link per singolo evento;
- luogo + orario;
- ritardo dopo arrivo;
- reminder prima della prossima routine;
- integrazione Calendario iniziale;
- opzione per mantenere l'orario di casa in casi specifici durante i viaggi;
- condizioni guidate semplici;
- ulteriori miglioramenti iPad.

## 38.2 Routally 1.2 — Integrazioni Apple

- app Apple Watch;
- complicazioni;
- logging dal polso;
- Apple Health;
- NFC;
- Comandi Rapidi avanzati;
- Centro di Controllo/tasto Azione più configurabili;
- approfondimenti iPad.

## 38.3 Routally 1.3 — Kit e adattamento

- condivisione privata Kit;
- import tramite link/file di configurazione Kit, non backup dati;
- nuovi Kit;
- aggiornamenti facoltativi Kit;
- suggerimenti sul ritmo reale;
- vacanze;
- stagionalità;
- soglie più realistiche;
- sempre conferma utente.

## 38.4 Routally 1.4+

- allegati utili;
- ulteriori unità;
- Analisi approfondita;
- automazioni a più livelli guidate;
- eventuali analytics privacy-first soltanto con nuova decisione;
- preparazione account 2.0;
- lingue ulteriori.

## 38.5 Prezzi 1.X

Restano:

- Annual 14,99 €;
- Lifetime 39,99 €;
- nessun mensile.

Nessun aumento prima della 2.0.

---

# 39. Roadmap 2.X e lungo termine

## 39.1 Routally 2.0 — Account Routally

- backend proprietario;
- Sign in with Apple;
- migrazione local/iCloud;
- sync account tra dispositivi Apple;
- dispositivi e sicurezza;
- modalità locale preservata, se tecnicamente sostenibile;
- nuovo modello cloud separato dal Lifetime 1.X;
- pricing da ridefinire.

## 39.2 Routally 2.1 — Condivisione

- spazi coppia/famiglia/conviventi;
- routine private e condivise;
- assegnazione;
- turnazione;
- notifiche coordinate;
- ruoli e permessi;
- cronologia modifiche;
- **Centro Attività**.

## 39.3 Routally 2.2 — Web

- consultazione;
- gestione routine;
- creazione/modifica;
- Analisi;
- Kit;
- spazi condivisi;
- nessun compromesso retroattivo sull'architettura o sull'esperienza nativa iOS.

## 39.4 Routally 2.3 — Android

- scelta nativa o multipiattaforma presa allora;
- parità funzioni fondamentali;
- integrazioni Android;
- account Routally obbligatorio per sync.

## 39.5 2.X successive

- libreria pubblica curata Kit;
- Kit utenti;
- moderazione/versioni;
- creator verificati;
- eventuale marketplace;
- API pubblica;
- integrazioni esterne;
- automazioni multilivello controllate;
- HomeKit o dispositivi compatibili soltanto con casi d'uso concreti;
- import/migrazione assistita da altri habit tracker e reminder;
- eventuali tag o hardware dedicati;
- template professionali e automazioni di terze parti, con governance e sicurezza.

Queste sono ipotesi di lungo termine, non feature approvate né impegni commerciali.

## 39.6 AI futura

AI soltanto 2.X, facoltativa, soprattutto come interfaccia di configurazione:

> «Vado in palestra tre volte a settimana e cambio l'asciugamano dopo quattro allenamenti.»

Regole:

- anteprima strutturata obbligatoria;
- nessuna modifica automatica;
- on-device preferito;
- cloud richiede decisione privacy/costi;
- app interamente funzionante senza AI.

## 39.7 Decision Gate commerciale 2.0

**DG-CLOUD-PRICING:** definire:

- costo backend;
- piano cloud;
- trattamento Lifetime;
- Family/Shared pricing;
- web/Android;
- eventuali aumenti per nuovi utenti.

---

# 40. Technical spikes e validation gates

## 40.1 TG-DATA — SwiftData/CloudKit

Verificare:

- event store;
- 100k eventi;
- App Group/widget;
- offline;
- multi-device;
- revisioni/tombstone;
- migrazioni;
- container provvisorio pre-gate e passaggio al container definitivo;
- CloudKit production schema;
- recovery.

Esito:

- Go;
- Adapt;
- Fallback Core Data/CloudKit.

## 40.2 TG-RECALC — ricalcolo retroattivo deterministico

Il ricalcolo su correzione retroattiva è il cuore del valore differenziante — sezioni 16.3,
16.5, requisiti RTY-010 e RTY-034 — ed è la parte del motore che più probabilmente si
rivela lenta o non deterministica sotto carico reale. Finora compariva solo come dataset di
stress nella sezione 36.2, senza un esito formale.

Lo spike si esegue nella 0.2, prima che Oggi, Analisi e le proiezioni vengano costruite
sopra il motore.

Verificare, sul dataset di stress della sezione 36.2:

- modifica di un evento di alcuni mesi prima con 100.000 eventi, 500 collegamenti e 2.000 follow-up;
- determinismo: due ricalcoli sullo stesso stato producono lo stesso risultato, indipendentemente dall'ordine di applicazione;
- convergenza multi-device: lo stesso insieme di eventi consegnato in ordini diversi da CloudKit converge, secondo l'invariante 10 della sezione 16.6;
- propagazione lungo più collegamenti dallo stesso evento sorgente;
- rimozione e rigenerazione dei follow-up secondo la matrice della sezione 41.1, incluso il caso di soglia ridotta sotto il progresso quando un follow-up del ciclo precedente è già stato completato;
- costo del ricalcolo mantenuto fuori dal percorso immediato, con la UI che rispetta il budget della sezione 36.1;
- cancellazione del ricalcolo in corso senza stati intermedi persistiti;
- confronto per checksum tra stato ricalcolato e stato ricostruito da zero dagli eventi canonici.

Esito:

- **Go:** ricalcolo incrementale sulle sole dipendenze coinvolte.
- **Adapt:** ricalcolo incrementale con finestra limitata e ricostruzione completa differita in background.
- **Fallback:** ricostruzione completa asincrona con stato esplicito in interfaccia; la correzione retroattiva resta disponibile, la sua applicazione non è istantanea.

In nessun esito la correzione retroattiva viene rimossa dalla 1.0 o resa non deterministica:
è coperta dalla sezione 37.5 tra le funzioni non sacrificabili.

## 40.3 TG-LOCATION — geofencing

Verificare:

- arrivo/uscita;
- next visit;
- fallback;
- deduplica;
- limite trigger;
- revoca permesso;
- device principale;
- battery impact.

## 40.4 TG-STOREKIT

Verificare:

- Annual;
- trial;
- Lifetime;
- Family;
- grace;
- refund/revoke;
- downgrade;
- offline;
- TestFlight.

## 40.5 TG-SEARCH

Verificare:

- search tab iOS 26;
- 20–50 routine;
- Kit e follow-up;
- sinonimi IT/EN;
- accessibilità;
- performance.

Cerca rimane requisito confermato; lo spike definisce implementazione, non la sua presenza.

## 40.6 TG-IPAD-ACCESSIBILITY

Verificare:

- split view;
- resizable windows;
- keyboard/pointer;
- VoiceOver;
- max Dynamic Type;
- Liquid Glass reduce transparency.

## 40.7 TG-PERFORMANCE

Verificare budget con build Release e device fisici.

---

# 41. Matrice delle eccezioni

La specifica operativa deve definire per ogni caso fonte di verità, UI, fallback, recupero e test.

## 41.1 Eventi e regole

| Caso | Comportamento richiesto |
|---|---|
| Evento modificato dopo soglia | Ricalcolo; follow-up rimosso o aggiornato se non più valido |
| Evento eliminato dopo follow-up | Follow-up ricalcolato; completamento precedente conservato come revisione |
| Soglia ridotta sotto progresso | Follow-up generato con spiegazione |
| Soglia aumentata | Follow-up non più valido rimosso se non completato; ciclo ricalcolato |
| Link cambiato | Solo futuro; storico invariato |
| Link circolare | Configurazione rifiutata |
| Doppio tap | Idempotenza/deduplica |
| Quantità negativa/impossibile | Validazione e messaggio |
| Evento retrodatato | Attribuzione al periodo originale e ricalcolo |

## 41.2 Tempo

| Caso | Comportamento |
|---|---|
| DST | Calendar components; nessuna deriva |
| Cambio fuso | Futuro local time, storico originale |
| Ora manuale cambiata | Riconciliazione, niente doppio evento |
| Giorno 31 | Mese breve senza deriva permanente |
| Periodo settimanale in viaggio | Evento attribuito al giorno locale originale |
| Occorrenze arretrate | Una riga attiva; storico conservato |

## 41.3 Follow-up/location

| Caso | Comportamento |
|---|---|
| Trigger geografico non arriva | Fallback temporale |
| Fallback arriva prima | Trigger successivo deduplicato |
| Permesso revocato | Avviso discreto e fallback |
| Luogo eliminato | Chiedere nuovo contesto o usare fallback |
| Device principale offline | Nessun failover automatico; stato nel Profilo |
| Follow-up completato su iPad | iPhone annulla quando riceve sync |

## 41.4 iCloud

| Caso | Comportamento |
|---|---|
| iCloud assente | Locale completo |
| Quota insufficiente | Locale continua, stato Richiede attenzione |
| Offline lungo | Merge eventi e ricalcolo |
| Due modifiche config | Revisioni; latest con recovery o conflitto guidato |
| Cambio Apple Account | Avviso, nessuna cancellazione silenziosa |
| Reinstallazione | Recupero CloudKit se disponibile |
| Migrazione interrotta | Transazione/rollback; runbook |

## 41.5 StoreKit

| Caso | Comportamento |
|---|---|
| Trial scaduto | Downgrade protetto |
| Billing retry | Stato StoreKit; grace se applicabile |
| Refund/revoke | Entitlement rimosso, dati intatti |
| Family sharing finisce | Downgrade protetto |
| Lifetime non verificato offline | Cache temporanea prudente, refresh successivo |
| Acquisto interrotto | Nessun doppio addebito; stato chiaro |
| Restore fallisce | Retry e supporto |

---

# 42. Runbook operativi

Devono essere pronti prima della 0.9.

## 42.1 CloudKit non sincronizza

- rilevazione;
- stato utente;
- preservare locale;
- retry;
- log redatto;
- verifica quota/account;
- repair projections;
- escalation Apple Feedback Assistant.

## 42.2 Proiezione incoerente

- Consistency Engine;
- ricostruzione;
- confronto checksum;
- preservare eventi;
- nessuna cancellazione automatica canonica;
- regression test.

## 42.3 Migrazione fallita

- bloccare scritture parziali;
- conservare store precedente;
- diagnostica;
- fallback;
- hotfix;
- test nuova migrazione.

## 42.4 Notifiche mancanti

- autorizzazioni;
- device principale;
- richieste programmate;
- fallback;
- Focus/system settings;
- non promettere delivery esatta.

## 42.5 StoreKit entitlement

- current entitlements;
- transaction updates;
- restore;
- grace/refund/revoke;
- stato offline;
- messaggio supporto.

## 42.6 App Review rejection

- classificare motivo;
- riprodurre;
- rispondere con evidenze;
- modifica minima;
- nessun cambio frettoloso di modello;
- nuova submission.

## 42.7 Bug critico post-lancio

- severità;
- sospendere promozione;
- hotfix;
- test regressione;
- support communication;
- phased release 1.1+;
- postmortem.

## 42.8 Vulnerabilità

- canale privato;
- triage;
- patch;
- segreti/entitlement;
- disclosure dopo fix;
- advisory se appropriato.

## 42.9 Geofencing inaffidabile

- verificare permessi, regioni attive e priorità;
- controllare deduplica con fallback;
- mantenere il follow-up in Oggi;
- passare a reminder temporale quando necessario;
- regression test su arrivo, uscita e next visit.

## 42.10 Widget, App Intents o ricerca non aggiornati

- verificare App Group e proiezioni;
- rigenerare snapshot/indice;
- preservare l'event store;
- invalidare cache ricostruibili;
- testare device bloccato e offline.

## 42.11 Dominio, email o Apple membership

- monitorare rinnovi;
- recovery owner documentato;
- evitare scadenze di dominio e membership;
- verificare certificati, accordi e ruoli;
- piano di comunicazione se supporto o download sono impattati.

---

# 43. Risk register iniziale

Scala: probabilità P e impatto I: Basso/Medio/Alto.

| Rischio | P | I | Segnale | Mitigazione | Gate/fallback |
|---|---|---|---|---|---|
| SwiftData/CloudKit non regge event model | M | A | conflitti/migrazioni fragili | spike e adapter | TG-DATA, Core Data fallback |
| Creazione troppo complessa | A | A | abbandono/test assistiti | rapido default, preset, Kit | beta gate |
| Geofencing inaffidabile | M | A | reminder mancanti/duplicati | fallback e dedup | TG-LOCATION |
| Analisi poco utile | M | M | tab vuota/generica | evidence gates, insight decisionali | ridurre contenuti, non eliminare senza decisione |
| Search sovradimensionata | M | B | scarso uso/confusione | search globale chiara | TG-SEARCH |
| Scope 1.0 troppo ampio | A | A | ritardi e fragilità | milestone, 0.7 freeze, linea di galleggiamento pre-approvata | 37.5, Product Owner |
| Ricalcolo retroattivo lento o non deterministico | M | A | correzione che blocca la UI o produce esiti divergenti tra dispositivi | ricalcolo incrementale, checksum, invarianti testate | TG-RECALC |
| App percepita ossessiva | M | A | tester ansiosi, troppe notifiche | Calm View, no streak, Kit criteria | beta UX |
| App percepita troppo tecnica | M | A | confusione link/regole | linguaggio naturale, trasparenza | Simulator/usability testing |
| Performance cronologia | M | A | launch/scroll lenti | projections/index/paging | TG-PERFORMANCE |
| Doppie notifiche multi-device | M | M | feedback duplicazioni | primary device | integration tests |
| Free troppo generoso | M | M | bassa conversione | limiti quantitativi, mai sotto la soglia dei 4 Kit introduttivi | 31.1.1, 90-day review |
| Free troppo limitato | M | A | nessun valore provato | core engine gratuito | beta pricing |
| Lifetime insostenibile 2.0 | M | A | costi cloud | separazione cloud | DG-CLOUD-PRICING |
| Identità legale ritardata | M | A | impossibile creare store record | gate 0.8 | DG-DEVELOPER-IDENTITY |
| App Review pricing/location | M | M | rejection | notes, terms, evidence | review runbook |
| Repository pubblico espone asset | B | M | clone/indexing | copyright, asset review, secrets | security baseline |
| Assenza analytics limita diagnosi | M | M | poco insight uso | beta qualitativa, App Store data | decisione futura esplicita |
| Acquisizione insufficiente | M | A | poco traffico e poche prove | ASO, custom pages, creator, lancio in due fasi | 90-day review |
| Retention debole per attrito di logging | M | A | abbandono dopo setup | quick logging, widget, Intents, Kit utili | beta/90-day review |
| iOS 26 minimo riduce pubblico iniziale | M | M | base compatibile più piccola | qualità Apple-native, lancio non prematuro, review 2.0 | TG/market review |
| iCloud eliminazioni propagate | M | A | perdita percepita | revisions + 30-day trash | recovery tests |
| Competitor aggiunge linked routines | M | M | riduzione differenziazione | closed loops, Kits, context, calm | roadmap/positioning |

Il registro viene aggiornato a ogni milestone.

---

# 44. Ownership di account, asset e credenziali

## 44.1 Principio

Ogni asset strategico deve essere intestato a Matteo o alla futura entità Temisfera approvata, salvo una diversa decisione esplicita nel DG-DEVELOPER-IDENTITY. Nessun collaboratore, agente, agenzia o publisher deve diventare proprietario occasionale o non contrattualizzato di un asset necessario al funzionamento di Routally.

## 44.2 Ownership matrix

| Risorsa | Owner iniziale | Accesso | Recupero | Futuro trasferimento |
|---|---|---|---|---|
| GitHub | Matteo | account personale, 2FA | recovery codes | organizzazione Temisfera se utile |
| routally.com | Matteo | registrar, 2FA | contatto/recovery | Temisfera |
| Email Routally | Matteo | utenti nominativi | recovery/admin | Temisfera |
| Apple Developer | Decision Gate | Account Holder | procedura Apple | vincoli Apple |
| App Store Connect | stessa entità Apple | ruoli ufficiali | Account Holder | app transfer condizionato |
| Bundle ID | team Apple owner | ruoli | account Apple | delicato |
| CloudKit container | team Apple owner | entitlement | account Apple | delicato |
| App Groups | team Apple owner | entitlement | account Apple | delicato |
| StoreKit products | App Store Connect owner | ruoli | Account Holder | con app transfer |
| Xcode Cloud | team Apple | ruoli | Account Holder/Admin | legato al team |
| Sito GitHub Pages | GitHub owner | repo actions | GitHub recovery | trasferibile |
| Codice/brand pre-società | Matteo | copyright | documentazione | cessione/licenza a Temisfera |

## 44.3 Regole

- niente password o 2FA condivisi;
- ruoli ufficiali Apple e GitHub;
- recovery codes fuori dal repository;
- nessun token nei prompt degli agenti;
- nessun publisher/account rental senza chiusura esplicita del DG-DEVELOPER-IDENTITY; baseline: account proprio;
- futura agenzia lavora sull'account Routally;
- inventario aggiornato a ogni milestone di release;
- IP creata prima della società trasferita o concessa formalmente all'entità distributrice.

---

# 45. Budget e sostenibilità operativa

## 45.1 Principio

Lean, ma non gratuito a qualsiasi costo.

## 45.2 Costi ammessi

- Apple Developer Program;
- dominio/email;
- device/accessori test;
- consulenza legale/fiscale/accessibilità;
- eventuale costituzione Temisfera;
- strumenti a pagamento soltanto con beneficio concreto.

## 45.3 Strumenti gratuiti finché sufficienti

- GitHub pubblico;
- GitHub Pages;
- Xcode;
- framework Apple;
- TestFlight;
- Instruments;
- quote Xcode Cloud incluse;
- nessun backend/analytics/helpdesk SaaS 1.0.

## 45.4 Nuovi costi ricorrenti

Richiedono:

- esigenza;
- beneficio misurabile;
- costo annuale;
- privacy/security review;
- exit strategy;
- approvazione.

---

# 46. Compliance e checklist App Store

## 46.1 Privacy

- Privacy Policy URL;
- App Privacy responses;
- privacy manifest;
- Required Reason APIs;
- data deletion;
- no ATT;
- location purpose strings;
- photo picker purpose se necessario.

## 46.2 Accessibilità

- Nutrition Labels per iPhone/iPad;
- accessibility URL;
- audit documentato;
- nessun claim non verificato.

## 46.3 Commerce

- IAP metadata IT/EN;
- trial;
- renewal text;
- Family Sharing;
- grace period;
- restore/manage subscription;
- terms/privacy links;
- price transparency;
- Lifetime scope.

## 46.4 Legale/territori

- age rating;
- export compliance encryption; se si usa soltanto la crittografia fornita dal sistema operativo, dichiarare correttamente l'esenzione e verificare se non serve documentazione aggiuntiva;
- EU DSA trader status;
- indirizzo/email/telefono commerciali se richiesti;
- tax/banking agreements;
- EULA standard;
- category;
- availability.

## 46.5 Technical submission

- SDK/toolchain richiesti al momento;
- screenshots;
- App Preview;
- entitlement corretti;
- CloudKit schema production;
- App Groups;
- Universal Link AASA;
- widget/intents metadata;
- StoreKit config production;
- no Dev tools;
- no private APIs;
- no placeholder content.

## 46.6 App Review notes

Devono spiegare:

- niente account;
- iCloud privato;
- come provare Free;
- come provare Linked Routines;
- come provare location senza attendere troppo;
- fallback;
- acquisti;
- Lifetime;
- perché le notifiche sono locali;
- accessibilità;
- contatti supporto.

---

# 47. Requirement traceability baseline

La matrice completa deve essere mantenuta in un file operativo. Questa baseline definisce i requisiti più critici.

| ID | Requisito | UI | Dominio/Dati | Integrazione | Test minimo | Fase/versione | Milestone primaria | Epica primaria |
|---|---|---|---|---|---|---|---|---|
| RTY-001 | Registrare evento una volta e propagare | Oggi/Dettaglio | Event + Link Engine | Widget/Intent | unit + UI | 0.3 | M03 | E06 |
| RTY-002 | Obiettivo X volte/periodo | Oggi/Routine | GoalRule | Notification | unit timezone | 0.2 | M02 | E04 |
| RTY-003 | Dopo ultima esecuzione | Oggi/Routine | FrequencyRule | Calendar notif | DST/month | 0.2 | M02 | E04 |
| RTY-004 | Giorni stabiliti | Routine | ScheduledOccurrence | Calendar notif | missed occurrence | 0.2 | M02 | E04 |
| RTY-005 | Evento/durata/quantità | Creation/Log | MeasurementRule | Intent/widget | parameterized | 0.2 | M02 | E04 |
| RTY-006 | Usage OR time | Creation/Detail | ThresholdRule | Scheduler | boundary tests | 0.2 | M02 | E04 |
| RTY-007 | Soglia genera follow-up | Oggi | FollowUpPolicy | Notification | dedup | 0.3 | M03 | E06 |
| RTY-008 | Follow-up completa/reset | Oggi | Cycle Engine | Sync | multi-device | 0.3 | M03 | E06 |
| RTY-009 | Right-time location reminder | Creation/Oggi | ReminderPolicy | Core Location/UN | fallback/dedup | 0.5 | M06 | E12 |
| RTY-010 | Correzione retroattiva | History | EventRevision | CloudKit | recalculation | 0.3 | M03 | E06 |
| RTY-011 | Undo | Snackbar/sheet | Reversal event | — | action tests | 0.3 | M03 | E06 |
| RTY-012 | Pause/archive/delete | Detail/Profile | State policy/tombstone | CloudKit | restore | 0.4 | M04 | E10 |
| RTY-013 | Recently deleted 30d | Profile | Tombstone retention | CloudKit | expiry/restore | 0.4 | M04 | E10 |
| RTY-014 | Calm View selettiva | Oggi | Today Projection | Widget | relevance tests | 0.4 | M04 | E09 |
| RTY-015 | Riepilogo conseguenze | Bottom sheet | Applied effects | Haptics | accessibility/UI | 0.4 | M04 | E09 |
| RTY-016 | Unified creation | Creation | Builders/presets | TipKit | usability | 0.4 | M04 | E08 |
| RTY-017 | 12 Kits | Esplora | Kit definitions | StoreKit gate | install tests | 0.5 | M05 | E11 |
| RTY-018 | Analisi evidence-gated | Analisi | Insight rules | Swift Charts | statistical guard | 0.6 | M07 | E15 |
| RTY-019 | Search globale | Search | local index | search tab | typo/synonym | 0.6 | M07 | E16 |
| RTY-020 | Profilo locale | Profile | LocalProfile | iCloud | migration | 0.5 | M06 | E14 |
| RTY-021 | iCloud seamless | Profile/all | Repositories/events | CloudKit | offline/conflict | 0.5 | M06 | E14 |
| RTY-022 | Primary reminder device | Profile | Device policy | UN/CloudKit | duplicate tests | 0.5 | M06 | E12 |
| RTY-023 | Widgets | System | projections | WidgetKit | snapshot/action | 0.5 | M06 | E13 |
| RTY-024 | App Intents | System | use cases | AppIntents | invocation | 0.5 | M06 | E13 |
| RTY-025 | Universal Links | Router | typed route | Associated Domains | installed/web | 0.5 | M06 | E13 |
| RTY-026 | Free limits | Paywall | Limit policy | StoreKit | matrix | 0.6 | M08 | E17 |
| RTY-027 | Plus Annual/Lifetime | Paywall/Profile | Entitlement | StoreKit 2 | sandbox | 0.6 | M08 | E17 |
| RTY-028 | Protected downgrade | Profile | Entitlement/activation | StoreKit | transition | 0.6 | M08 | E17 |
| RTY-029 | IT/EN complete | All | string catalogs | App Store | snapshot/manual | 0.7 | M09 | E19 |
| RTY-030 | Accessibility gate | All | accessible models | iOS accessibility | matrix | 0.7 | M09 | E19 |
| RTY-031 | No third-party telemetry | All | Null analytics | Privacy manifest | binary audit | 0.8 | M10 | E20 |
| RTY-032 | CSV export | Profile | event serialization | Share sheet | large data | 0.5 | M06 | E14 |
| RTY-033 | Complete data deletion | Profile | delete/tombstone | CloudKit | multi-device | 0.5 | M06 | E14 |
| RTY-034 | Consistency repair | Dev/automatic | Consistency Engine | Background | corruption tests | 0.2 | M02 | E04 |
| RTY-035 | App Store launch | Store | release assets | ASC/TestFlight | checklist | 1.0 | M12 | E22 |

La fase indica quando il requisito raggiunge la propria milestone primaria; le verifiche
trasversali e di release restano obbligatorie nelle milestone successive. Ogni requisito
deve avere owner, attività/PR, specifica e stato aggiornati.

---

# 48. Definition of Done per milestone

## 48.1 M01 — Foundation

- repo, CI e Xcode compilano;
- Swift 6 strict concurrency;
- Dev/Public config;
- documentazione base;
- SwiftUI UI Foundation e preview matrix;
- spike report e relativi esiti dei Technical Gate;
- no secrets;
- ADR baseline.

## 48.2 M02 — Core Routine Engine

- quattro archetipi rappresentabili;
- invarianti testate;
- event revisions;
- projections;
- deterministic replay;
- repository adapter e persistenza locale offline;
- schema locale V1 versionato e migrazione baseline;
- 100k dataset baseline;
- no UI dependency.

## 48.3 M03 — Vertical Slice

- flusso end-to-end su device;
- offline;
- undo/correction;
- follow-up;
- reminder/fallback tramite adapter testabili, senza dipendere dai trigger di sistema completi;
- accessibility base;
- screenshot/video di evidenza;
- nessun hardcode del caso Palestra nel dominio.

## 48.4 M04 — Today & Routine

- Calm View;
- list/detail;
- creation;
- pause/archive/delete;
- IT/EN;
- light/dark;
- max text;
- UI tests.

## 48.5 M05 — Explore & Kits

- 12 schede editoriali;
- 4 Free/8 Plus;
- add/configure;
- independent copies;
- search metadata;
- all Kit acceptance tests.

## 48.6 M06 — System Integrations

- notifications;
- location;
- primary device;
- widgets;
- App Intents;
- Universal Links;
- background;
- permission fallbacks;
- `DG-DOMAIN` chiuso e Universal Links verificati sul dominio definitivo;
- local profile e controlli dei dati;
- sincronizzazione CloudKit Development, conflitti e recovery;
- CSV e cancellazione completa verificati.

## 48.7 M07 — Insights & Search

- evidence gates;
- no causal overclaim;
- accessible charts;
- local search;
- filters/synonyms;
- performance.

## 48.8 M08 — Commerce & Release Foundations

- Free limits;
- Annual/Lifetime;
- trial/grace/family;
- downgrade;
- paywall;
- legal copy;
- sandbox suite;
- support site e pagine legali/accessibilità baseline IT/EN;
- metadata e checklist App Store baseline.

## 48.9 M09 — Accessibility & Localization

- accessibility matrix pass;
- Nutrition Label evidence;
- IT/EN complete;
- pseudolocalization;
- iPad;
- support/legal pages accessibili e localizzate.

## 48.10 M10 — Alpha

- no Critical data bugs;
- internal flows;
- `DG-DEVELOPER-IDENTITY` chiuso;
- security/privacy audits;
- performance baseline;
- runbooks draft.

## 48.11 M11 — Beta

- beta metrics;
- RC stability;
- App Store assets;
- legal complete;
- CloudKit production;
- review evidence;
- support ready;
- `DG-TRADEMARK`, `DG-ICON` e `DG-LAUNCH` chiusi.

## 48.12 M12 — App Store 1.0

- all release gates;
- submission e App Review completate;
- manual release;
- monitoring and support;
- controlled launch;
- 1.0.1 contingency.

---

# 49. Backlog iniziale per epiche

## E01 — Repository & Governance

- create repo;
- README/copyright/security;
- AGENTS/CLAUDE;
- branch protection;
- CodeQL;
- docs structure;
- decision register.

## E02 — Apple-native UI Direction

- baseline Human Interface Guidelines e componenti Apple nativi;
- token semantici definiti;
- navigazione iPhone/iPad definita;
- flusso Oggi definito;
- flusso di creazione definito;
- scenario e criteri di accettazione della vertical slice;
- direzioni e criteri dell'esplorazione icona.

## E03 — Xcode & SwiftUI Foundation

- project/targets;
- Dev/Public bundles con identificativi provvisori finché DG-DEVELOPER-IDENTITY è aperto;
- xcconfig;
- SPM local packages;
- CI;
- feature flags;
- fixture system;
- Asset Catalog e token semantici;
- componenti e schermate SwiftUI con `#Preview`;
- preview matrix iPhone/iPad, Light/Dark e Dynamic Type;
- vertical slice interattiva con fixture locali.

## E04 — Domain Engine

- IDs/Clock/Calendar;
- routine models;
- event store;
- rule engine;
- cycle engine;
- links;
- follow-ups;
- revisions/tombstones;
- projections;
- consistency.

## E05 — Local Persistence Foundation

- SwiftData models;
- schema locale V1 versionato;
- repository adapter;
- persistenza condivisa con App Group;
- letture e scritture offline;
- migrazioni locali;
- stress del database locale.

## E06 — Vertical Slice Integration

- routine sorgente e routine collegata su dominio e persistenza locale reali;
- soglia, follow-up e reminder contestuale con fallback tramite adapter testabili;
- completamento, reset e cronologia;
- riepilogo delle conseguenze, esclusione del singolo effetto e annullamento;
- correzione retroattiva e ricostruzione deterministica;
- funzionamento offline e stato di sincronizzazione pendente simulato;
- verifica su device dei criteri `E02-VS-01`–`E02-VS-13`;
- nessuna pretesa di completare CloudKit, geofencing o notifiche di sistema, che appartengono a `M06`;
- nessun hardcode del caso Palestra nel dominio.

## E07 — App Shell

- TabView;
- search role;
- NavigationStack per tab;
- Profile button;
- routing;
- sheets;
- deep links.

## E08 — Creation

- presets;
- rapid default;
- progressive steps;
- natural summary;
- validation;
- Kit entry.

## E09 — Today

- projection;
- sections;
- rows;
- actions;
- effect summary;
- pins/relevant goals;
- empty state.

## E10 — Routines

- list/areas/filters;
- detail;
- history;
- edit;
- pause/archive/delete;
- recently deleted.

## E11 — Explore & Kits

- catalog;
- 12 specs;
- cards;
- detail preview;
- add/configure;
- Free/Plus gate.

## E12 — Notifications & Location

- permission flow;
- scheduler;
- categories;
- actions;
- location triggers;
- fallback/dedup;
- primary device;
- badge.

## E13 — System Surfaces

- widgets;
- lock screen;
- intents;
- Spotlight;
- control/action button;
- universal links;
- background.

## E14 — Profile, Data & iCloud

- local profile;
- appearance;
- locations;
- CloudKit adapter e container Development;
- sincronizzazione multi-device;
- conflitti e recovery;
- iCloud status;
- CSV;
- delete data;
- support.

## E15 — Analysis

- metrics;
- insights;
- thresholds;
- charts;
- history filters;
- empty/insufficient data.

## E16 — Search

- index;
- normalized terms;
- synonyms;
- recent;
- filters;
- results/actions.

## E17 — Commerce

- StoreKit config;
- entitlements;
- Free limits;
- paywall;
- trial/grace/family;
- lifetime;
- downgrade;
- Beta Plus.

## E18 — Support, Legal & App Store Foundations

- struttura del sito di supporto;
- Privacy Policy, Termini, Termini Plus e pagina Accessibilità baseline IT/EN;
- metadata App Store baseline;
- checklist di submission e piano dell'evidence package;
- processo di supporto e ownership dei contenuti;
- nessun asset finale derivato da prototipi.

## E19 — Accessibility/Localization

- string catalogs;
- IT/EN;
- VoiceOver;
- Dynamic Type;
- contrast/motion;
- iPad keyboard/pointer;
- audit.

## E20 — Alpha

- TestFlight;
- flussi interni e raccolta strutturata del feedback;
- chiusura di `DG-DEVELOPER-IDENTITY`;
- audit privacy, sicurezza e performance;
- verifica dei runbook;
- triage e stabilizzazione senza nuove feature.

## E21 — Beta

- beta privata e ampliata;
- metriche/questionari;
- StoreKit Sandbox;
- schema CloudKit production;
- evidence package per App Review;
- revisione legale finale e supporto pronto;
- screenshot, video e Custom Product Pages dalla release candidate reale;
- finalizzazione asset e release candidate;
- chiusura di `DG-TRADEMARK`, `DG-ICON` e `DG-LAUNCH`.

## E22 — App Store Release

- submission e ciclo App Review;
- rilascio manuale e controlled launch;
- supporto e piano di contingenza `1.0.1`.

---

# 50. Decision Gate aperti

## DG-DOMAIN

- registrare `routally.com`;
- configurare email e DNS;
- eventuale `routally.app` difensivo;
- prenotare gli identificativi social essenziali;
- definire owner e recovery;
- chiudere il gate prima di `M06`, perché gli Universal Links richiedono il dominio definitivo.

## DG-TRADEMARK

- ricerca formale Routally e Temisfera;
- UIBM/EUIPO/WIPO;
- valutare deposito.

## DG-ICON

- scelta dopo esplorazione SVG, Icon Composer e user test.

## DG-DEVELOPER-IDENTITY

Fase 0.8:

- account individuale oppure entità Temisfera;
- eventuale publisher reale o account rental valutati soltanto con due diligence e contratto; baseline non raccomandata;
- dati DSA trader e indirizzo pubblico;
- Apple organization/D‑U‑N‑S, sito ed email di dominio;
- cessione o licenza IP;
- impatto su Bundle ID, CloudKit, App Groups, StoreKit, Xcode Cloud, pagamenti e trasferimento;
- riservare il Bundle ID finale soltanto dopo la chiusura coerente di questo gate;
- developer name scelto prima del primo record App Store.

## DG-LAUNCH

- data e preordine dopo RC 0.9.

## DG-CLOUD-PRICING

- modello 2.0, backend e prezzi.

## DG-FUTURE-ANALYTICS

- soltanto se strumenti Apple e ricerca qualitativa insufficienti;
- nuova decisione privacy e App Store.

---

# 51. Decisioni esplicitamente sostituite

Per evitare che documenti o chat precedenti vengano seguiti per errore:

- **Superseded:** tre percorsi separati «rapida/guidata/Kit».  
  **Finale:** un flusso rapido di default, progressivo; Kit in Esplora.

- **Superseded:** `+` in Oggi e Routine, pulsante centrale inferiore, FAB o `+` dentro la tab bar.  
  **Finale:** `+` soltanto nella navigation bar della tab Routine.

- **Superseded:** barra di configurazione permanente con molte categorie o sezione «Avanzate».  
  **Finale:** flusso progressivo con preset e quattro schede modificabili.

- **Superseded:** ricerca in alto.  
  **Finale:** ricerca globale separata nella tab bar.

- **Superseded:** tab `Kit`.  
  **Finale:** tab `Esplora`.

- **Superseded:** traduzione Insights = Ritmo/Andamento.  
  **Finale:** Analisi.

- **Superseded:** backup `.routally` manuale.  
  **Finale:** iCloud seamless e solo export CSV.

- **Superseded:** `routally.app` come dominio principale.  
  **Finale:** `routally.com`; `.app` soltanto difensivo facoltativo.

- **Superseded:** repository inizialmente privato o GitHub come community.  
  **Finale:** repository pubblico dal primo commit, personale, Issues/Discussions non usate.

- **Superseded:** Codex implementatore e Claude revisore.  
  **Finale:** agenti alternativi, mai contemporanei.

- **Superseded:** prezzo Lifetime rivalutabile in 1.X.  
  **Finale:** prezzi stabili fino alla 2.0.

- **Superseded:** tre app Dev/TestFlight/App Store.  
  **Finale:** una variante Dev e un unico prodotto Routally per TestFlight/App Store.

- **Superseded:** riunione cliente/follow-up come caso rappresentativo.  
  **Finale:** escluso perché il vantaggio è troppo debole.

- **Superseded:** utilizzi della valigia.  
  **Finale:** Viaggi usa follow-up utili, non conta la valigia.

---

# 52. Quality bar finale

Routally 1.0 è pronta soltanto quando:

1. il valore distintivo funziona end-to-end;
2. gli utenti comprendono i quattro archetipi;
3. il motore è deterministico e ricostruibile;
4. nessun errore può cancellare o duplicare silenziosamente dati;
5. iCloud e offline sono affidabili;
6. le notifiche hanno fallback;
7. l'app è accessibile;
8. IT/EN sono completi;
9. Free dimostra davvero il prodotto;
10. Plus è trasparente;
11. l'interfaccia sembra Apple-native;
12. la registrazione è più semplice del carico mentale che elimina;
13. la Calm View evita ansia e debito;
14. i Kit sono utili e non ossessivi;
15. TestFlight, supporto, sito e App Store sono pronti;
16. non esistono feature Dev o incomplete nella build;
17. il Product Owner approva esperienza, materiali e release.

---

# 53. Riferimenti esterni principali

Le implementazioni devono essere verificate contro la documentazione Apple corrente al momento dello sviluppo e della submission. I riferimenti sotto sono una baseline, non sostituiscono il controllo della toolchain installata.

## Apple design e piattaforma

- Apple Human Interface Guidelines — Search fields: https://developer.apple.com/design/human-interface-guidelines/search-fields
- WWDC25 — Build a SwiftUI app with the new design: https://developer.apple.com/videos/play/wwdc2025/323/
- Apple Design Resources: https://developer.apple.com/design/resources/
- Icon Composer: https://developer.apple.com/icon-composer/

## SwiftData e CloudKit

- ModelConfiguration: https://developer.apple.com/documentation/swiftdata/modelconfiguration
- VersionedSchema: https://developer.apple.com/documentation/swiftdata/versionedschema
- SchemaMigrationPlan: https://developer.apple.com/documentation/swiftdata/schemamigrationplan

## StoreKit e App Store Connect

- Transaction.currentEntitlements: https://developer.apple.com/documentation/storekit/transaction/currententitlements
- Billing Grace Period: https://developer.apple.com/help/app-store-connect/manage-subscriptions/enable-billing-grace-period-for-auto-renewable-subscriptions/
- Family Sharing for IAP: https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/turn-on-family-sharing-for-in-app-purchases
- TestFlight feedback: https://developer.apple.com/help/app-store-connect/test-a-beta-version/view-tester-feedback
- Accessibility Nutrition Labels: https://developer.apple.com/help/app-store-connect/manage-app-accessibility/overview-of-accessibility-nutrition-labels

## Notifiche e background

- User Notifications: https://developer.apple.com/documentation/usernotifications
- BackgroundTasks: https://developer.apple.com/documentation/backgroundtasks
- App Intents: https://developer.apple.com/documentation/appintents
- Universal Links: https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content

## Benchmark di prodotto

- DoneAgo: https://doneago.com/
- KountEm App Store: https://apps.apple.com/app/id6771548628
- Tody: https://todyapp.com/
- SparesBro: https://sparesbro.app/
- Counter: https://counterautomate.com/
- Habit Nova: https://habitnova.com/about
- Habtik: https://www.habtik.com/
- ChainRoutine: https://apps.apple.com/app/id6757709123
- Structured: https://apps.apple.com/app/id1499198946

---

# 54. Approvazione della baseline

Con l'approvazione di questo documento:

- la fase di definizione generale è chiusa;
- le decisioni non sospese sono vincolanti;
- il lavoro successivo è Xcode, SwiftUI UI Foundation e technical spike;
- Codex o Claude Code possono decomporre il piano in documenti e attività senza reinterpretarlo;
- le nuove decisioni vengono registrate tramite change control;
- la 1.0 rimane l'obiettivo principale e la roadmap futura non ne deve compromettere qualità e semplicità.

**Fine del Master Plan.**

---

## Nota di audit 1.1

Questa baseline è stata ricontrollata contro l'intera conversazione di definizione prima dell'handoff a Codex. Le integrazioni 1.1 hanno recuperato dettagli su naming, benchmark, creazione per archetipi, strumenti di design, governance del primo commit, continuità CloudKit/TestFlight, Kit Free/Plus, App Store, identità dello sviluppatore, use-case backlog e runbook. Le idee non approvate sono marcate come ipotesi o Decision Gate, non come scope.

## Nota di audit 1.2

Con approvazione del Product Owner del 6 agosto 2026, Routally adotta un processo SwiftUI-first: specifiche e criteri di accettazione restano documentali, mentre interfaccia, componenti e prototipi diventano artefatti eseguibili in Xcode Previews, Simulator e dispositivi reali. Icon Composer gestisce le varianti dell'icona e gli asset App Store derivano esclusivamente dalla release candidate reale.

## Nota di audit 1.3

Con approvazione del Product Owner del 14 agosto 2026, la baseline recepisce una revisione
critica del piano stesso. Le modifiche non ampliano lo scope della 1.0: chiudono
contraddizioni interne, rendono verificabili regole finora descrittive e anticipano
decisioni che sarebbero altrimenti maturate sotto pressione.

| Ambito | Modifica | Sezioni |
|---|---|---|
| Limiti Free | 10 routine e 5 collegamenti: con 5 e 2 i 4 Kit introduttivi promessi non erano installabili | 20.1, 31.1, 31.1.1, 31.1.2, 43 |
| Downgrade | Le conseguenze sospese dalla pausa diventano visibili invece di interrompersi in silenzio | 31.8, 31.8.1, 31.9 |
| Lettura del piano | Lettura selettiva per sezioni invece della lettura integrale obbligatoria | 0.6, `agent-workflow.md` |
| Governance agenti | Il gate di review è un controllo di CI, non un ruolo di agente | 27.2, 27.3, 28.3.1, ADR-0005 |
| Motore | Nuovo spike TG-RECALC sul ricalcolo retroattivo deterministico, in 0.2 | 37.1, 40.2, 43 |
| Scope | Linea di galleggiamento pre-approvata con ordine di sacrificio e funzioni non sacrificabili | 37.5, 43 |
| Metriche | Le soglie della beta privata sono dichiarate qualitative e non statistiche | 34.1 |
| Calm View | La rilevanza di «Questa settimana» diventa una regola deterministica e testabile | 9.2 |

Restano invariati posizionamento, perimetro funzionale della 1.0, prezzi, architettura,
privacy e roadmap.

## Nota di audit 1.4

Con approvazione del Product Owner del 14 agosto 2026, versioni interne, milestone, epiche
e gate adottano una gerarchia operativa univoca. Le milestone usano identificativi `M01`–
`M12`, le epiche `E01`–`E22` e ogni epica appartiene a una sola milestone primaria. La
Vertical Slice diventa una milestone e un'epica di integrazione esplicite; Alpha, Beta e
App Store diventano epiche distinte. La persistenza locale viene separata dalle
integrazioni iCloud e la preparazione di supporto, legale e App Store riceve un'epica
propria nella 0.6. La modifica non amplia lo scope funzionale della 1.0.
La coerenza della gerarchia e della tracciabilità è verificata in modo eseguibile da
`scripts/check-roadmap-hierarchy.mjs` e dal workflow del gate Codex.
