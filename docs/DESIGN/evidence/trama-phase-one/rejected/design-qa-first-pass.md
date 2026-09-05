# Trama Fase 1 — Verifica del prototipo nativo

Verifica: 4–5 settembre 2026. Ambito: Oggi, dettaglio Routine, riepilogo delle conseguenze.
**final result: blocked** — il Product Owner ha respinto l’allineamento al concept.
La prima valutazione ha accettato troppi scostamenti come adattamenti nativi: va corretta.
Restano da riallineare filo causale continuo, progresso, tipografia, pulsante e spaziature.

## Evidenze e normalizzazione

Directory: `docs/DESIGN/evidence/trama-phase-one/`.

- Source visual truth: `00-target-approved.png`, concept 3 con Registra satinato approvato.
- Implementazione: `01-oggi-light.png`, iPhone 17 Pro, iOS 26.5, italiano, fixture
  `connectedGymCycle` in memoria; Palestra 1/3 e Asciugamano 3/4, anteprima aperta.
- Sorgente: 852 × 1846 px. Screenshot iPhone: 1206 × 2622 px, viewport nativo 402 × 874 pt,
  densità 3×. Non esiste un viewport CSS. Il concept raster non ha una densità dichiarata.
- `comparison-full.png`: entrambi gli screenshot nello stesso artefatto, ridotti alla
  medesima larghezza di 394 px preservando le proporzioni; nessuna deformazione dei contenuti.
- `comparison-module.png`: ritagli del modulo (source x34/y330/x818/y1088,
  implementazione x48/y648/x1158/y1720), affiancati alla medesima larghezza di 400 px.
  Questo confronto permette di leggere tipografia, pulsante, progresso e conseguenze.
- Il concept non include la status bar di iOS e usa una data e righe illustrative.
  La build mantiene safe area, navigazione e classificazione temporale native. Il confronto
  non viene quindi presentato come sovrapposizione pixel-perfect dello stesso contenuto.

## Iterazioni e correzioni

| Priorità | Osservazione iniziale | Correzione | Evidenza dopo la correzione |
| --- | --- | --- | --- |
| P2 | Registra andava sotto il titolo anche a dimensione standard | HStack flessibile standard, VStack alle dimensioni accessibili | `01-oggi-light.png`, confronto modulo; prima: `iteration01-button-layout.jpg` |
| P2 | Seconda superficie grande duplicava visivamente la conseguenza | Superficie evidenziata per la sorgente collegata, riga leggera per la routine collegata, sempre raggiungibile | `comparison-full.png` |
| P1 | Testo bianco sul pulsante indaco chiaro in dark mode | Testo adattivo bianco/nero; contrasto teorico dei token 6,61:1 light e 9,51:1 dark | `04-oggi-dark.png`, `05-oggi-dark-ax5-contrast.png` |
| P2 | L’esclusione era indicata dal solo simbolo meno | Testo localizzato «Conseguenza esclusa» esposto anche nell’albero AX | `10-ipad-esclusione-dark.png`, video del flusso iPhone |
| P2 | Header trasparente fissato sopra i testi durante lo scroll AX5 | Sezioni native insetGrouped senza quel comportamento di pinning | `05-oggi-dark-ax5-contrast.png`; prima: `iteration02-pinned-header.png` |
| P2 | Il testo sorgente dell’anteprima si troncava ad AX5 e i simboli sottraevano troppo spazio | Altezza libera del testo, simboli decorativi limitati e allineati in alto | `05-oggi-dark-ax5-contrast.png`, `06-conseguenze-dark-ax5.png`; prima: `iteration03-preview-truncation.png` |

Dopo le correzioni sono stati acquisiti e aperti sia il confronto completo sia quello del
modulo. Non restano sovrapposizioni, troncamenti dell’anteprima o controlli irraggiungibili
nelle geometrie provate. Le righe lunghe ad AX5 vanno a capo e si leggono scorrendo.

## Cinque superfici di fedeltà

- **Tipografia:** San Francisco e stili semantici SwiftUI, titolo semibold e contesti
  secondari; nessuna sostituzione con font web. Corpo e controlli sono più grandi del raster
  generato per mantenere la dimensione nativa e Dynamic Type. È un adattamento esplicito.
- **Spaziatura:** modulo unico arrotondato, sorgente e azione affiancate, progresso e
  conseguenze nello stesso contenitore. La riga secondaria ha peso inferiore. Status bar,
  sezioni temporali e tab bar spiegano lo scostamento verticale dal concept.
- **Colori:** indaco del brand, superficie opaca adattiva, testo neutro; Registra non usa
  riflessi glassProminent. In dark e con contrasto aumentato i testi del pulsante restano
  leggibili. I colori non sono l’unico mezzo per distinguere stati ed esclusioni.
- **Asset e simboli:** SF Symbols provenienti dalla configurazione delle routine, con
  contenitori uniformi; nessuna illustrazione generata o finta schermata nell’app. Il glyph
  della fixture Palestra e il simbolo del follow-up differiscono dal raster, coerentemente
  con il vincolo Apple nativo e con la configurazione effettiva. Le immagini di questa
  cartella sono documentazione, non asset di produzione.
- **Copy e dati:** anteprima e risultato provengono dallo stesso reducer. «Al rientro a casa»
  indica un momento futuro. La fixture compare in Questa settimana; Camminata e Lettura del
  concept non vengono aggiunte artificialmente. Il progresso usa una barra nativa continua
  con valore testuale, invece dei tre punti decorativi del concept.

Questi adattamenti sono dichiarati e saranno parte della revisione del prototipo reale da
parte del proprietario; il presente esito non implica che siano stati approvati singolarmente.

## Matrice e interazioni

| Prova | Evidenza/esito |
| --- | --- |
| iPhone, Oggi light/dark | `01-oggi-light.png`, `04-oggi-dark.png` |
| iPhone, dettaglio | `02-dettaglio-light.png` |
| iPhone, riepilogo espanso | `03-conseguenze-light.png` |
| iPhone, dark + AX5 + contrasto aumentato, scroll completo | `05-oggi-dark-ax5-contrast.png`, `06-conseguenze-dark-ax5.png` |
| iPad Pro 11 M5, Oggi e navigazione a colonne | `07-ipad-oggi-light.png`, `08-ipad-dettaglio-light.png` |
| iPad, registrazione dal dettaglio e riepilogo | `09-ipad-conseguenze.png` |
| iPad, esclusione e dark | `10-ipad-esclusione-dark.png` |
| Espansione/compressione, dettaglio, Registra, Escludi, Annulla su iPhone | Video locale `routally-trama-flow.mp4`; ripristino 1/3 e anteprima 3/4 → 4/4 osservato |
| Integrità dell’anteprima | Suite esistente VerticalSliceTests: nessuna scrittura, parità con reducer, undo, reset, italiano/inglese |

Video locale: `/Users/Matteo/.codex/visualizations/2026/09/04/01a06e4b-24c6-7860-82cf-a889d3af2861/routally-trama-flow.mp4`.
Le schermate iPad del dettaglio/riepilogo sono state raccolte prima degli ultimi affinamenti
AX5 dei simboli; Oggi iPad è stata ricatturata con il codice finale. Nessun cambiamento alle
operazioni di registrazione/esclusione/annullamento è intervenuto fra le acquisizioni.

## Limiti e osservazioni

- Nella prima sessione iPad molto lenta la registrazione ha aggiornato i dati senza rendere
  subito visibile il riepilogo. Il caso non si è riprodotto in due prove successive,
  inclusa la prima registrazione dopo un riavvio pulito. Non si dichiara una correzione di
  causa non identificata: conservare questa osservazione nella prossima prova manuale.
- Gli snapshot di XcodeBuildMCP non esponevano in modo affidabile i target e talvolta non
  si stabilizzavano. Sono stati usati screenshot reali e albero AX del Simulator con CUA;
  le azioni di scorrimento AX hanno verificato il contenuto completo.
- Etichette AX verificate; percorso VoiceOver parlato e feedback aptico da provare su
  dispositivo fisico. Reduce Motion è rispettato dal ramo del codice che elimina il
  tracciamento del connettore; non viene dichiarata una prova runtime con l’opzione attiva.
- Reduce Transparency: il contenuto del modulo è già opaco; il chrome resta di sistema.
- Nessun test con account, sincronizzazione remota o promemoria reali; tutti i dati delle
  acquisizioni provengono dalla fixture in memoria.

## Prossimo passaggio

Revisione del proprietario su questa resa reale prima di estendere Trama alle altre superfici.
DG-VISUAL rimane aperto. Nessun push, PR, merge, TestFlight o pubblicazione eseguito.
