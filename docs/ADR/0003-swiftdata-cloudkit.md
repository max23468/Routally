# ADR 0003 — SwiftData e CloudKit

- **Stato:** Confirmed
- **Technical Gate:** `TG-DATA` aperto — Adapt candidato
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

## Evidenza TG-DATA

Lo spike locale supporta un esito candidato Adapt con UUID e deduplica applicativi,
riconciliazione dei duplicati già persistiti, nessun vincolo unique, riferimenti UUID
scalari, proprietà con default e identificativi App Group/CloudKit iniettati dalla
configurazione. Migrazione locale, offline, recovery su disco, dataset realistico,
revisioni, tombstone e convergenza simulata a ordini diversi sono coperti da test.

Il gate non è chiuso: prima di `E05` deve ancora validare un container CloudKit
provvisorio, sincronizzazione e recovery fra client reali e inizializzazione dello schema.
La promozione dello schema definitivo Production resta in `E21`, dopo gli asset Apple
previsti da `DG-DEVELOPER-IDENTITY`. Rapporto completo: `docs/ENGINEERING/tg-data-spike.md`.

## Riferimenti

- Master Plan, sezioni 21, 25.6 e 40.1.
