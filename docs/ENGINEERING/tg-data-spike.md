# TG-DATA — rapporto di chiusura

- **Stato:** Closed
- **Esito:** Adapt
- **Data:** 2026-08-23
- **Milestone:** `M01` Foundation
- **Evidence target:** `RoutallyDataSpike` e `TGDataTests`

## Decisione

SwiftData con sincronizzazione CloudKit resta la tecnologia confermata. Lo spike non ha
evidenziato limiti che giustifichino il fallback Core Data. L'approccio viene adattato in
tre punti vincolanti per `E05` ed `E14`:

1. UUID di dominio e deduplica applicativa, senza `@Attribute(.unique)`, perché lo schema
   deve restare compatibile con CloudKit;
2. riferimenti tramite UUID scalari e proprietà con valori di default, evitando relazioni
   obbligatorie che renderebbero fragile la sincronizzazione;
3. identificativi App Group e container CloudKit iniettati dalla configurazione, così il
   passaggio dagli asset provvisori a quelli definitivi non crea un secondo schema o un
   secondo contratto di store.

Il target dello spike è collegato soltanto ai test. L'app, la UI e `RoutallyDomain` non
dipendono da SwiftData: l'integrazione di produzione appartiene a `E05`.

## Evidenze

| Criterio `TG-DATA` | Evidenza | Esito |
|---|---|---|
| Event store | ingestione idempotente per UUID, inclusi duplicati nello stesso batch | Superato |
| Dataset di riferimento | 50 routine attive, 200 archiviate, 10.000 eventi, 100 link e 500 follow-up, più revisioni e tombstone | Superato |
| App Group / widget | due client riaprono lo stesso store e condividono uno snapshot widget compatto; gli identificativi App Group sono configurabili | Superato localmente |
| Offline | scrittura e lettura usano una configurazione locale con CloudKit disattivato e non richiedono rete | Superato |
| Multi-device | batch equivalenti consegnati in ordini opposti convergono allo stesso stato risolto | Superato deterministicamente |
| Revisioni / tombstone | prevalenza deterministica per clock, data e UUID; il tombstone più recente nasconde l'evento | Superato |
| Migrazioni | store V1 su disco riaperto tramite `SchemaMigrationPlan` V1→V2 senza perdita dell'evento | Superato |
| Container provvisorio → definitivo | cambia soltanto la configurazione degli identificativi; versione dello schema e store contract restano identici | Superato |
| CloudKit Production schema | configurazioni private CloudKit e relativi schemi superano `ModelConfiguration.validate()` | Superato come fattibilità locale |
| Recovery | chiusura e riapertura dello store su disco conserva il registro canonico | Superato |

## Confine della validazione

Lo spike non crea container, App Group o schemi negli account Apple e non effettua una
sincronizzazione CloudKit reale. Queste sono operazioni remote legate agli asset Apple:

- `E14` / `M06` valida iCloud Development, conflitti e recovery fra dispositivi;
- dopo `DG-DEVELOPER-IDENTITY` vengono sostituiti gli identificativi provvisori con quelli
  definitivi;
- `E21` / `M11` promuove e verifica lo schema CloudKit Production prima della beta esterna.

Queste verifiche operative non riaprono la scelta di persistenza, ma restano gate delle
milestone che le possiedono. Un errore riproducibile di SwiftData/CloudKit in quelle fasi
richiede un nuovo ADR prima di valutare il fallback.

## Verifiche eseguite

- `Routally Tests` su iPhone 17 Pro, iOS 26.5: 32 test superati, 0 falliti;
- build Simulator dei target `Routally` e `Routally Dev` completate senza errori;
- il test del dataset canonico è incluso nella suite completa;
- `ModelConfiguration.validate()` sulle configurazioni provvisoria e definitiva.

## Conseguenze per le epiche successive

- `E04` definisce eventi, revisioni, reducer e invarianti senza importare SwiftData;
- `E05` trasforma il modello esplorativo in schema locale V1 e store di produzione;
- `E13` espone al widget soltanto il reader dello snapshot necessario;
- `E14` aggiunge la sincronizzazione CloudKit reale e gli stati iCloud visibili;
- cache e indici persistenti restano vietati finché una misura non ne dimostra la necessità.
