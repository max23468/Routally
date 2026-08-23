# Navigazione adattiva

- **Stato:** Confirmed
- **Epic:** E02 — Apple-native UI Direction
- **Fonte canonica:** [Master Plan](../MASTER_PLAN.md), sezioni 7 e 8

## Principi

- Le quattro aree stabili sono Oggi, Routine, Esplora e Analisi.
- Cerca è una destinazione globale separata con search role.
- Ogni area conserva selezione, posizione di scroll e percorso di navigazione quando si
  cambia tab.
- La tab bar serve soltanto a navigare; `+`, Profilo e altre azioni vivono nelle toolbar.
- Le strutture native producono la superficie Liquid Glass e si adattano alla larghezza.
- Non esistono sidebar, barre o pulsanti flottanti disegnati manualmente.

## iPhone

Un `TabView` contiene cinque destinazioni visuali: quattro tab ordinarie e Cerca con
search role. Ogni tab possiede il proprio `NavigationStack` e routing tipizzato.

| Destinazione | Radice | Toolbar | Apertura dettaglio |
|---|---|---|---|
| Oggi | Calm View | Profilo | push |
| Routine | lista e filtri | `+`, Profilo | push |
| Esplora | raccolte e Kit | Profilo | push |
| Analisi | insight e panoramica | Profilo | push |
| Cerca | suggerimenti/risultati | campo search di sistema | push alla destinazione pertinente |

La tab bar Liquid Glass rimane l'orientamento persistente e può minimizzarsi durante lo
scroll verso il basso. Non viene nascosta programmaticamente nei normali dettagli. Cerca
si attiva tramite il pattern di sistema in basso e conserva la tab di provenienza per il
ritorno.

### Presentazioni

- `+` apre Nuova routine in una sheet con `NavigationStack` dedicato;
- Profilo apre una sheet navigabile, perché contiene un compito circoscritto ma più
  sezioni correlate;
- riepilogo conseguenze usa una sheet compatta che può espandersi;
- menu `…` raccoglie azioni secondarie; le distruttive richiedono confirmation dialog;
- una sheet modificata chiede se conservare o scartare soltanto quando la chiusura
  perderebbe dati.

## iPad

Il `TabView` resta il livello superiore: le destinazioni e il loro ordine non cambiano
tra iPhone e iPad. Su iPad usa la tab bar Liquid Glass nativa e non lo stile
`.sidebarAdaptable`: in questo modo Routine ed Esplora possono usare una sola
`NavigationSplitView` interna senza creare due sidebar concorrenti. La tab bar non è
personalizzabile e non diventa una tassonomia alternativa.

| Area | Larghezza regular | Larghezza compact/intermedia |
|---|---|---|
| Oggi | colonna singola leggibile, centrata; dettaglio in push | stesso stack dell'iPhone |
| Routine | `NavigationSplitView`: lista a sinistra, dettaglio a destra | collapse in `NavigationStack` |
| Esplora | `NavigationSplitView`: Kit/raccolte a sinistra, anteprima a destra | collapse in `NavigationStack` |
| Analisi | colonna singola ampia con grafici adattivi | impilamento verticale |
| Cerca | risultati globali; selezione apre il dettaglio pertinente | stesso pattern search compatto |

Routine ed Esplora usano esattamente due colonne. Non esiste una terza colonna o un
inspector nella 1.0. Quando la finestra si restringe, il sistema collassa la colonna
secondaria preservando selezione e percorso; nessuna soglia in punti viene codificata
manualmente.

La selezione iniziale mostra un placeholder utile nel dettaglio, non seleziona
arbitrariamente la prima routine o il primo Kit. Sheet e Profilo adottano una larghezza
leggibile e restano modali rispetto al compito.

## Azioni e tastiera iPad

| Comando | Risultato |
|---|---|
| `⌘1`…`⌘4` | Oggi, Routine, Esplora, Analisi |
| `⌘F` | Cerca |
| `⌘N` | Nuova routine |
| `⌘,` | Profilo |
| `⌘Z` / `⇧⌘Z` | annulla/ripristina dove disponibile |
| Escape | chiude menu, popover o sheet se non perde dati |

Ogni comando ha un equivalente visuale. Focus, hover e pointer sono forniti dai
controlli nativi; nessun elemento essenziale richiede precisione del puntatore.

## Destinazioni e ritorno

- un risultato di ricerca apre l'area proprietaria dell'elemento senza perdere la query;
- chiudendo Cerca si torna alla tab precedente e al suo stato;
- un Universal Link non autorizza accesso: instrada soltanto a contenuti già presenti;
- una notifica apre l'elemento pertinente dentro Oggi o il dettaglio Routine;
- dopo una creazione riuscita si apre il dettaglio della nuova routine nella tab Routine;
- `Annulla` o `Fatto` nel riepilogo non cambiano tab senza richiesta dell'utente.

## Criteri di accettazione

- tutte le cinque destinazioni sono raggiungibili con componenti nativi su iPhone e iPad;
- l'ordine delle quattro tab principali è stabile e Cerca resta separata;
- Routine ed Esplora mostrano due colonne su iPad quando lo spazio lo consente e
  collassano senza perdere selezione;
- il layout resta utilizzabile nelle configurazioni metà, terzo, quadrante e finestra
  minima supportate da iPadOS;
- tab bar, sidebar, toolbar, search e sheet mostrano Liquid Glass di sistema senza
  background custom concorrenti;
- ogni gesto ha un controllo visibile e ogni comando da tastiera ha un equivalente UI;
- VoiceOver annuncia area, titolo, stato di selezione e azione, senza duplicare etichette.

## Riferimenti

- Apple HIG — [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
- Apple HIG — [Sidebars](https://developer.apple.com/design/human-interface-guidelines/sidebars)
- Apple HIG — [Split views](https://developer.apple.com/design/human-interface-guidelines/split-views)
- Apple HIG — [Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- Apple — [Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
