# TG-RECALC — ricalcolo retroattivo deterministico

**Stato:** chiuso

**Esito:** Async boundary

**Data:** 2026-08-26

## Decisione

Il reducer di dominio resta puro e sincrono. Il confine applicativo di ricalcolo è invece
asincrono, cancellabile e fuori dal `MainActor`: restituisce uno stato immutabile soltanto
al termine e non espone né persiste risultati parziali.

Non vengono introdotti cache, proiezioni persistenti o repair engine. E05 potrà persistere
il registro canonico e applicare il risultato completo in una singola transazione.

## Dataset e misure

La fixture canonica copre 250 routine, 10.000 eventi, 100 collegamenti, 500 cicli e
follow-up, 500 revisioni e 100 tombstone. Su iPhone 17 Pro Simulator in configurazione
Development, le esecuzioni osservate del dataset completo sono rimaste tra 1,1 e 1,5
secondi. Sono misure di sviluppo utili alla scelta del confine, non un budget prestazionale
da Release Candidate o da dispositivo reale.

## Evidenze

I test `DomainEngineTests` e `TGRecalcTests` verificano:

- uguaglianza dello stato su replay ripetuto e ordine di consegna invertito;
- tie-break deterministico per conflitti a clock identico;
- composizione ordinata di correzioni parziali e rimozione tramite tombstone;
- propagazione diretta alle sole routine dipendenti, senza catene multilivello;
- rimozione, conservazione e rigenerazione dei follow-up secondo le esclusioni;
- idempotenza di retry e doppio tap;
- cancellazione senza restituzione di uno stato parziale;
- esecuzione del ricalcolo fuori dal `MainActor`.

## Vincoli residui

TG-RECALC chiude la scelta architetturale per E04. Restano a E05 la transazione SwiftData,
la persistenza del registro e il collegamento con la strategia UUID/deduplica di TG-DATA;
le soglie prestazionali su Release Candidate e device restano quelle della sezione 36 del
Master Plan.
