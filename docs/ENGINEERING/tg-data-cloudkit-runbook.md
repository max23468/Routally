# TG-DATA — runbook CloudKit Development

Questo runbook completa la validazione reale richiesta da `TG-DATA` senza creare asset
definitivi né promuovere lo schema in Production. Tutti i record sono sintetici e il
container è provvisorio e sacrificabile.

## Prerequisiti

1. team iscritto all'Apple Developer Program, configurato in Xcode;
2. due simulatori o dispositivi con lo stesso account iCloud di prova;
3. copia locale non versionata di `Configuration/Local.xcconfig.example` chiamata
   `Configuration/Local.xcconfig`, con il Team ID effettivo;
4. App ID provvisorio `com.temisfera.routally.dev.provisional`;
5. App ID dell'estensione
   `com.temisfera.routally.dev.provisional.tgdatawidget`;
6. App Group `group.com.temisfera.routally.tgdata.provisional` associato a entrambi;
7. container `iCloud.com.temisfera.routally.tgdata.provisional` associato all'app Dev.

Non salvare Apple ID, password, token CloudKit, profili o certificati nel repository.

## Build firmata

Verificare il Team ID senza stamparne credenziali, quindi compilare `Routally Dev` con
firma automatica e `-allowProvisioningUpdates`. Il target pubblico non partecipa alla
prova. Controllare gli entitlement effettivi dell'app e del widget nel prodotto compilato.

Il probe si attiva con:

```text
-tgDataCloudProbe
-tgDataClient client-A
-tgDataSession <UUID condiviso>
```

L'argomento facoltativo `-tgDataAutoAction` accetta `base`, `duplicate`, `revision`,
`tombstone` o `widget` e rende ripetibili le azioni senza interazione manuale.

## Sequenza multi-client

Usare lo stesso UUID di sessione su entrambi i client.

1. Avviare client A con azione `base`; attendere `Varianti evento = 1` sul client B.
2. Mettere client B offline, avviarlo con azione `duplicate` e confermare la scrittura
   locale immediata.
3. Sul client A online eseguire `revision`.
4. Riportare client B online e attendere su entrambi almeno due varianti, una revisione,
   clock risolto `30` e payload della revisione.
5. Sul client A eseguire `tombstone`; attendere su entrambi un tombstone e stato risolto
   assente.
6. Ripetere su un nuovo UUID invertendo l'ordine di client e consegna; l'esito deve essere
   identico.

Ogni attesa ha un limite operativo di cinque minuti. Un timeout è un fallimento da
diagnosticare, non un risultato positivo implicito.

## App Group e widget

1. Avviare l'app con azione `widget`.
2. Aggiungere `TG-DATA Probe` alla Home del client.
3. Attendere che l'app mostri `Confermato dal widget`.
4. Rimuovere e reinstallare soltanto l'app Dev; ripetere il passaggio per verificare che
   l'accesso sia determinato dagli entitlement e non da un percorso locale accidentale.

## Riavvio, reinstallazione e recovery

1. Chiudere e riaprire entrambi i client: lo stato deve restare convergente.
2. Disinstallare l'app dal client B senza eliminare dati dal container CloudKit.
3. Reinstallare la stessa build firmata e riavviare il probe con il medesimo UUID.
4. Attendere il recupero di varianti, revisione e tombstone; lo stato finale deve restare
   nascosto.
5. Verificare che il client A non perda dati e che nessuna azione quotidiana attenda la
   rete.

## Schema Development e percorso di promozione

Dopo la prima sincronizzazione, verificare nel CloudKit Console che lo schema Development
contenga i record type generati da SwiftData. Con `cktool`, usando un management token
solo da Keychain o variabile effimera:

1. esportare lo schema Development del container provvisorio;
2. validare il file esportato contro l'ambiente Production dello stesso container;
3. archiviare nel rapporto soltanto digest, data, esito e versione della toolchain;
4. non importare né promuovere lo schema: la promozione definitiva appartiene a `E21`.

## Criterio di chiusura

`TG-DATA` può passare da Open a **Adapt** soltanto se:

- i due ordini di consegna convergono;
- duplicati, revisioni e tombstone arrivano realmente tramite CloudKit;
- offline, riavvio e reinstallazione recuperano senza perdita o riapparizione;
- app e widget confermano l'App Group reale;
- lo schema Development è inizializzato e il percorso di validazione verso Production è
  verificato;
- log, screenshot e digest non contengono credenziali o dati personali.
