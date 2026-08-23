# M10 — runbook di validazione CloudKit Development

Questo runbook raccoglie la prova reale rinviata a `M10`. Non serve a chiudere
`TG-DATA`, già chiuso **Adapt** sulle evidenze locali: certifica l'integrazione iCloud
della build Alpha sugli asset Apple definitivi, dopo `DG-DEVELOPER-IDENTITY`.

## Prerequisiti di M10

1. identità dello sviluppatore decisa e `DG-DEVELOPER-IDENTITY` chiuso;
2. iscrizione all'Apple Developer Program attiva;
3. Bundle ID, App Group e container iCloud definitivi intestati all'owner approvato;
4. build Alpha firmata con gli entitlement effettivi;
5. almeno due client di prova con account iCloud controllati e dati sintetici;
6. implementazione `E14` completata e test locali su Simulator verdi.

Nessuno di questi prerequisiti deve essere anticipato in `M01`–`M09`. Non salvare Apple
ID, password, token CloudKit, profili o certificati nel repository.

## Preparazione

- iniettare Bundle ID, App Group, container iCloud e Team ID tramite la configurazione di
  build prevista dal progetto;
- compilare la build Alpha firmata e controllare gli entitlement del prodotto compilato;
- verificare che il target pubblico e le eventuali estensioni usino lo stesso contratto
  dati e soltanto le capability necessarie;
- assegnare a ogni scenario un UUID sintetico condiviso fra i client.

## Sequenza multi-client

1. Sul client A creare un evento base e attenderne la comparsa sul client B.
2. Portare il client B offline, scrivere una variante duplicata e confermare la scrittura
   locale immediata.
3. Sul client A online creare una revisione più recente.
4. Riportare B online e verificare convergenza di varianti, revisione, clock e payload.
5. Sul client A creare un tombstone e verificarne la convergenza su entrambi i client.
6. Ripetere con un nuovo UUID invertendo ordine dei client e ordine di consegna.

Ogni attesa ha un limite operativo di cinque minuti. Un timeout è un fallimento da
diagnosticare, non un risultato positivo implicito.

## App Group e superfici di sistema

1. Scrivere dall'app lo snapshot minimo condiviso.
2. Verificarne la lettura dalla superficie `E13` prevista, senza accesso allo store
   completo se non necessario.
3. Riavviare app ed estensione e verificare coerenza e permessi.
4. Controllare che la build senza iCloud disponibile continui integralmente in locale e
   mostri uno stato comprensibile.

## Riavvio, reinstallazione e recovery

1. Chiudere e riaprire entrambi i client: lo stato deve restare convergente.
2. Disinstallare l'app dal client B senza eliminare i dati dal container CloudKit.
3. Reinstallare la stessa build Alpha e attendere il recupero di eventi, revisioni e
   tombstone.
4. Verificare che il client A non perda dati e che nessuna azione quotidiana attenda la
   rete.
5. Eseguire i fallback per account iCloud assente, quota insufficiente e servizio
   temporaneamente indisponibile.

## Schema Development

Dopo la prima sincronizzazione, verificare nel CloudKit Console che lo schema Development
contenga i record type attesi. Con strumenti Apple e credenziali ottenute solo da
Keychain o variabili effimere:

1. esportare lo schema Development del container definitivo;
2. archiviare nel rapporto soltanto digest, data, esito e versione della toolchain;
3. controllare che la futura promozione sia compatibile con il piano di migrazione;
4. non promuovere lo schema: promozione e verifica Production appartengono a `E21` / `M11`.

## Criterio di accettazione M10

- i due ordini di consegna convergono;
- duplicati, revisioni e tombstone arrivano realmente tramite CloudKit;
- offline, riavvio e reinstallazione recuperano senza perdita o riapparizione;
- app e superficie di sistema confermano l'App Group firmato;
- fallback iCloud e recovery sono comprensibili e non bloccano l'uso locale;
- lo schema Development è inizializzato e documentato;
- log, screenshot e digest non contengono credenziali o dati personali.
