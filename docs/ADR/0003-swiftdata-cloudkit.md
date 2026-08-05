# ADR 0003 — SwiftData e CloudKit

- **Stato:** Accepted, validation pending
- **Data:** 2026-08-05
- **Ambito:** Routally 1.0

## Contesto

La 1.0 deve essere local-first, funzionare offline, sincronizzare dati privati tramite
iCloud e non dipendere da account Routally, backend o runtime esterni.

## Decisione

L'adapter predefinito usa SwiftData, App Group e CloudKit. Il dominio dipende da
repository protocol e UUID propri, non da modelli SwiftData o identificatori persistenti.

## Conseguenze

- le azioni quotidiane scrivono subito in locale e non attendono CloudKit;
- schema e migrazioni sono versionati dalla prima release;
- widget e app condividono proiezioni tramite App Group;
- `TG-DATA` deve validare event store, migrazioni, offline, sync e 100.000 eventi;
- se il gate fallisce, cambia soltanto l'adapter, preferibilmente verso Core Data con
  `NSPersistentCloudKitContainer`.

## Riferimenti

- Master Plan, sezioni 21, 25.6 e 40.1.
