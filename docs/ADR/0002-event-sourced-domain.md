# ADR 0002 — Journal eventi e reducer essenziale

- **Stato:** Confirmed
- **Data:** 2026-08-05
- **Ambito:** Routally 1.0

## Contesto

Una registrazione può aggiornare più obiettivi e cicli, generare follow-up e venire
corretta o eliminata. Serve uno storico affidabile, ma CloudKit e il comportamento
distribuito sono rinviati alla 1.1 e non giustificano una piattaforma event-sourced nella
1.0.

## Decisione

Le registrazioni vivono in un journal con identificativi stabili. Un reducer di dominio
deterministico calcola gli effetti diretti e aggiorna journal e stato corrente nella stessa
transazione SwiftData. Correzioni ed esclusioni ricalcolano soltanto le routine coinvolte.
Non esistono proiettori generici, snapshot materializzati o Consistency Engine.

## Conseguenze

- correzioni e annullamenti producono risultati deterministici;
- gli input ripetuti sono idempotenti;
- le invarianti critiche hanno test automatici;
- proiezioni e replay completo verranno valutati soltanto con misure o CloudKit attivo.

## Riferimenti

- Master Plan, sezioni 4, 5 e 10.
