# TG-DATA — rapporto di validazione locale

- **Stato:** Closed
- **Esito:** Adapt
- **Data:** 2026-08-23
- **Milestone:** `M01` Foundation
- **Evidence target:** spike storico, poi regressioni `RoutallyData` ed
  `E05PersistenceTests`

## Decisione

La validazione locale non ha evidenziato limiti che giustifichino il fallback Core Data.
`TG-DATA` è quindi chiuso con esito **Adapt** per SwiftData/CloudKit. L'esito vincola la
persistenza a tre adattamenti:

1. UUID di dominio e deduplica applicativa, senza `@Attribute(.unique)`, per mantenere lo
   schema compatibile con CloudKit;
2. riferimenti tramite UUID scalari e proprietà con valori di default, evitando relazioni
   obbligatorie fragili durante la sincronizzazione;
3. identificativi App Group e container CloudKit iniettati dalla configurazione, senza
   incorporare nello schema asset Apple provvisori.

E05 ha assorbito il target isolato nel modulo di prodotto `RoutallyData`, rimuovendo la
duplicazione dimostrativa. L'app, la UI e `RoutallyDomain` continuano a non dipendere da
SwiftData; le garanzie pertinenti alla persistenza E05 vengono ora rieseguite sullo store
reale. Il reader compatto del widget resta in E13 e il primo stage di migrazione di
prodotto verrà introdotto soltanto con una seconda versione reale dello schema.

## Evidenze

| Criterio `TG-DATA` | Evidenza | Esito |
|---|---|---|
| Event store | ingestione idempotente e riconciliazione per UUID, inclusi duplicati nello stesso batch, già materializzati nello store o ricevuti in merge separati | Superato |
| Dataset di riferimento | 50 routine attive, 200 archiviate, 10.000 eventi, 100 link e 500 follow-up, più revisioni e tombstone | Superato |
| Contratto App Group/widget | lo spike storico ha verificato due client sullo stesso store; E05 mantiene configurazione e riapertura condivise, mentre il reader compatto appartiene a E13 | Superato localmente |
| Offline | scrittura e lettura usano una configurazione locale con CloudKit disattivato e non richiedono rete | Superato |
| Convergenza multi-client | batch equivalenti consegnati insieme o separatamente e in ordini opposti convergono allo stesso stato risolto | Superato localmente |
| Revisioni/tombstone | prevalenza deterministica per clock, data e UUID; una revisione obsoleta non sostituisce un evento più recente; il tombstone più recente nasconde l'evento | Superato |
| Migrazioni | lo spike storico ha verificato V1→V2; il prodotto nasce da V1 con `SchemaMigrationPlan` esplicito, riapertura su disco e nessuno stage artificiale prima di una seconda versione reale | Superato |
| Configurazione futura | il cambio degli identificativi non modifica versione dello schema o contratto dello store | Superato localmente |
| Recovery | chiusura e riapertura dello store su disco conserva il registro canonico | Superato |

## Confine della decisione

Lo spike chiude l'incertezza architetturale necessaria per avviare `E05`; non certifica il
funzionamento del servizio CloudKit. Non crea container, App Group, profili o schemi negli
account Apple e non richiede l'iscrizione a pagamento all'Apple Developer Program.

`E14` implementerà in `M06` l'integrazione iCloud e le relative strategie di conflitto e
recovery, verificandole localmente su Simulator. In `M10`, dopo
`DG-DEVELOPER-IDENTITY`, la build Alpha userà gli asset Apple definitivi per verificare
realmente CloudKit Development, App Group, multi-client, offline, riavvio,
reinstallazione, recovery e schema. `E21` promuoverà e verificherà lo schema Production
prima della beta esterna.

Il runbook differito è in `docs/ENGINEERING/tg-data-cloudkit-runbook.md`.

## Verifiche eseguite

- `Routally Tests` su iPhone 17 Pro, iOS 26.5: 35 test superati, 0 falliti;
- build Simulator dei target `Routally` e `Routally Dev` completate senza errori;
- dataset canonico incluso nella suite completa;
- `ModelConfiguration.validate()` sulle configurazioni locali previste.

## Conseguenze per le epiche successive

- `E04` può definire eventi, revisioni, reducer e invarianti senza importare SwiftData;
- `E05` applica gli adattamenti stabiliti dal gate nello schema locale V1 e nel confine
  transazionale dello store;
- `E13` espone al widget soltanto il reader dello snapshot necessario;
- `E14` implementa la sincronizzazione e gli stati iCloud senza anticipare asset Apple;
- cache e indici persistenti restano vietati finché una misura non ne dimostra la necessità.
