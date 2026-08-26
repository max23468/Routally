# Routally — Master Plan

- **Documento canonico:** `docs/MASTER_PLAN.md`
- **Stato:** approvato per l'avvio della progettazione e dello sviluppo
- **Data:** 23 agosto 2026
- **Owner di prodotto:** Matteo
- **Obiettivo primario:** pubblicare Routally 1.0 su App Store come prodotto completo, affidabile, completamente gratuito e privo di limiti commerciali, mantenendo una roadmap esplicita per un Plus additivo nella 1.X e per le versioni 2.X successive.

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
- [16. Registro eventi, correzione e consistenza](#16-registro-eventi-correzione-e-consistenza)
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
- [42. Checklist operativa](#42-checklist-operativa)
- [43. Risk register iniziale](#43-risk-register-iniziale)
- [44. Ownership di account, asset e credenziali](#44-ownership-di-account-asset-e-credenziali)
- [45. Budget e sostenibilità operativa](#45-budget-e-sostenibilità-operativa)
- [46. Compliance e checklist App Store](#46-compliance-e-checklist-app-store)
- [47. Tracciabilità operativa](#47-tracciabilità-operativa)
- [48. Definition of Done per milestone](#48-definition-of-done-per-milestone)
- [49. Backlog per epiche](#49-backlog-per-epiche)
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
- modificare la garanzia del core gratuito, il Premium Value Gate, il prezzo di Plus o i diritti già acquistati;
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
- coerenza con il core gratuito e, dalla 1.X, con eventuali entitlement Plus;
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
altre sezioni: TG-RECALC precede le feature che dipendono dal ricalcolo, TG-DATA precede lo schema e TG-STOREKIT precede soltanto l’eventuale commercio della 1.X, dopo il checkpoint di approvazione del bundle previsto da `DG-PLUS-LAUNCH`. Per la 1.0 il gate StoreKit è esplicitamente inattivo. Leggere la sezione 40 solo quando si lavora sulla roadmap significherebbe scoprire un vincolo dopo averlo violato.

La matrice indica le sezioni che descrivono l'oggetto dell'intervento, non l'insieme
completo di ciò che lo vincola. Le dimensioni del principio di completezza della sezione
0.4 — garanzia del core gratuito e, quando applicabile, comportamento Plus, accessibilità, localizzazione, privacy, persistenza,
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

La 1.0 dovrà essere un prodotto completo e pubblicabile, non un MVP dimostrativo. Comprenderà:

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
- lancio 1.0 completamente gratuito, senza limiti commerciali, paywall o acquisti in-app;
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
- il costo di costruzione Apple-native è compatibile con una validazione mirata;
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

Accenti curati disponibili a tutti nella 1.0:

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

La selezione visuale preliminare è conclusa, ma `DG-ICON` resta aperto. Le attività sono
collocate nella roadmap in base alla maturità richiesta dal prodotto:

- `E03` / `M01` Foundation prepara la candidata tecnica: livelli autonomi importati in
  Icon Composer su macOS Tahoe 26.4 o successivo, verifica di Default, Dark, Mono, Clear,
  Tinted e Liquid Glass, file `.icon` versionati e collegati ai target pubblico e Dev;
- `E20` / `M10` Alpha, dopo il feature freeze, verifica la candidata nelle superfici reali
  dell'app su iPhone e iPad fisici, con attenzione a 29 e 40 pt, ed esegue lo user test
  cieco fra A1 Lavender 50, A1 Amber 50 e T1;
- `E21` / `M11` Beta completa la verifica figurativa formale oppure registra
  l'accettazione esplicita del rischio residuo, raccoglie le evidenze finali e sottopone la
  candidata alla ratifica del Product Owner.

**Decision Gate DG-ICON:** resta aperto e blocca il file definitivo e i materiali App Store
finché tutte le evidenze del `DESIGN/icon/decision-record.md` non sono complete e approvate
in `E21`; non anticipa prove su dispositivi reali o user test durante la Foundation.

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
- uso completo e senza limiti commerciali di routine, collegamenti, Kit, cronologia, luoghi e superfici di sistema;
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
- accento Routally;
- feedback aptico;
- animazioni;
- link alle impostazioni native rilevanti.

### Dati e servizio

- stato iCloud;
- esportazione CSV;
- Eliminati di recente;
- eliminazione completa dei dati;
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
- requisiti tecnici o autorizzazioni eventualmente necessarie.

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

# 16. Registro eventi, correzione e consistenza

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

## 16.2 Stato derivato

Un reducer deterministico deriva dagli eventi lo stato necessario a routine, Oggi,
follow-up, Analisi, ricerca e widget. Nella baseline 1.0 lo stato viene calcolato su lettura
o aggiornato nella stessa transazione che registra l'evento.

Cache o indici persistenti si introducono soltanto per una query misurata come lenta e
restano eliminabili senza perdita di dati. Non esistono nella baseline un sottosistema di
proiezioni, una coda di aggiornamento o una gerarchia di snapshot da riconciliare.

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

## 16.5 Controlli di integrità

Non esiste un `Consistency Engine` autonomo. Scrittura, modifica e sincronizzazione
validano gli invarianti nella stessa operazione; retry e deduplica usano gli UUID degli
eventi. Se una cache opzionale è incoerente viene scartata e ricalcolata dal reducer.

La build Dev può validare gli invarianti e generare fixture realistiche. Simulatori di
corruzione, dashboard diagnostiche e procedure di repair dedicate si aggiungono soltanto
dopo un guasto riproducibile che i normali test non coprono.

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
9. lo stato derivato è riproducibile dagli eventi canonici;
10. l'ordine di consegna CloudKit non cambia il risultato finale;
11. retry e riconciliazioni sono idempotenti;
12. un follow-up completato su un dispositivo non viene completato due volte altrove;
13. il fallback temporale e il trigger geografico non generano due follow-up;
14. il core della 1.0 non dipende da entitlement commerciali né da limiti quantitativi;
15. una routine archiviata non riceve aggiornamenti automatici;
16. una routine in pausa non viene incrementata da link, salvo registrazione manuale esplicita della routine stessa secondo le regole approvate;
17. ogni modifica che altera conseguenze conserva una traccia revisionale;
18. nessuna cache o indice può diventare fonte di verità.

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

Nella 1.0 non esistono acquisti o entitlement. Dalla 1.X l’eliminazione dei dati non modifica eventuali diritti Plus acquistati.

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
- aggiornare stato derivato e indici necessari;
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
- disponibilità nella versione minima supportata;
- microcopy IT/EN;
- avvertenze;
- versione;
- test di accettazione.

I Kit sono inclusi e versionati nell'app 1.0, non scaricati da server.

Tutti gli utenti possono esplorare, installare e configurare liberamente tutti i 12 Kit della 1.0. I Kit sono parte del core gratuito permanente: nessuno richiede Plus e nessuno consuma una quota commerciale di routine o collegamenti.

## 20.2 Kit introduttivi

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

## 20.3 Altri Kit inclusi nella 1.0

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
- fino a `M09`, identificativi App Group e CloudKit iniettati e validazioni locali su Simulator, senza creare asset Apple remoti; in `M10`, dopo `DG-DEVELOPER-IDENTITY`, preferibilmente un unico container iCloud Routally definitivo con ambienti CloudKit Development e Production separati, associato agli App ID necessari;
- schema versionato dalla prima release;
- `SchemaMigrationPlan` esplicito;
- un confine di persistenza sufficiente a testare il dominio senza SwiftData.

Architettura:

```text
SwiftUI
  ↓
Feature state / use case
  ↓
Domain engine
  ↓
Routally store
  ↓
SwiftData + CloudKit
```

## 21.3 Indipendenza dal framework

- i tipi di dominio non sono direttamente modelli SwiftData esposti alla UI;
- gli UUID sono indipendenti da `PersistentIdentifier`;
- CloudKit non viene chiamato dalla feature;
- il formato di esportazione non dipende da dettagli SwiftData.

La possibile 2.0 non impone adapter, repository sostituibili o compatibilità preventiva
alla 1.0. Una migrazione futura verrà progettata sui dati e sui requisiti reali di allora.

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
- eventuali indici locali motivati da misure;
- tombstone;
- device preference;

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

Non esiste un protocollo analytics vuoto: se una futura decisione autorizzerà analytics,
l'integrazione verrà progettata allora sui requisiti approvati.

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

- perdita o corruzione dati, inclusi sync incoerente, duplicati e riapparizione di eliminati;
- esposizione involontaria di note, luoghi o profilo tramite log e superfici di sistema;
- dalla 1.X, bypass o corruzione degli entitlement Plus dopo l’effettiva introduzione di StoreKit;
- input esterni non fidati, inclusi link, App Intents e file importati;
- repository e supply chain, inclusi secret e GitHub Actions.

Il threat model resta un controllo breve aggiornato quando cambia una superficie reale; non
richiede scenari, infrastrutture o contromisure per servizi che Routally non usa.

## 22.8 Principio del minimo privilegio

Capability 1.0:

- iCloud/CloudKit;
- App Groups;
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
│   └── Migration
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
- isolamento con actor dove esiste stato mutabile condiviso, senza creare un actor per ogni servizio in anticipo;
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

## 25.4 Confini dei servizi

Si introducono soltanto confini usati dall'app o necessari a test deterministici. La
baseline indicativa è:

```swift
protocol RoutallyStore: Sendable { ... }
protocol ReminderScheduling: Sendable { ... }
protocol LocationReminding: Sendable { ... }
protocol Clock: Sendable { ... }
```

Nella 1.0 non esiste un confine di entitlement. `EntitlementProviding` può essere introdotto
soltanto nella 1.X, dopo il checkpoint A di `DG-PLUS-LAUNCH`, se `TG-STOREKIT` dimostra
che serve un confine testabile.

`Clock` e calendario devono essere controllabili nei test. Non si crea un protocollo per
ogni modello, framework o possibile fornitore futuro; un nuovo confine richiede almeno due
implementazioni reali o un test che non può essere scritto in modo più semplice.

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

**Technical Gate TG-DATA:** uno spike locale deve verificare registro eventi, migrazioni,
contratto App Group/widget, convergenza offline e dataset di riferimento. La validazione
del servizio CloudKit Development su asset Apple definitivi è un criterio di accettazione
di integrazione rinviato a `M10`, dopo `DG-DEVELOPER-IDENTITY`, e non riapre il gate.

Se il gate fallisce per limiti dimostrati, il dominio e il contratto dello store restano
invariati e viene valutata una persistenza Apple-native alternativa, preferibilmente Core
Data + `NSPersistentCloudKitContainer`. Il fallback non modifica l'esperienza né autorizza
dipendenze esterne.

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
| CI/CD Apple | verifiche locali obbligatorie fino a `M09`; Xcode Cloud da `M10` |
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
- StoreKit config soltanto dopo il checkpoint A di `DG-PLUS-LAUNCH`; pubblicazione dopo il checkpoint B; fuori dalla baseline 1.0.

Regole:

- release solo con toolchain stabile;
- beta Apple soltanto in spike/branch dedicati;
- niente upgrade toolchain durante milestone critica senza necessità;
- upgrade seguito da build e regressione completa;
- Actions bloccate a versioni/commit affidabili;
- feature flag obsolete rimosse.

## 26.7 Ripartizione CI

Fino a `M09`, prima dell'iscrizione all'Apple Developer Program, il gate Apple è eseguito
su un Mac controllato con la toolchain bloccata: `swift-format`, build degli scheme
`Routally Dev` e `Routally`, suite `Routally Tests` sul Simulator canonico e registrazione
dell'esito nella pull request. Queste verifiche locali sono obbligatorie prima del merge.

Da `M10`, dopo `DG-DEVELOPER-IDENTITY` e l'iscrizione, **Xcode Cloud** diventa la fonte
primaria per build Apple, test, archivi e TestFlight.

**GitHub Actions** resta complementare e limitata a:

- `swift-format`;
- documentazione e file di configurazione;
- CodeQL e controlli di sicurezza;
- verifiche che non richiedono firma, Simulator o infrastruttura Apple completa.

Da `M10` non duplicare inutilmente la pipeline Xcode Cloud; prima di allora GitHub Actions
non sostituisce le verifiche Apple locali obbligatorie.

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

Un nuovo commit invalida immediatamente lo status precedente e termina il relativo job;
l'attesa riparte soltanto con la nuova richiesta di review. Il polling usa intervalli brevi
e un timeout massimo di un'ora. I finding P2/P3 restano registrati ma non richiedono la
risoluzione della conversazione per il merge, mentre P0/P1 continuano a bloccare.

### 28.3.2 Gate di pubblicazione proporzionato

Ogni PR produce lo status richiesto `publication-gate` sull'HEAD esatto. Il workflow parte sempre e
classifica il diff come documentazione ordinaria, documentazione canonica, governance,
Swift, UI oppure release/sicurezza. I job applicabili vengono eseguiti in parallelo:

- integrità del diff per ogni modifica;
- matrice, roadmap e test degli script per documentazione canonica e governance;
- `swift-format`, build e test per codice o configurazioni applicative;
- CodeQL nella PR per Swift e configurazioni di progetto;
- controlli degli asset ed evidenza visuale dichiarata per UI.

Un job non applicabile viene saltato, ma il gate aggregato restituisce sempre un esito. Il
comando locale `node scripts/verify-change.mjs --base origin/main` usa la stessa
classificazione della CI. Le prove manuali, inclusa l'approvazione visuale quando prevista,
restano esplicite e non vengono sostituite da un successo automatico.

### 28.3.3 Auto-merge e rilettura finale

Quando `codex-review` e `publication-gate` sono in corso si abilita lo squash auto-merge.
GitHub integra la PR soltanto dopo il successo dei gate richiesti. Dopo il merge, il tree
ottenuto applicando l'HEAD validato della PR al parent del commit pubblicato deve coincidere
con il tree del commit squash; `scripts/verify-merge-tree.mjs` rende eseguibile il controllo.

Se i tree coincidono, i gate pre-merge costituiscono evidenza del contenuto pubblicato e
non vengono ripetuti su `main`. CodeQL resta anche pianificato settimanalmente come monitor
asincrono, senza prolungare una pubblicazione già validata. La rilettura finale continua a
verificare PR, SHA, `main`, `origin/main`, branch, worktree e stash.

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
│   ├── testing-strategy.md
│   └── agent-workflow.md
├── RELEASE/
│   ├── app-store.md
│   ├── privacy-checklist.md
│   ├── testflight.md
│   ├── review-evidence.md
│   └── release-checklist.md
├── OPERATIONS.md
└── ADR/
    ├── 0001-ios-26-minimum.md
    ├── 0002-deterministic-event-journal.md
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
- fino a `M09`, configurazione CloudKit/App Group iniettata e verifiche locali su Simulator, senza asset Apple remoti; in `M10`, dopo il gate identità, ambiente Development del container definitivo;
- strumenti diagnostici;
- icona DEV;
- mai pubblicata.

### Routally

Unica identità definitiva:

- stesso bundle ID per TestFlight e App Store;
- un record App Store Connect;
- CloudKit Production dello stesso container;
- dati TestFlight preservati nella versione App Store;
- nessun prodotto o configurazione StoreKit nella 1.0; gli eventuali acquisti 1.X usano lo stesso record App Store dopo la chiusura dei relativi gate.

Gli asset Apple definitivi della 1.0 — Bundle ID, App Groups, container CloudKit e record
App Store — vengono creati soltanto dopo `DG-DEVELOPER-IDENTITY`, in `M10`. Prima di
allora lo sviluppo usa configurazioni locali e identificativi iniettati, senza richiedere
l'iscrizione a pagamento all'Apple Developer Program. La creazione non pubblica degli
eventuali prodotti StoreKit della 1.X richiede il checkpoint A di `DG-PLUS-LAUNCH`; la
pubblicazione richiede il checkpoint B.

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

Si attiva in `M10`, dopo `DG-DEVELOPER-IDENTITY` e l'iscrizione all'Apple Developer
Program. Fino a `M09` si applica il gate locale della sezione 26.7.

Workflow da `M10`:

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
- UnrestrictedLibrary;
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

## 31.1 Lancio 1.0: gratuito, completo e senza limiti commerciali

Routally 1.0 viene distribuita gratuitamente. Non contiene acquisti in-app, abbonamenti,
trial, paywall, entitlement commerciali, pubblicità o vendita di dati.

Tutto lo scope della sezione 6 è disponibile senza quote commerciali, inclusi:

- routine, collegamenti e Linked Routines;
- tutti i modelli temporali, obiettivi, utilizzi, durata e quantità;
- Smart Follow-ups, luoghi e fallback, nei soli limiti tecnici imposti da iOS;
- tutti i 12 Routine Kits della 1.0;
- cronologia, correzione retroattiva, Analisi e ricerca;
- widget, Lock Screen, App Intents, Siri, Spotlight, Centro di Controllo e tasto Azione;
- iCloud, esportazione CSV, accessibilità, localizzazione e personalizzazione previste;
- iPhone e iPad.

La 1.0 non distingue utenti Free e Plus. Non esistono limiti artificiali sul numero di
routine, collegamenti, Kit installati, luoghi salvati, widget configurati o periodo di
cronologia consultabile. Restano validi soltanto limiti tecnici, di affidabilità o di
piattaforma documentati e applicati allo stesso modo a tutti.

## 31.2 Garanzia permanente del core gratuito

Ogni funzione pubblicata nella 1.0 rimane gratuita per tutti gli utenti, presenti e
futuri. Restano gratuiti anche:

- correzioni di bug e vulnerabilità;
- manutenzione, compatibilità con nuovi sistemi e affidabilità;
- accessibilità e localizzazione;
- miglioramenti normali delle funzioni 1.0 che non costituiscono una nuova capacità
  autonoma;
- accesso ai dati creati con il core gratuito.

Non è consentito introdurre retroattivamente quote, nascondere cronologia, ridurre widget
o Kit, rendere a pagamento iCloud, correzione, Linked Routines o altre parti già incluse
nella 1.0. Una futura funzione Premium deve essere additiva e non può diventare necessaria
per continuare a usare correttamente il core.

Questa garanzia rende superfluo il grandfathering basato sulla data di installazione: il
confine è funzionale e vale allo stesso modo per vecchi e nuovi utenti.

## 31.3 Strategia di monetizzazione 1.X

La serie 1.X serve prima a validare attivazione, comprensione, retention e utilità reale.
Routally Plus viene introdotto soltanto quando esiste un insieme coerente di nuove
capacità per cui il pagamento sia giustificato.

Plus non vende maggiore quantità d’uso del core. Non può basarsi su routine illimitate,
più collegamenti, cronologia sbloccata o affidabilità migliore. Vende invece capacità
nuove che riducono ulteriormente il logging o rendono le routine sostanzialmente più
intelligenti.

Promessa candidata:

> **Routally Plus registra più cose automaticamente e rende le routine più intelligenti.**

## 31.4 Premium Value Gate

**Decision Gate `DG-PLUS-LAUNCH`.** Il gate usa due checkpoint ordinati, così la decisione
di prodotto precede lo spike tecnico e l’autorizzazione al lancio lo segue.

### Checkpoint A — Approvazione del bundle

Il Product Owner può approvare il bundle candidato quando:

1. almeno due capacità principali nuove e autonome sono pronte per una beta mirata;
2. il bundle ha una promessa unica e comprensibile, non una raccolta di rifiniture;
3. il valore è ricorrente nell’uso reale, non occasionale o puramente estetico;
4. beta e ricerca qualitativa mostrano bisogno, comprensione e disponibilità a pagare;
5. nessuna funzione della 1.0 viene sottratta, degradata o resa dipendente da Plus;
6. costo, prezzo una tantum e sostenibilità del perimetro locale sono documentati.

L’approvazione del checkpoint A non chiude il gate e non autorizza il lancio. Autorizza
soltanto `TG-STOREKIT`, la Commerce QA e, se necessario, la creazione non pubblica del
prodotto in App Store Connect.

### Checkpoint B — Autorizzazione al lancio

Il Product Owner chiude `DG-PLUS-LAUNCH` soltanto quando:

1. `TG-STOREKIT` è chiuso sul prodotto definitivo;
2. il bundle è release-complete, accessibile, localizzato IT/EN e verificato offline;
3. privacy, supporto, termini, metadata commerciali e Commerce QA sono completi;
4. prezzo, perimetro e diritti permanenti sono confermati un’ultima volta.

Colori, singoli Kit, qualche grafico o una sola integrazione minore non sono sufficienti
per superare il checkpoint A. Se manca una condizione di uno dei due checkpoint, la
monetizzazione viene rinviata e il gate resta aperto.

## 31.5 Bundle candidato di Routally Plus

Le capacità candidate, da validare senza automatica classificazione Premium, sono:

- automazione Apple Health con import controllabile degli allenamenti e propagazione alle
  routine collegate;
- app Apple Watch, complicazioni, Smart Stack e logging dal polso;
- Linked Routines avanzate con condizioni multiple, varianti, ramificazioni e catene
  guidate su più livelli;
- ritmo adattivo e insight azionabili, con suggerimenti confermati dall’utente.

Calendario avanzato, NFC, nuovi contesti, esportazioni evolute, personalizzazioni e Kit
aggiuntivi possono completare il bundle, ma non ne costituiscono da soli il motivo di
acquisto. La classificazione del bundle viene registrata al checkpoint A di `DG-PLUS-LAUNCH`; la pubblicazione resta subordinata al checkpoint B.

## 31.6 Prezzo e forma di acquisto nella 1.X

Il modello commerciale confermato, da validare tecnicamente dopo il checkpoint A e autorizzare al checkpoint B, è:

- **Routally Plus: 29,99 € una tantum**;
- nessun piano mensile o annuale nella 1.X;
- prodotto StoreKit non consumabile;
- nessun trial necessario, perché il core completo resta gratuito;
- Family Sharing soltanto se confermato da `TG-STOREKIT` e dai test App Store;
- prezzo locale mostrato e gestito esclusivamente da App Store.

Una variazione del prezzo o l’introduzione di un abbonamento nella 1.X richiede change
control esplicito. Dopo il checkpoint A il prodotto può essere creato in stato non
pubblico per `TG-STOREKIT` e Commerce QA; non viene reso acquistabile prima della chiusura
del checkpoint B.

## 31.7 Diritti dell’acquisto Plus

L’acquisto sblocca permanentemente le capacità Plus Apple-locali pubblicate nella 1.X e
la loro manutenzione, incluse le integrazioni Watch e Health eventualmente comprese nel
bundle definitivo. I diritti non scadono e non dipendono da un account Routally.

Non sono inclusi automaticamente servizi che generano costi ricorrenti, tra cui:

- account e backend Routally;
- sincronizzazione web o Android;
- spazi e routine condivisi tramite cloud Routally;
- servizi AI o altre elaborazioni server-side ricorrenti.

Questi servizi appartengono al modello cloud della 2.0. La loro introduzione non riduce i
diritti locali già acquistati.

## 31.8 Esperienza commerciale futura

La 1.0 non presenta alcun paywall o messaggio di upgrade. Dopo il lancio effettivo di
Plus, la proposta commerciale può comparire soltanto:

- nella pagina della nuova capacità;
- quando l’utente prova volontariamente a configurarla;
- nella pagina informativa Routally Plus.

Non compare nell’onboarding, non interrompe una registrazione o il completamento di una
routine e non usa notifiche ripetitive. Sono vietati timer artificiali, falsi prezzi
barrati, preselezioni ambigue e dark pattern. Il confine tra core gratuito e capacità
Plus, il prezzo una tantum, Family Sharing e il ripristino acquisti devono essere chiari.

## 31.9 StoreKit differito alla 1.X

La build pubblica 1.0 non include prodotti, configurazioni, superfici o capability
In-App Purchase. `TG-STOREKIT` è differito alla 1.X e viene eseguito dopo il checkpoint A
di `DG-PLUS-LAUNCH` e prima del checkpoint B.

Lo spike e la futura matrice commerciale devono verificare almeno:

- acquisto non consumabile e ripristino;
- `Transaction.currentEntitlements` e `Transaction.updates`;
- Family Sharing;
- rimborso e revoca;
- stato offline prudente;
- acquisto interrotto o non sincronizzato;
- TestFlight e Commerce QA;
- conservazione dei dati quando l’entitlement non è disponibile.

La perdita o revoca di Plus può disabilitare soltanto capacità additive Premium. Non
mette in pausa routine del core, non spezza collegamenti 1.0 e non nasconde dati.

## 31.10 Separazione del cloud 2.0

`DG-CLOUD-PRICING` definisce separatamente account, backend, condivisione, web, Android e
servizi con costi ricorrenti. Un eventuale piano cloud può essere in abbonamento, ma non
sostituisce il core gratuito di Routally né annulla l’acquisto permanente di Plus locale.

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
- Supporto;
- Privacy;
- Termini;
- Accessibilità;
- Changelog;
- App Store;
- GitHub.

Le pagine Prezzi e Routally Plus vengono aggiunte soltanto quando `DG-PLUS-LAUNCH` è chiuso e l’acquisto è realmente disponibile.

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
- nessuna richiesta commerciale nella sessione;
- nessun feedback negativo nella sessione.

La richiesta nativa non viene chiamata come risposta diretta a un pulsante, perché iOS decide se mostrarla. Il link permanente «Valuta Routally» nel Profilo apre invece la pagina App Store.

## 32.4 Legale

- EULA standard Apple;
- Privacy Policy IT/EN;
- Termini IT/EN;
- Accessibilità;
- termini Plus IT/EN soltanto prima dell’eventuale lancio 1.X;
- nessun checkbox legale bloccante nell'onboarding;
- revisione legale prima della 0.9.

I Termini chiariscono:

- strumento organizzativo, non medico/professionale/di sicurezza;
- soglie confermate dall'utente;
- notifiche soggette a iOS, Focus, permessi e dispositivo;
- geofencing non istantaneo garantito;
- garanzia del core gratuito e, quando disponibile, perimetro dell’acquisto Plus;
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
- posizione/fallback;
- iCloud senza account;
- widget/intents;
- dichiarazione esplicita che la 1.0 è completamente gratuita e non contiene acquisti in-app;
- screencast interno EN;
- quattro archetipi, non soltanto Palestra;
- nessun account demo richiesto: il revisore può installare un Kit e usare l’intero prodotto locale;
- istruzioni precise per raggiungere ogni funzione soggetta a permesso.

## 33.10 Identità dello sviluppatore

**Decision Gate DG-DEVELOPER-IDENTITY — fase 0.8.**

Alternative da valutare:

- **account individuale:** percorso più semplice, ma App Store mostra il nome legale personale; non fare affidamento su una futura conversione per cambiare liberamente il developer name senza conferma scritta Apple;
- **entità giuridica propria idonea Apple:** può rendere Temisfera il developer name, richiede D‑U‑N‑S, sito/email aziendali, dati DSA e costi amministrativi;
- **forma societaria italiana:** S.r.l.s./S.r.l. unipersonale come soluzione più lineare; altre partnership soltanto con socio reale e verifica preventiva Apple/D&B;
- **publisher reale:** possibile con contratto e licenza IP, ma lascia controllo contrattuale ultimo, pagamenti e trasferimento all'Account Holder del publisher;
- **account rental:** opzione ad alto rischio di controllo, credenziali e conformità; non raccomandata come baseline, ma la decisione finale resta nel gate.

La preferenza attuale è account individuale o organizzazione propria; publisher eventualmente come partner di crescita dopo la validazione. Non creare il primo record definitivo, il Bundle ID finale o i container definitivi finché il gate non è chiuso o finché Apple non conferma la trasferibilità desiderata. Eventuali prodotti StoreKit appartengono alla 1.X: la creazione non pubblica richiede il checkpoint A di `DG-PLUS-LAUNCH` e la pubblicazione richiede il checkpoint B.

---

# 34. Metriche di successo

## 34.1 Beta privata

### Natura delle soglie

La beta privata produce evidenze qualitative da sessioni osservate, questionari e feedback
TestFlight. La numerosità dipende dai tester realmente disponibili e non viene presentata
come campione statistico. La decisione di procedere alla 0.9 resta del Product Owner e si
basa sui problemi osservati, non su percentuali prive di potenza statistica.

### Soglie

Senza analytics nascosti, tramite TestFlight e ricerca diretta, si verificano:

- percorsi assegnati completati senza un pattern ricorrente di assistenza;
- nessuno dei quattro archetipi con problema strutturale;
- creazione di routine reali proprie dopo i casi guidati;
- uso continuato sufficiente a osservare almeno un ciclo reale;
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

Nei primi 90 giorni si raccolgono baseline reali per attivazione, retention, conversione della pagina App Store, stabilità, adozione delle funzioni e volume di supporto. I confronti con peer e gli obiettivi
numerici vengono fissati soltanto dopo avere dati omogenei e una numerosità dichiarata.
Resta immediatamente bloccante qualunque problema ricorrente del motore fondamentale o di
integrità dei dati.

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

Non usare la code coverage percentuale come unico obiettivo. Privilegiare comportamenti
critici, invarianti ed edge case.

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
- esportazione CSV;
- migrazioni;
- invarianti, incluso il fatto che il core 1.0 non dipende da entitlement commerciali.

Ogni bug produce un regression test.

## 35.3 XCTest/XCUITest

Flussi obbligatori 1.0:

1. onboarding;
2. creazione rapida;
3. configurazione completa;
4. installazione e configurazione dei 12 Kit;
5. quattro archetipi;
6. link e follow-up;
7. geofencing/fallback;
8. correzione;
9. search;
10. iCloud;
11. widget/intents;
12. CSV;
13. delete/recover;
14. accessibility;
15. localization;
16. iPad;
17. librerie con molte routine e collegamenti, senza limiti commerciali.

StoreKit, ripristino, rimborso, revoca e Family Sharing entrano nei flussi obbligatori
della release candidata Plus dopo il checkpoint A e devono essere completati prima del
checkpoint B di `DG-PLUS-LAUNCH`.

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
- verifica che non esistano paywall, prodotti o capability In-App Purchase;
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

Release manuale dopo approvazione, completamente gratuita e senza acquisti in-app.

Dalla 1.1: phased release di default. La beta commerciale e la Commerce QA di Plus
vengono pianificate separatamente dopo il checkpoint A e prima del checkpoint B di
`DG-PLUS-LAUNCH`.

---

# 36. Performance e affidabilità

## 36.1 Budget

Prima della beta vengono misurati su un dispositivo minimo supportato cold launch, risposta
alle azioni principali, scroll, memoria ed energia. I numeri iniziali sono baseline da
registrare, non soglie inventate a priori.

Restano vincoli funzionali:

- il feedback di una registrazione è immediato e non attende CloudKit;
- nessuna operazione di rete blocca la UI;
- le azioni quotidiane funzionano offline;
- ricalcoli percepibili espongono progresso e cancellazione senza stato parziale;
- la cronologia usa paginazione quando la misura ne dimostra la necessità.

## 36.2 Dataset di verifica

Fino ai dati della beta, la fixture di riferimento rappresenta un uso intenso ma
plausibile: 50 routine attive, 200 archiviate, 10.000 eventi, 100 collegamenti e 500
follow-up distribuiti su più anni, fusi, revisioni, tombstone e conflitti multi-device.

Il volume viene aggiornato dopo la beta usando il percentile alto osservato con un margine
esplicito. Dataset molto maggiori possono essere esplorativi, ma non bloccano la release
se non rappresentano un uso reale supportato.

## 36.3 Strategie

- ricalcolo dipendenze coinvolte;
- paginazione;
- cache o indici soltanto dopo profiling;
- isolamento della persistenza e delle operazioni pesanti;
- cancellation;
- indici;
- niente full scan all'avvio;
- niente location continua;
- trigger geografici prioritizzati.

## 36.4 Gate

La Release Candidate viene misurata in configurazione Release su device fisico per cold
launch, interazioni principali, scroll, memoria, energia, database, ricalcolo, offline e
sync. Il gate fallisce per regressioni rispetto alla baseline o per un problema percepibile
e riproducibile, non perché manca un numero arbitrario definito prima delle misure.

---

# 37. Versioning e milestone interne

## 37.1 Versioni pre-1.0

Le versioni `0.x` sono fasi interne verso una 1.0 completa e gratuita, non un MVP
commerciale.

### 0.1 — Foundation

Ordine obbligatorio:

1. repository e governance documentale;
2. direzione UI Apple-native e flussi iniziali nelle specifiche;
3. progetto Xcode, target e SwiftUI UI Foundation;
4. technical spike applicabili alla 1.0.

Include:

- repository e documentazione;
- brand foundations in Asset Catalog e SwiftUI;
- candidata tecnica dell'icona in Icon Composer, collegata ai target e verificata su
  Simulator senza chiudere `DG-ICON`;
- progetto Xcode;
- Routally Dev;
- CI;
- architettura base;
- spike dati; prototipi mirati per location, navigation/search e iPad/accessibilità.

`TG-STOREKIT` non appartiene alla Foundation 1.0 ed è differito alla 1.X.

### 0.2 — Core Routine Engine

- eventi;
- regole temporali;
- misure;
- obiettivi;
- cicli;
- reducer e stato derivato;
- invarianti;
- test dominio;
- spike TG-RECALC sul ricalcolo retroattivo, prima di costruire interfacce che dipendono dal motore.

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

Il caso di sviluppo può usare Palestra, ma il motore deve essere generico e testato sui
quattro archetipi.

### 0.4 — Today & Routines

- shell navigazione;
- Oggi;
- lista Routine;
- dettaglio;
- creazione rapida/progressiva;
- pause/archive/delete.

### 0.5 — Explore & System

- tutti i 12 Kit installabili;
- Esplora;
- notifiche;
- luoghi;
- widget;
- App Intents;
- Universal Links;
- Profilo/iCloud;
- nessun limite commerciale.

### 0.6 — Insights, Search & Release Foundations

- Analisi;
- search;
- garanzia del core gratuito verificata;
- support/legal;
- App Store foundations;
- nessuna superficie commerciale o capability In-App Purchase.

### 0.7 — Feature complete / freeze

- tutte le feature 1.0 implementate;
- nessuna nuova feature;
- soltanto bug, accessibilità, UX indispensabile, localizzazione, performance e App Review.

### 0.8 — Alpha

- test interni;
- verifica dell'icona su iPhone e iPad reali nella build feature-complete;
- user test cieco della candidata icona e dei due controlli previsti;
- revisione UI, accessibilità e implementazione;
- identity gate;
- legal/privacy/security audit;
- stabilization.

### 0.9 — Beta / Release Candidate

- beta privata/ampliata;
- success criteria;
- schema CloudKit production;
- App Review evidence;
- decisione sul rischio figurativo e ratifica finale dell'icona;
- final assets;
- launch date gate.

### 1.0 — App Store

- release manuale;
- worldwide;
- completamente gratuita;
- controlled launch;
- support ready.

## 37.2 Milestone operative

Gli identificativi distinguono livelli diversi e non formano numeri decimali:

- `0.x` e `1.0` identificano la fase/versione interna complessiva del prodotto;
- `Mnn` identifica una milestone, cioè un risultato integrato con una Definition of Done;
- `Enn` identifica un’epica, cioè un’area di lavoro implementabile attraverso attività e PR;
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
- `M08` — Free Core & Release Foundations;
- `M09` — Accessibility & Localization;
- `M10` — Alpha;
- `M11` — Beta;
- `M12` — App Store 1.0.

### Mappa canonica fase → milestone → epiche → gate

Ogni epica appartiene a una sola milestone primaria e gli ID delle epiche seguono
l’ordine delle milestone, non una gerarchia decimale. I gate non sono figli organizzativi
della milestone: sono condizioni che ne precedono o vincolano il completamento.

| Fase/versione | Milestone | Epiche primarie | Gate e prerequisiti principali |
|---|---|---|---|
| `0.1` | `M01` Foundation | `E01`–`E03` | `TG-DATA` chiuso **Adapt** su evidenze locali; prototipi mirati per le integrazioni UI/sistema |
| `0.2` | `M02` Core Routine Engine | `E04`–`E05` | adattamenti di `TG-DATA` applicati; `TG-RECALC` prima delle feature dipendenti |
| `0.3` | `M03` Vertical Slice | `E06` | `M01` e `M02` concluse; gate dati, ricalcolo e location applicati tramite confini testabili, senza anticipare le integrazioni di sistema complete |
| `0.4` | `M04` Today & Routine | `E07`–`E10` | vertical slice reale verificata su device e offline |
| `0.5` | `M05` Explore & Kits | `E11` | motore e creazione disponibili; tutti i 12 Kit installabili senza limiti commerciali |
| `0.5` | `M06` System Integrations | `E12`–`E14` | `DG-DOMAIN` chiuso; criteri delle sezioni 18, 19, 21 e 23 implementati e verificati localmente; predisposizione iCloud testata su Simulator |
| `0.6` | `M07` Insights & Search | `E15`–`E16` | criteri di ricerca e gate di evidenza degli insight verificati |
| `0.6` | `M08` Free Core & Release Foundations | `E17`–`E18` | garanzia gratuita, assenza di commercio 1.0, supporto, legale e App Store foundations completi |
| `0.7` | `M09` Accessibility & Localization | `E19` | `M01`–`M08` feature complete; avvio del feature freeze |
| `0.8` | `M10` Alpha | `E20` | `DG-DEVELOPER-IDENTITY` chiuso; asset Apple definitivi e CloudKit Development validati realmente; gate performance della sezione 36; audit privacy e sicurezza; evidenze real-device e user test di `DG-ICON` raccolte |
| `0.9` | `M11` Beta | `E21` | RC stabile, schema CloudKit production; decisione figurativa e ratifica di `DG-ICON`; `DG-TRADEMARK`, `DG-ICON` e `DG-LAUNCH` chiusi |
| `1.0` | `M12` App Store 1.0 | `E22` | release gate delle sezioni 35, 46 e 52; submission approvata e rilascio manuale autorizzato |

La fase `0.7` non rende accessibilità e localizzazione attività finali: `E19` conduce
l’audit complessivo, mentre ogni epica precedente deve già rispettare le dimensioni
trasversali della sezione 0.4 durante la propria implementazione.

La mappa copre il percorso verso la 1.0. `DG-PLUS-LAUNCH` e `TG-STOREKIT` appartengono
alla monetizzazione additiva della 1.X; `DG-CLOUD-PRICING` e `DG-FUTURE-ANALYTICS`
appartengono rispettivamente alla 2.0 e a una valutazione futura. Nessuno dei quattro gate
blocca la release gratuita 1.0.

Le milestone vengono mantenute nel backlog personale e nella documentazione del
repository. GitHub non viene usato per raccogliere issue o richieste pubbliche; branch e
PR restano strumenti tecnici personali.

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

Nessuna data pubblica prima della 0.9 e dei release gate. Nessuna stima in settimane deve
essere trattata come affidabile prima di aver completato la SwiftUI UI Foundation e i
technical spike applicabili alla 1.0.

**Decision Gate DG-LAUNCH:** data e possibile preordine dopo RC stabile.

## 37.5 Gestione dello scope 1.0

Lo scope della sezione 6 resta interamente nella 1.0 per decisione del Product Owner. La
sua ampiezza è un rischio consapevole, non un’autorizzazione a preparare architetture
generiche o a comprimere i requisiti di prodotto.

La mitigazione è operativa:

1. implementare nell’ordine delle milestone, chiudendo prima motore e vertical slice;
2. costruire la soluzione più semplice che soddisfa il requisito corrente;
3. introdurre ottimizzazioni e astrazioni soltanto dopo una misura o un secondo caso reale;
4. applicare il feature freeze dalla 0.7;
5. se la qualità non è sufficiente, spostare la data di lancio.

Nessuna funzione passa automaticamente alla 1.1. Un eventuale cambio di scope richiede
una nuova decisione esplicita del Product Owner e il normale change control.

---

# 38. Roadmap 1.X

## 38.1 Principio di evoluzione

La serie 1.X continua a migliorare gratuitamente tutto il core della 1.0. Correzioni,
affidabilità, accessibilità, compatibilità, riduzione dell’attrito e normali evoluzioni
delle funzioni esistenti non diventano Premium.

Routally Plus non è legato a una versione prestabilita: viene pubblicato soltanto quando
`DG-PLUS-LAUNCH` è chiuso. Fino a quel momento ogni release 1.X resta completamente
gratuita.

## 38.2 Evoluzione gratuita del core

Candidati gratuiti della 1.X:

- varianti guidate e preset più efficaci;
- esclusione rapida di un link per singolo evento;
- luogo + orario e ritardo dopo arrivo;
- reminder prima della prossima routine;
- integrazione Calendario di base;
- gestione migliore dei viaggi;
- ulteriori miglioramenti iPad;
- nuovi Kit basati sul motore 1.0;
- miglioramenti a ricerca, Analisi, widget e correzione;
- import o condivisione privata di configurazioni Kit, senza dati personali.

L’elenco non autorizza automaticamente nuovo scope: ogni voce segue milestone, evidenza
e change control ordinari.

## 38.3 Capacità candidate per Routally Plus

Il bundle da sottoporre al Premium Value Gate può comprendere:

- app Apple Watch, complicazioni, Smart Stack e logging dal polso;
- Apple Health con automazioni trasparenti e confermabili;
- Linked Routines avanzate con condizioni multiple, varianti e catene guidate;
- ritmo adattivo, previsioni e insight azionabili;
- NFC, Calendario avanzato e contesti evoluti come funzioni complementari;
- automazioni a più livelli senza trasformare Routally in un editor tecnico.

La presenza in questa roadmap non determina da sola la classificazione Free o Plus. Il
confine finale deve rispettare la garanzia della sezione 31.2.

## 38.4 Gate di lancio Plus

La sequenza obbligatoria è:

1. costruire e testare le capacità candidate dietro feature flag Dev;
2. raccogliere evidenza qualitativa sul valore del bundle;
3. approvare il checkpoint A di `DG-PLUS-LAUNCH`, lasciando il gate aperto;
4. creare soltanto le configurazioni e gli asset non pubblici necessari e chiudere
   `TG-STOREKIT` sul prodotto definitivo;
5. completare bundle, accessibilità, IT/EN, privacy, supporto, termini, metadata e
   Commerce QA;
6. chiudere il checkpoint B di `DG-PLUS-LAUNCH`;
7. soltanto allora rendere disponibili il prodotto e le superfici di acquisto.

## 38.5 Prezzo 1.X

Il modello confermato, applicabile solo dopo il gate, è:

- Routally Plus a **29,99 € una tantum**;
- nessun abbonamento mensile o annuale nella 1.X;
- nessun trial;
- Family Sharing se verificato tecnicamente;
- diritti locali permanenti e separati dal futuro cloud 2.0.

## 38.6 Evoluzione successiva

Restano candidati di lungo termine nella 1.X:

- allegati utili;
- ulteriori unità;
- Analisi approfondita;
- stagionalità e vacanze;
- soglie adattive sempre confermate dall’utente;
- lingue ulteriori;
- preparazione dei confini di migrazione per l’account 2.0, senza backend anticipato;
- eventuali analytics privacy-first soltanto con nuova decisione.

---

# 39. Roadmap 2.X e lungo termine

## 39.1 Routally 2.0 — Account Routally

- backend proprietario;
- Sign in with Apple;
- migrazione local/iCloud;
- sync account tra dispositivi Apple;
- dispositivi e sicurezza;
- modalità locale preservata, se tecnicamente sostenibile;
- nuovo modello cloud separato dall’acquisto permanente di Plus locale;
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
- tutela dei diritti Plus locali già acquistati;
- Family/Shared pricing;
- web/Android;
- eventuali aumenti per nuovi utenti.

---

# 40. Technical spikes e validation gates

## 40.1 TG-DATA — SwiftData/CloudKit

**Stato:** chiuso — **Adapt**. Le evidenze locali su UUID e deduplica applicativi,
migrazioni, offline, recovery su disco, convergenza deterministica e dataset sono in
`docs/ENGINEERING/tg-data-spike.md`. L'esito sblocca `E05` e vincola l'implementazione a
UUID di dominio, deduplica applicativa, schema versionato e identificativi iniettati.

Il gate risolve l'incertezza architetturale, ma non certifica il servizio CloudKit. La
sincronizzazione reale, il recovery fra client, l'App Group firmato e lo schema CloudKit
Development saranno verificati in `M10`, dopo `DG-DEVELOPER-IDENTITY`, sugli asset Apple
definitivi. La promozione e verifica dello schema Production appartengono a `E21` / `M11`.

Verificare:

- event store;
- dataset di riferimento della sezione 36;
- contratto App Group/widget simulato localmente;
- offline;
- convergenza multi-client simulata;
- revisioni/tombstone;
- migrazioni;
- configurazione iniettata per il futuro container definitivo;
- recovery.

Esito:

- Go;
- Adapt;
- Fallback Core Data/CloudKit.

## 40.2 TG-RECALC — ricalcolo retroattivo deterministico

**Stato:** chiuso — **Async boundary**. Evidenze e misure sono raccolte in
`docs/ENGINEERING/tg-recalc-spike.md`.

Il ricalcolo su correzione retroattiva è parte del valore distintivo e viene validato
nella 0.2 prima che le feature dipendano dal suo comportamento.

Sul dataset di riferimento della sezione 36 verificare:

- due esecuzioni sugli stessi eventi producono lo stesso risultato;
- ordini di consegna CloudKit diversi convergono allo stesso stato;
- la modifica propaga soltanto alle dipendenze coinvolte;
- follow-up rimossi o rigenerati rispettano la matrice della sezione 41.1;
- l’operazione non blocca la UI e non persiste stati parziali se cancellata.

Lo spike sceglie fra ricalcolo sincrono e asincrono in base alle misure. Non autorizza a
rimuovere la correzione retroattiva né a costruire proiezioni persistenti o un repair
engine senza un collo di bottiglia dimostrato.

## 40.3 TG-STOREKIT — differito alla 1.X

Questo gate non appartiene alla 1.0 e non ne blocca il rilascio. Si apre dopo il
checkpoint A di `DG-PLUS-LAUNCH`, mentre il Decision Gate resta aperto, e deve chiudersi
prima del checkpoint B.

Verificare sul prodotto non consumabile definitivo:

- acquisto, transazione pendente e ripristino;
- `Transaction.currentEntitlements` e `Transaction.updates`;
- Family Sharing;
- rimborso e revoca;
- comportamento offline e cache prudente;
- reinstallazione e acquisto non sincronizzato;
- TestFlight e Commerce QA;
- conservazione di routine e dati quando l’entitlement non è disponibile;
- assenza di qualunque effetto sul core gratuito.

Lo spike chiude soltanto le incertezze dell’integrazione StoreKit. Non può modificare il
bundle, il prezzo o la garanzia gratuita senza change control.

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
| Migrazione interrotta | Transazione/rollback; checklist operativa |

## 41.5 StoreKit futuro — 1.X

Questa matrice non si applica alla 1.0. Quando Plus viene lanciato deve coprire:

| Caso | Comportamento |
|---|---|
| Acquisto interrotto o pendente | Nessun doppio addebito; stato chiaro e ripetibile |
| Ripristino fallisce | Retry e supporto senza bloccare il core gratuito |
| Rimborso o revoca | Solo capacità Plus disabilitate; routine e dati intatti |
| Family Sharing termina | Solo entitlement condiviso rimosso; core e dati intatti |
| Entitlement non verificabile offline | Cache prudente e refresh successivo, senza perdita dati |
| Acquisto non sincronizzato | Aggiornamento transazioni e azione di ripristino visibile |

---

# 42. Checklist operativa

Prima della 0.9 serve una sola checklist operativa, aggiornata con problemi realmente
osservati in sviluppo e beta. Ogni incidente segue questo flusso:

1. proteggere i dati locali e impedire nuove scritture parziali o distruttive;
2. classificare impatto, riproducibilità e componente coinvolto;
3. verificare stato e permessi Apple pertinenti senza raccogliere dati personali;
4. applicare retry, fallback o rollback già previsti dalla matrice delle eccezioni;
5. comunicare uno stato comprensibile all'utente quando il problema è visibile;
6. correggere la causa con un test di regressione;
7. per bug critici, sospendere promozione o phased release e preparare un hotfix;
8. per vulnerabilità, usare il canale privato di `SECURITY.md` e valutare disclosure dopo il fix.

CloudKit, migrazioni, notifiche/geofencing, App Review e asset operativi riutilizzano questo flusso. StoreKit lo riutilizzerà soltanto dalla release 1.X che lancerà Plus con le rispettive verifiche della sezione 41. Runbook separati
si scrivono soltanto quando un incidente reale o una procedura Apple non banale richiede
passaggi ripetibili aggiuntivi.

---

# 43. Risk register iniziale

Scala: probabilità P e impatto I: Basso/Medio/Alto.

| Rischio | P | I | Segnale | Mitigazione | Gate/fallback |
|---|---|---|---|---|---|
| SwiftData/CloudKit non regge il registro eventi | M | A | conflitti/migrazioni fragili | `TG-DATA` locale chiuso Adapt e prova reale Development in M10 | fallback Core Data se l'integrazione reale dimostra un limite bloccante |
| Creazione troppo complessa | A | A | abbandono/test assistiti | rapido default, preset, Kit | beta gate |
| Geofencing inaffidabile | M | A | reminder mancanti/duplicati | fallback, deduplica e prova su device | sezioni 18 e 35 |
| Analisi poco utile | M | M | tab vuota/generica | evidence gates, insight decisionali | ridurre contenuti, non eliminare senza decisione |
| Search sovradimensionata | M | B | scarso uso/confusione | ricerca globale chiara e test con dati reali | sezioni 8 e 35 |
| Scope 1.0 troppo ampio | A | A | ritardi e fragilità | milestone, soluzione minima conforme, 0.7 freeze e slittamento della data se serve | 37.5, Product Owner |
| Ricalcolo retroattivo lento o non deterministico | M | A | correzione che blocca la UI o produce esiti divergenti tra dispositivi | reducer deterministico, misura e ricalcolo delle sole dipendenze | TG-RECALC |
| App percepita ossessiva | M | A | tester ansiosi, troppe notifiche | Calm View, no streak, Kit criteria | beta UX |
| App percepita troppo tecnica | M | A | confusione link/regole | linguaggio naturale, trasparenza | Simulator/usability testing |
| Performance cronologia | M | A | launch/scroll lenti | profiling, indici mirati e paginazione | sezione 36 |
| Doppie notifiche multi-device | M | M | feedback duplicazioni | primary device | integration tests |
| La 1.0 gratuita non genera ricavi immediati | A | M | costi superiori alla capacità di sostenerli | costi ricorrenti minimi, local-first e validazione prima dell’acquisizione a pagamento | 45, review 90 giorni |
| Plus 1.X non offre valore sufficiente | M | A | tester lo percepiscono come rifiniture o paywall artificiale | Premium Value Gate e rinvio del lancio | DG-PLUS-LAUNCH |
| Prezzo una tantum non sostenibile | M | M | supporto o manutenzione superiori alle ipotesi | cost model prima del gate, nessun servizio cloud incluso | DG-PLUS-LAUNCH, DG-CLOUD-PRICING |
| Superfici commerciali entrano per errore nella 1.0 | B | A | paywall, capability o metadata IAP nella RC | release gate esplicito e scan configurazioni | 31.9, 35, 46 |
| Costi cloud 2.0 incompatibili con il prezzo locale | M | A | backend variabile non coperto | piano cloud separato e tutela dei diritti locali | DG-CLOUD-PRICING |
| Identità legale ritardata | M | A | impossibile creare store record | gate 0.8 | DG-DEVELOPER-IDENTITY |
| Repository pubblico espone asset | B | M | clone/indexing | copyright, asset review, secrets | security baseline |
| Assenza analytics limita diagnosi | M | M | poco insight uso | beta qualitativa, App Store data | decisione futura esplicita |
| Acquisizione insufficiente | M | A | poco traffico e poche prove | ASO, custom pages, creator, lancio in due fasi | review 90 giorni |
| Retention debole per attrito di logging | M | A | abbandono dopo setup | quick logging, widget, Intents, Kit utili | beta/review 90 giorni |
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
| StoreKit products futuri | App Store Connect owner | ruoli | Account Holder | creazione non pubblica dopo il checkpoint A di `DG-PLUS-LAUNCH`; pubblicazione dopo il checkpoint B; con app transfer |
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

Sostenibile, ma non gratuito a qualsiasi costo. La gratuità commerciale della 1.0 non autorizza infrastruttura o acquisizione non sostenibili: il modello local-first e l’assenza di backend mantengono basso il costo variabile durante la validazione.

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
- Instruments;
- nessun backend/analytics/helpdesk SaaS 1.0.

Da `M10`, TestFlight e le quote Xcode Cloud incluse nell'iscrizione Apple già necessaria
per la distribuzione non costituiscono un costo aggiuntivo separato.

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

## 46.3 Modello gratuito 1.0

- prezzo App Store gratuito;
- nessun prodotto In-App Purchase o abbonamento associato alla 1.0;
- nessuna capability, configurazione StoreKit, restore o manage subscription nella build;
- nessun paywall o metadata che suggerisca funzioni a pagamento;
- descrizione chiara che tutte le funzioni della 1.0 sono incluse;
- verifica che i 12 Kit, cronologia, luoghi, widget e collegamenti non abbiano limiti commerciali.

La checklist commerce completa viene aperta dopo il checkpoint A e deve essere
completata prima del checkpoint B di `DG-PLUS-LAUNCH`; copre prezzo una tantum, Family
Sharing, restore, refund/revoke, termini, privacy e trasparenza del perimetro Plus.

## 46.4 Legale/territori

- age rating;
- export compliance encryption; se si usa soltanto la crittografia fornita dal sistema operativo, dichiarare correttamente l’esenzione e verificare se non serve documentazione aggiuntiva;
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
- assenza di StoreKit config e capability In-App Purchase nella 1.0;
- no Dev tools;
- no private APIs;
- no placeholder content.

## 46.6 App Review notes

Devono spiegare:

- niente account;
- iCloud privato;
- app completamente gratuita e senza acquisti in-app;
- come provare Linked Routines e installare qualunque Kit;
- come provare location senza attendere troppo;
- fallback;
- perché le notifiche sono locali;
- accessibilità;
- contatti supporto.

---

# 47. Tracciabilità operativa

La tracciabilità non duplica più i requisiti in una matrice separata. L'albero canonico
fase → milestone → epiche → gate è nella sezione 37.2; le Definition of Done della sezione
48 indicano l'esito verificabile. Ogni PR collega la propria epica, i requisiti di prodotto
coinvolti e le verifiche eseguite, senza mantenere una seconda tassonomia `RTY-*`.

---

# 48. Definition of Done per milestone

## 48.1 M01 — Foundation

- repo, CI e Xcode compilano;
- Swift 6 strict concurrency;
- Dev/Public config;
- documentazione base;
- SwiftUI UI Foundation e preview matrix;
- candidata tecnica dell'icona pubblico/Dev versionata, collegata e verificata su Simulator;
- spike report ed esiti dei Technical Gate applicabili alla 1.0;
- `TG-STOREKIT` registrato come differito alla 1.X;
- no secrets;
- ADR baseline.

## 48.2 M02 — Core Routine Engine

- quattro archetipi rappresentabili;
- invarianti testate;
- event revisions;
- reducer e stato derivato;
- deterministic replay;
- confine di store e persistenza locale offline;
- schema locale V1 versionato e migrazione baseline;
- dataset di riferimento della sezione 36;
- no UI dependency.

## 48.3 M03 — Vertical Slice

- flusso end-to-end su device;
- offline;
- undo/correction;
- follow-up;
- reminder/fallback tramite confini testabili, senza dipendere dai trigger di sistema completi;
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
- tutti i 12 Kit installabili e configurabili gratuitamente;
- copie indipendenti;
- search metadata;
- nessuna quota di routine o collegamenti;
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
- integrazione CloudKit, conflitti e recovery implementati e verificati localmente su Simulator; la prova sul servizio Development è rinviata a `M10`;
- CSV e cancellazione completa verificati.

## 48.7 M07 — Insights & Search

- evidence gates;
- no causal overclaim;
- accessible charts;
- local search;
- filters/synonyms;
- performance.

## 48.8 M08 — Free Core & Release Foundations

- garanzia del core gratuito documentata e testata;
- nessun limite commerciale, paywall o flag Plus nella 1.0;
- nessun prodotto o capability In-App Purchase;
- tutti i 12 Kit e tutte le superfici 1.0 disponibili;
- support site e pagine legali/accessibilità baseline IT/EN;
- metadata e checklist App Store baseline;
- `DG-PLUS-LAUNCH` e `TG-STOREKIT` esplicitamente fuori dalla 1.0.

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
- icona verificata nelle superfici della build feature-complete su iPhone e iPad reali;
- user test cieco dell'icona completato e risultati registrati;
- `DG-DEVELOPER-IDENTITY` chiuso;
- iscrizione all'Apple Developer Program completata e asset definitivi di Bundle ID, App Group e container iCloud creati;
- sincronizzazione CloudKit Development, conflitti, offline, riavvio, reinstallazione, recovery e schema verificati realmente fra almeno due client;
- security/privacy audits;
- performance baseline;
- checklist operativa aggiornata con i problemi osservati.

## 48.11 M11 — Beta

- beta metrics;
- RC stability;
- App Store assets;
- legal complete;
- CloudKit production;
- review evidence per app gratuita;
- support ready;
- rischio figurativo dell'icona verificato formalmente o accettato esplicitamente;
- ratifica finale dell'icona registrata nel decision record;
- `DG-TRADEMARK`, `DG-ICON` e `DG-LAUNCH` chiusi.

## 48.12 M12 — App Store 1.0

- all release gates;
- submission e App Review completate;
- prezzo gratuito e assenza di IAP verificati;
- manual release;
- monitoring and support;
- controlled launch;
- 1.0.1 contingency.

---

# 49. Backlog per epiche

La sezione 37.2 assegna ogni epica a una sola milestone; la sezione 48 definisce il
risultato della milestone. Questo catalogo conserva nomi e obiettivi, senza riscrivere per
la terza volta i requisiti delle sezioni di prodotto.

| Epica | Obiettivo |
|---|---|
| `E01` Repository & Governance | repository, regole operative e controlli di base |
| `E02` Apple-native UI Direction | contratti di navigazione, creazione, accessibilità e icona |
| `E03` Xcode & SwiftUI Foundation | progetto, target, configurazioni, componenti, preview eseguibili e candidata tecnica dell'icona pubblico/Dev |
| `E04` Domain Engine | registro eventi, reducer, regole, cicli, link, follow-up e invarianti |
| `E05` Local Persistence Foundation | schema SwiftData locale, migrazioni, offline e store testabile |
| `E06` Vertical Slice Integration | flusso collegato completo con correzione, conseguenze e fallback |
| `E07` App Shell | tab, navigazione, routing, sheet e deep link |
| `E08` Creation | flusso unico progressivo, preset, validazione e ingresso dai Kit |
| `E09` Today | Calm View, azioni e riepilogo delle conseguenze |
| `E10` Routines | lista, dettaglio, cronologia, modifica e ciclo di eliminazione |
| `E11` Explore & Kits | catalogo dei 12 Kit, installazione libera e copie configurabili |
| `E12` Notifications & Location | notifiche, trigger geografici, fallback e dispositivo principale |
| `E13` System Surfaces | widget, Lock Screen, App Intents, link e background |
| `E14` Profile, Data & iCloud | profilo locale, implementazione CloudKit predisposta e testata localmente, conflitti, export e cancellazione dati |
| `E15` Analysis | metriche, insight spiegabili, grafici e stati senza dati sufficienti |
| `E16` Search | indice locale, sinonimi, filtri, risultati e azioni |
| `E17` Free Core & Product Readiness | garanzia gratuita, assenza di limiti/IAP e preparazione del futuro Premium Value Gate |
| `E18` Support, Legal & App Store Foundations | supporto, documenti IT/EN, metadata e checklist submission gratuita |
| `E19` Accessibility & Localization | audit completo, IT/EN e matrice di accessibilità |
| `E20` Alpha | TestFlight interno, gate identità, asset Apple definitivi, validazione CloudKit Development, audit, stabilizzazione, prove real-device e user test dell'icona |
| `E21` Beta | beta, CloudKit Production, asset ed evidence package della 1.0 gratuita, decisione figurativa e ratifica dell'icona |
| `E22` App Store Release | submission, App Review, rilascio controllato e contingenza 1.0.1 |

Il backlog non deve duplicare il Master Plan: ogni attività indica epica, criterio di
accettazione, dipendenze e verifiche applicabili. Una nuova attività non amplia lo scope
dell’epica né della 1.0 senza change control.

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

- `E03` / `M01`: candidata tecnica in Icon Composer, file `.icon`, collegamento dei target
  e verifica Simulator; il gate resta aperto;
- `E20` / `M10`: prove su iPhone e iPad reali e user test cieco sulla build
  feature-complete;
- `E21` / `M11`: verifica figurativa formale o accettazione esplicita del rischio,
  ratifica del Product Owner e chiusura del gate prima degli asset App Store definitivi.

## DG-DEVELOPER-IDENTITY

Fase 0.8:

- account individuale oppure entità Temisfera;
- eventuale publisher reale o account rental valutati soltanto con due diligence e contratto; baseline non raccomandata;
- dati DSA trader e indirizzo pubblico;
- Apple organization/D‑U‑N‑S, sito ed email di dominio;
- cessione o licenza IP;
- impatto su Bundle ID, CloudKit, App Groups, Xcode Cloud, pagamenti e trasferimento;
- impatto futuro sui prodotti StoreKit, che non vengono creati nella 1.0;
- riservare il Bundle ID finale soltanto dopo la chiusura coerente di questo gate;
- iscriversi all'Apple Developer Program e creare Bundle ID, App Group e container iCloud definitivi soltanto in `M10`, quindi eseguire la validazione reale CloudKit Development prevista dalla sezione 40.1;
- developer name scelto prima del primo record App Store.

## DG-LAUNCH

- data e preordine dopo RC 0.9.

## DG-PLUS-LAUNCH

Gate 1.X, non bloccante per la 1.0 e articolato in due checkpoint:

### A — Approvazione del bundle

- almeno due nuove capacità principali;
- promessa coerente e valore ricorrente;
- evidenza qualitativa di bisogno, comprensione e disponibilità a pagare;
- nessuna sottrazione o degradazione del core 1.0;
- prezzo una tantum di 29,99 € e sostenibilità del perimetro locale confermati.

Il checkpoint A apre `TG-STOREKIT`, ma non autorizza il lancio.

### B — Autorizzazione al lancio

- `TG-STOREKIT` chiuso sul prodotto definitivo;
- bundle, accessibilità, IT/EN, privacy, supporto e termini completi;
- metadata e Commerce QA completi;
- prezzo, perimetro e diritti permanenti riconfermati.

Se una condizione manca, Plus non viene lanciato e il gate resta aperto.

## DG-CLOUD-PRICING

- modello 2.0, backend e prezzi;
- tutela permanente del core gratuito e dei diritti Plus locali già acquistati.

## DG-FUTURE-ANALYTICS

- soltanto se strumenti Apple e ricerca qualitativa insufficienti;
- nuova decisione privacy e App Store.

---

# 51. Decisioni esplicitamente sostituite

Per evitare che documenti o chat precedenti vengano seguiti per errore:

- **Superseded:** Routally 1.0 freemium con 10 routine, 5 collegamenti, 4 Kit installabili, Analisi limitata, un widget e un luogo.
  **Finale:** Routally 1.0 completamente gratuita e senza limiti commerciali; tutti i 12 Kit e tutto il core sono disponibili a tutti.

- **Superseded:** Plus 1.0 con Annual 14,99 €, trial di 14 giorni e Lifetime 39,99 €, paywall, grace period e downgrade.
  **Finale:** nessun acquisto o StoreKit nella 1.0; Plus additivo nella 1.X soltanto dopo `DG-PLUS-LAUNCH`, a 29,99 € una tantum e senza abbonamento.

- **Superseded:** il Lifetime 1.X comprendeva in anticipo Watch, Health e altre integrazioni.
  **Finale:** le capacità Premium vengono classificate solo dal Premium Value Gate; i diritti locali acquistati restano permanenti e il cloud 2.0 è separato.

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

- **Superseded:** tre app Dev/TestFlight/App Store.
  **Finale:** una variante Dev e un unico prodotto Routally per TestFlight/App Store.

- **Superseded:** icona «azione centrale e conseguenze collegate» e le quattro alternative della 4.8.
  **Finale:** monogramma `R` costruito attorno a un ciclo; `DG-ICON` resta aperto per la validazione finale Apple e di originalità.

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
7. l’app è accessibile;
8. IT/EN sono completi;
9. l’intero core 1.0 è gratuito e privo di limiti commerciali;
10. tutti i 12 Kit, cronologia, collegamenti, luoghi e superfici di sistema sono disponibili senza paywall;
11. la build non contiene prodotti, capability o UI In-App Purchase;
12. l’interfaccia sembra Apple-native;
13. la registrazione è più semplice del carico mentale che elimina;
14. la Calm View evita ansia e debito;
15. i Kit sono utili e non ossessivi;
16. TestFlight, supporto, sito e App Store sono pronti;
17. non esistono feature Dev o incomplete nella build;
18. il Product Owner approva esperienza, materiali e release.

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

## StoreKit e App Store Connect — differiti alla 1.X

- Transaction.currentEntitlements: https://developer.apple.com/documentation/storekit/transaction/currententitlements
- Non-consumable in-app purchases: https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/overview-for-configuring-in-app-purchases
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
