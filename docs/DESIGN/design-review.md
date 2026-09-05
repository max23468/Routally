# Trama — revisione complessiva del design

**Stato:** Confirmed — pacchetto approvato; DG-VISUAL chiuso il 5 settembre 2026.
**Data:** 5 settembre 2026. **Ambito:** E06, prototipo visuale con dati sintetici.

Il proprietario ha chiesto di completare insieme i quattro passaggi del
[piano](dg-visual-plan.md): stati della creazione, coerenza trasversale, altre superfici
e consegna complessiva. Le alternative erano uno strumento per scegliere la composizione,
non un requisito da ripetere per ciascuno stato. Questa revisione segue una sola direzione.

## Decisioni conservate

- Oggi, dettaglio e conseguenze della [fase 1](trama-phase-one.md), codice `92f97de`,
  restano il riferimento approvato. Le schermate di appoggio del prototipo non li sostituiscono.
- Creazione minima: composizione 3 corretta, obiettivo nella frase modificabile e sola
  misura sotto; nessuna duplicazione dell’obiettivo.
- Conseguenze e promemoria: composizioni scelte nella [specifica di creazione](creation-flow.md).
- Riepilogo: composizione 2, intestazione Palestra separata e quattro sezioni modificabili.
- Tipografia, superfici, icone e azioni seguono il [contratto Trama](trama-components.md).

## Stati della creazione

| Stato | Soluzione unica |
|---|---|
| Vuoto | Nome con etichetta persistente e esempio; Continua disabilitato |
| Tastiera | Campo nativo, scroll e azione sopra la tastiera |
| Dato mancante | Spiegazione vicino al campo dopo il tentativo; niente allarme iniziale |
| Minimo valido | Obiettivo modificabile e misura; Crea routine primaria, configurazione facoltativa secondaria |
| Conseguenze | Sorgente, incremento, destinatario, soglia e passo successivo in linguaggio naturale |
| Promemoria | Luogo e orario di riserva distinti; alternativa solo temporale |
| Posizione negata | Messaggio contestuale; orario di riserva conservato e modificabile |
| Luogo mancante | Scegli un luogo oppure usa soltanto l’orario; conferma bloccata finché manca una scelta valida |
| Riepilogo | Frequenza, collegamento, passo successivo e promemoria modificabili |
| Salvataggio | Progresso e comandi disabilitati nello stesso contesto |
| Errore | Dati visibili, messaggio inline e Riprova; nessuna nuova sheet |
| Uscita modificata | Conferma nativa con continua a modificare o scarta |
| Successo | Chiusura della sheet e dettaglio con conferma; nessuna installazione reale nella fixture |

## Raccordo delle superfici

| Superficie | Informazione e azioni |
|---|---|
| Oggi senza routine | Orientamento verso Routine o Esplora; nessun `+` aggiuntivo |
| Oggi senza necessità | Stato calmo, senza inventare lavoro o progressi |
| Follow-up futuro | Origine, soglia raggiunta e momento utile; ciclo ancora a 4/4 |
| Follow-up pronto | Fatto come primaria e rinvio esplicito |
| Follow-up completato | Nuovo ciclo a 0/4 e Annulla completamento |
| Routine vuote | Creazione dalla navigation bar canonica |
| Filtro senza risultati | Distinto dall’assenza di routine; Mostra tutte conserva i dati |
| Cronologia | Evento, data/quantità, conseguenze e accesso alla correzione |
| Cronologia vuota | Descrive cosa apparirà dopo la prima registrazione |
| Correzione | Originale conservato, campi nativi e conferma prima del ricalcolo |
| Modifica | Nome e obiettivo; spiega ricalcolo del periodo e confine dei collegamenti futuri |
| Archivio | Stato esplicito e Ripristina; cronologia conservata |
| Esplora | Raccolta editoriale e beneficio dei collegamenti, senza dati installati implicitamente |
| Kit | Attività principale, beneficio, cosa verrà creato, valori e configurazione personale |
| Kit già aggiunto | Vai alle routine esistenti oppure configura una copia indipendente |
| Errore Kit | Nessuna aggiunta parziale; configurazione conservata e Riprova |

Le due schede Palestra e Lenzuola sono esempi visuali delle raccolte: non sono un nuovo
catalogo ridotto. Le raccolte complete e i dodici Kit restano quelli delle sezioni 12 e 20.
Il dettaglio operativo continua a usare la card causale approvata e le sue azioni di
esclusione/annullamento; il dettaglio sintetico serve soltanto a mostrare gli arrivi da
creazione, cronologia e modifica. Analisi, Cerca e Profilo sono contesto di navigazione,
non nuove proposte complete di quelle superfici.

## Prototipo riproducibile

Il modulo `RoutallyFixtures`, escluso dal prodotto pubblico, espone gli scenari tramite
`-designReview <scenario>` nella variante **Routally Dev**, configurazione **Development**.
`-designReview gallery` apre l’indice. Un argomento sconosciuto torna all’indice del
prototipo; senza opt-in l’app conserva il normale percorso. `Debug` non è una configurazione
del progetto: usarla causa un disallineamento fra app e package nella build isolata.

Esempi: `creation-error`, `permission-denied`, `follow-up-ready`, `event-correction`,
`explore`, `kit-conflict`. L’elenco completo è in `DesignReviewScenario`.

Le transizioni sono dimostrative e in memoria: non certificano salvataggio atomico,
ricalcolo, cronologia persistente, notifiche, geofence o installazione Kit. Il successo
usa lo scenario sintetico Palestra; non è una creazione generale. Il catalogo usa String
Catalog IT/EN e componenti SwiftUI nativi, senza nuove dipendenze esterne.

## Evidenze e revisione finale

Le catture native sono raccolte nella [galleria](evidence/trama-design-review/index.html).
Le sezioni di prova contengono screenshot Simulator; i due raster generati sono
separati e identificati come concept approvati. La galleria distingue
schermate standard, iPad e prove di accessibilità; permette di aprire gli originali.
Il confronto riguarda anatomia e gerarchia dei concept: i pixel delle tavole non fissano
le dimensioni in punti dei controlli Apple.

La copertura locale e i limiti sono registrati nel [QA](../../design-qa.md).
VoiceOver parlato, Voice Control, tastiera/puntatore iPad, aptica e prove su dispositivo
fisico restano verifiche delle milestone pertinenti. Le etichette AX e gli screenshot non
certificano un audit completo di accessibilità né autorizzano Nutrition Labels.

Il Product Owner ha approvato esplicitamente il pacchetto complessivo con «Approvo»
il 5 settembre 2026, dopo la consegna della galleria. L’approvazione riguarda il commit
`1119333b93af80071f67253dbd29f7f14060b562`, verificato con build Dev e pubblica e
75 test verdi in 5 suite. Insieme alle evidenze della fase 1 e alla formalizzazione,
soddisfa i sei requisiti della sezione 48.3 e chiude DG-VISUAL.
E07–E11 richiedono un incarico distinto.
Push, PR, merge, TestFlight, App Store e aggiornamenti di servizi remoti non sono richiesti.
