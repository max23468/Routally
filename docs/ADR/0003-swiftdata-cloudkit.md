# ADR 0003 — SwiftData locale e backup lossless

- **Stato:** Confirmed
- **Technical Gate:** `TG-DATA` aperto
- **Data:** 2026-08-05
- **Ambito:** Routally 1.0

## Contesto

La 1.0 deve essere local-first, funzionare offline e offrire un recupero controllabile
senza introdurre subito sincronizzazione multi-device, conflitti CloudKit o adapter per un
backend futuro.

## Decisione

La 1.0 usa uno store SwiftData locale concreto. Il dominio conserva UUID stabili e
funzioni pure dove serve, ma non richiede repository intercambiabili per ogni entità.
Backup lossless versionato, reimportabile e CSV sono le strategie di portabilità e
recupero. CloudKit è rinviato alla 1.1 e avrà un gate dedicato.

## Conseguenze

- le azioni quotidiane scrivono subito in locale;
- schema e migrazioni sono versionati dalla prima release pubblica;
- `TG-DATA` valida transazioni, backup/import, idempotenza e 10.000 eventi;
- 100.000 eventi restano uno stress test esplorativo;
- nessun fallback Core Data o adapter alternativo viene costruito senza un limite
  dimostrato.

## Riferimenti

- Master Plan, sezioni 5, 9 e 10.
- Roadmap, sezione 1.1 «CloudKit e multi-device».
