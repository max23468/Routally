# TG-DATA — rapporto di validazione locale

- **Stato:** Open
- **Esito candidato:** Adapt
- **Data:** 2026-08-23
- **Milestone:** `M01` Foundation
- **Evidence target:** `RoutallyDataSpike` e `TGDataTests`

## Decisione

La validazione locale non ha evidenziato limiti che giustifichino il fallback Core Data e
supporta un esito candidato Adapt per SwiftData/CloudKit. Il gate resta aperto finché le
prove su un container CloudKit provvisorio non coprono sincronizzazione, duplicati
materializzati dal framework, recovery fra dispositivi e schema. L'approccio candidato
prevede tre adattamenti vincolanti:

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
| Event store | ingestione idempotente e riconciliazione per UUID, inclusi duplicati nello stesso batch o già materializzati nello store | Superato localmente |
| Dataset di riferimento | 50 routine attive, 200 archiviate, 10.000 eventi, 100 link e 500 follow-up, più revisioni e tombstone | Superato |
| App Group / widget | due client riaprono lo stesso store locale e condividono uno snapshot widget compatto; gli identificativi App Group sono configurabili | Parziale: manca l'entitlement reale |
| Offline | scrittura e lettura usano una configurazione locale con CloudKit disattivato e non richiedono rete | Superato |
| Multi-device | batch equivalenti consegnati in ordini opposti convergono allo stesso stato risolto | Parziale: simulazione deterministica |
| Revisioni / tombstone | prevalenza deterministica per clock, data e UUID; il tombstone più recente nasconde l'evento | Superato |
| Migrazioni | store V1 su disco riaperto tramite `SchemaMigrationPlan` V1→V2 senza perdita dell'evento | Superato |
| Container provvisorio → definitivo | cambia soltanto la configurazione degli identificativi; versione dello schema e store contract restano identici | Parziale: configurazione locale |
| CloudKit Production schema | configurazioni private CloudKit e relativi schemi superano `ModelConfiguration.validate()` | Non verificato sul servizio |
| Recovery | chiusura e riapertura dello store su disco conserva il registro canonico | Superato |

## Confine della validazione

Lo spike non crea container, App Group o schemi negli account Apple e non effettua una
sincronizzazione CloudKit reale. Di conseguenza `TG-DATA` e `M01` restano aperti. Per
chiudere il gate prima di avviare `E05` servono, su asset provvisori e sacrificabili:

- App Group ed entitlements effettivi per app e client widget di prova;
- sincronizzazione CloudKit Development fra almeno due simulatori o dispositivi;
- import di duplicati, consegne fuori ordine, revisioni e tombstone materializzati da
  SwiftData/CloudKit;
- disconnessione, riavvio, reinstallazione controllata e recovery;
- inizializzazione dello schema CloudKit e verifica del percorso di promozione.

Dopo la chiusura del gate, `E14` completerà l'esperienza iCloud di prodotto; dopo
`DG-DEVELOPER-IDENTITY`, gli identificativi provvisori saranno sostituiti con quelli
definitivi; `E21` promuoverà e verificherà lo schema Production prima della beta esterna.

## Verifiche eseguite

- `Routally Tests` su iPhone 17 Pro, iOS 26.5: 35 test superati, 0 falliti;
- build Simulator dei target `Routally` e `Routally Dev` completate senza errori;
- il test del dataset canonico è incluso nella suite completa;
- `ModelConfiguration.validate()` sulle configurazioni provvisoria e definitiva.

## Preparazione della prova CloudKit reale

Il 23 agosto 2026 è stato aggiunto a `Routally Dev` un probe ripetibile che usa lo stesso
schema dello spike, il container provvisorio
`iCloud.com.temisfera.routally.tgdata.provisional` e l'App Group provvisorio
`group.com.temisfera.routally.tgdata.provisional`. Il probe:

- espone scritture separate di evento base, duplicato, revisione e tombstone;
- mostra varianti materializzate e stato risolto per una sessione sintetica;
- accetta launch arguments per eseguire lo stesso scenario su client distinti;
- incorpora un widget tecnico Dev che legge l'input e scrive un acknowledgement nello
  stesso App Group;
- lascia il target pubblico senza capability o dipendenze dallo spike.

La build e l'avvio sul Simulator hanno verificato il funzionamento locale del probe e la
creazione del container App Group. CloudKit ha correttamente mantenuto lo store locale ma
ha riportato `CKAccountStatusNoAccount`, perché il simulatore non contiene un account
iCloud. Inoltre Xcode dispone al momento soltanto di un `Personal Team`: secondo la
[matrice Apple delle capability iOS](https://developer.apple.com/help/account/reference/supported-capabilities-ios/),
la prova di CloudKit e App Groups con provisioning reale richiede un team iscritto
all'Apple Developer Program.

Il gate non viene chiuso con questa evidenza. Il runbook ripetibile e i prerequisiti
restanti sono in `docs/ENGINEERING/tg-data-cloudkit-runbook.md`.

## Conseguenze per le epiche successive

- `E04` può definire eventi, revisioni, reducer e invarianti senza importare SwiftData;
- `E05` resta bloccata finché `TG-DATA` non è chiuso con evidenze CloudKit reali;
- `E13` espone al widget soltanto il reader dello snapshot necessario;
- `E14` aggiunge la sincronizzazione CloudKit reale e gli stati iCloud visibili;
- cache e indici persistenti restano vietati finché una misura non ne dimostra la necessità.
