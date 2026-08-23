# ADR 0003 — SwiftData e CloudKit

- **Stato:** Confirmed
- **Technical Gate:** `TG-DATA` aperto
- **Data:** 2026-08-05
- **Ambito:** Routally 1.0

## Contesto

La 1.0 deve essere local-first, funzionare offline, sincronizzare dati privati tramite
iCloud e non dipendere da account Routally, backend o runtime esterni.

## Decisione

La persistenza usa SwiftData, App Group e CloudKit. Il dominio dipende da un unico confine
di store e da UUID propri, non da modelli SwiftData o identificatori persistenti. Non si
predispongono adapter per il backend ipotetico della 2.0.

## Conseguenze

- le azioni quotidiane scrivono subito in locale e non attendono CloudKit;
- schema e migrazioni sono versionati dalla prima release;
- widget e app condividono soltanto i dati o gli indici necessari tramite App Group;
- `TG-DATA` deve validare registro eventi, migrazioni, offline, sync e il dataset realistico della sezione 36;
- se il gate dimostra un limite bloccante, si valuta Core Data con
  `NSPersistentCloudKitContainer`.

## Riferimenti

- Master Plan, sezioni 21, 25.6 e 40.1.
