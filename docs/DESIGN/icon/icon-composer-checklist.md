# Checklist Icon Composer e dispositivi

Questa checklist è il passaggio manuale obbligatorio fra gli SVG versionati e la chiusura di
`DG-ICON`. Icon Composer richiede **macOS Tahoe 26.4 o successivo**. La verifica va eseguita
con la versione corrente dello strumento e di Xcode disponibile al momento della prova.

## Preparazione

- Registrare data, Mac, versione di macOS, Icon Composer e Xcode.
- Rigenerare gli asset e completare il controllo una tantum indicato in
  [validation-plan.md](validation-plan.md).
- Usare i file di `composer-layers/`, non i gruppi interni agli SVG combinati.
- Importare almeno A1, A3 e T1; per il confronto di rifinitura importare anche le quattro
  varianti A1 presenti in `experiments/`.
- Mantenere tela, posizione e scala comuni a tutti i livelli di una stessa variante.

## Import dei livelli

Per ciascuna variante:

1. creare un documento 1024 × 1024;
2. impostare il fondo dal livello `background` oppure, se Icon Composer lo richiede,
   ricrearlo con lo stesso valore sRGB;
3. importare `symbol`, poi `accent`; per la build Dev importare infine `overlay`;
4. verificare che ogni file diventi un artwork separato e non venga appiattito;
5. controllare che la posizione coincida con lo SVG combinato;
6. annotare eventuali differenze, warning o conversioni effettuate dallo strumento.

## Materiali e modi di rendering

Configurare e salvare esplicitamente:

- **Default**;
- **Dark**;
- **Mono**.

Per ciascun modo verificare tutte le rese disponibili nel pannello di anteprima, comprese
Default, Dark, Clear light, Clear dark, Tinted light e Tinted dark. Gli SVG piatti non
anticipano rifrazione, frostiness, ombre, highlight speculari o adattamento allo sfondo.

Controlli specifici:

- l'inizio sottile dell'arco non deve sparire o diventare rumore;
- la testa terminale non deve sembrare una macchia o un secondo pulsante;
- simbolo e accento devono restare distinguibili in Mono;
- nessun materiale deve chiudere otticamente il contatore o alterarne il centraggio;
- A1 deve restare leggibile senza richiedere T1 come sostituzione automatica;
- la fascia Dev deve essere visibile senza coprire fianco, gamba o accento.

## Confronto obbligatorio

Usare lo stesso sfondo e la stessa scala per confrontare:

| Confronto | Varianti |
|---|---|
| Direzione | A1, A3, T1 |
| Testa terminale | raggio 54, raggio 50 |
| Accento | Lavender, Amber |
| Combinazione | 54/Lavender, 50/Lavender, 54/Amber, 50/Amber |
| Aspetti | Default, Dark, Mono |
| Misure | 180, 120, 60, 40 e 29 pt |

La scelta non va effettuata sulla sola anteprima grande.

## Salvataggio e Xcode

- Salvare il documento come file `.icon` in una posizione versionabile del repository.
- Trascinare il file `.icon` nel progetto Xcode.
- Selezionarlo come app icon nel Project Editor per il target pubblico.
- Creare o selezionare la derivata Dev per il target `Routally Dev`.
- Non aggiungere PNG duplicati se il flusso `.icon` funziona correttamente.
- Eseguire build pulite di entrambi i target.
- Verificare che archiviazione, bundle e catalogo compilato contengano l'icona attesa.

## Prova su dispositivi

Eseguire almeno su un iPhone e un iPad compatibili con iOS/iPadOS 26:

- Home Screen su sfondo chiaro, scuro e fotografico;
- App Library e ricerca Spotlight;
- Impostazioni;
- notifiche;
- selettori o elenchi di sistema che mostrano l'icona;
- modalità Default, Dark, Clear e Tinted disponibili sul dispositivo;
- Riduci trasparenza e Aumenta contrasto, quando incidono sulla resa del contesto.

Per ogni contesto conservare screenshot non ritagliati e indicare modello, sistema, modo di
rendering e variante. Le tavole in `evidence/` sono simulazioni vettoriali e non sostituiscono
questa prova.

## Esito

La checklist è superata soltanto quando:

- non esistono difetti bloccanti a 29 o 40 pt;
- la stessa variante funziona su iPhone e iPad;
- Default, Dark e Mono non richiedono una diversa struttura di base;
- il risultato dello user test è coerente con routine, ciclo o progresso e non con routing,
  rete o sincronizzazione;
- il [decision record](decision-record.md) contiene evidenze e approvazione finale.
