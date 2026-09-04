# ADR-0008 — Schema locale V1, payload V2 e confine transazionale dello store

- **Stato:** Confirmed
- **Data:** 2026-08-27
- **Ambito:** E05 — Local Persistence Foundation

## Contesto

E04 ha stabilito il registro canonico e il reducer deterministico senza dipendere da
SwiftData. `TG-DATA` ha chiuso con esito Adapt la scelta SwiftData/CloudKit, imponendo UUID
di dominio, deduplica applicativa, riferimenti UUID scalari, proprietà con default e
identificativi Apple iniettati. Lo spike isolato non era però uno store di prodotto e
duplicava modelli dimostrativi non collegati ai tipi di dominio.

## Decisione

La persistenza locale di prodotto vive nel modulo `RoutallyData`, che dipende soltanto da
`RoutallyDomain`. Il confine pubblico `RoutallyStore` è asincrono e `Sendable`; la sua
implementazione `SwiftDataRoutallyStore` conforma a `ModelActor`, usa il serial executor
di SwiftData e non usa il `MainActor`. La configurazione è sempre esplicita: anche i test
devono richiedere intenzionalmente lo store in-memory, così il chiamante di prodotto non
può ottenere per omissione una persistenza effimera.

Lo schema locale `RoutallySchemaV1` è formalmente versionato e contiene sei famiglie di
record:

1. routine;
2. collegamenti diretti;
3. definizioni dei cicli;
4. eventi;
5. revisioni degli eventi;
6. tombstone degli eventi.

Ogni record conserva gli UUID e i campi necessari alla selezione come valori scalari, una
versione esplicita del payload e il valore di dominio completo come payload `Codable`. Una
versione sconosciuta viene rifiutata prima della decodifica, così una futura evoluzione del
formato deve dichiarare la propria migrazione. I modelli SwiftData non attraversano il
confine del modulo e non vengono esposti al dominio o alla UI. Non si usa
`@Attribute(.unique)`: i retry identici vengono deduplicati applicativamente, mentre
varianti con lo stesso UUID restano disponibili al criterio deterministico del registro.

E06 modifica intenzionalmente il payload `Codable` delle routine prima che esistano utenti
o store distribuiti. Il payload applicativo passa quindi a V2 e l'app apre il nuovo file
`Routally-v2.store`: l'eventuale file pre-release V1 resta intatto ma non viene consumato.
Non viene aggiunto un decoder legacy né uno stage di migrazione artificiale; un payload V1
aperto esplicitamente viene rifiutato prima della decodifica. Lo schema fisico SwiftData
resta V1 perché le famiglie e i campi scalari dei record non cambiano.

Il catalogo corrente viene sostituito come insieme completo; eventi, revisioni e tombstone
sono append-only. Un commit:

1. carica il registro canonico;
2. applica la deduplica esatta;
3. valida il catalogo e ricalcola lo stato completo fuori dal `MainActor`;
4. controlla la cancellazione;
5. esegue un solo salvataggio SwiftData.

Lo snapshot restituito espone soltanto catalogo, registro canonico e stato ricalcolato.
Non propaga liste di routine interessate: nessun consumer esegue ricalcoli parziali o usa
questa informazione, quindi lo store mantiene un unico percorso di ricalcolo completo.

Un errore di validazione, ricalcolo, codifica o salvataggio non persiste parti della
modifica. Lo stato derivato non viene salvato: resta riproducibile dal catalogo e dal
registro. Cache, indici e repair engine richiedono una misura successiva.

`RoutallyMigrationPlan` nasce con lo schema V1 e nessuno stage artificiale. Una futura
evoluzione aggiungerà il nuovo schema e una migrazione esplicita senza inventare una
versione precedente mai distribuita. Le configurazioni in-memory, su file e
App Group/CloudKit condividono lo stesso schema; gli identificativi Apple restano
iniettati e nessun asset remoto viene creato in E05.

## Conseguenze

- Lo spike `RoutallyDataSpike` viene assorbito e rimosso; le garanzie pertinenti a E05
  restano coperte dalle regressioni `E05PersistenceTests` sul modulo di prodotto. Il
  reader compatto del widget appartiene a E13 e il primo stage di migrazione reale verrà
  aggiunto insieme alla prima evoluzione dello schema.
- E06 può integrare un flusso reale attraverso `RoutallyStore` senza importare SwiftData
  nelle feature.
- E14 aggiungerà gli stati iCloud e l'integrazione CloudKit locale; M10 conserverà la prova
  reale su App Group e container Development definitivi.
- La promozione dello schema CloudKit Production resta in E21/M11.

## Riferimenti

- Master Plan, sezioni 16, 21, 25, 35, 36 e 40.
- ADR-0002 e ADR-0003.
- `docs/ENGINEERING/tg-data-spike.md`.
