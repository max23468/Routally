# UI Foundation Apple-native

- **Stato:** Confirmed
- **Epic:** E02 — Apple-native UI Direction
- **Piattaforme:** iOS 26 e iPadOS 26
- **Fonte canonica:** [Master Plan](../MASTER_PLAN.md)
- **Baseline Apple verificata:** 6 agosto 2026

## Intento

Routally deve apparire nativa, calma e riconoscibile. Liquid Glass è il linguaggio
predominante dell'interazione: vive nelle strutture, nei controlli e nelle transizioni di
sistema, mentre il contenuto mantiene superfici semplici e leggibili. La personalità del
brand deriva dall'indaco, dalla visualizzazione dei cicli e dal modo trasparente in cui
vengono mostrate le conseguenze, non da decorazioni sovrapposte.

## Gerarchia visuale

1. **Contenuto:** liste, testi, grafici e schede Kit usano sfondi e materiali standard.
2. **Interazione:** tab bar, sidebar, navigation bar, toolbar, search, sheet, menu,
   picker e pulsanti adottano automaticamente Liquid Glass tramite componenti SwiftUI.
3. **Brand:** l'accento Routally evidenzia selezione, azione primaria e progresso; non
   tinge indiscriminatamente navigazione e contenuto.
4. **Stato:** testo, simbolo e forma comunicano sempre insieme al colore.

“Predominante” descrive la copertura del livello interattivo, non la quantità di vetro
sullo schermo: ogni azione primaria visibile usa `glassProminent`, mentre barre,
toolbar, search e presentazioni lasciano il materiale al sistema. Il contenuto non viene
reso glass per compensare un controllo implementato con uno stile non coerente.

Il contenuto scorre sotto le superfici di navigazione affinché il vetro reagisca al
contesto. Non si aggiungono blur, fondi oscuranti o shadow custom dietro barre e sheet:
interferirebbero con lo scroll-edge effect e con l'adattamento automatico del materiale.

### Dove usare Liquid Glass

| Area | Scelta |
|---|---|
| Tab bar e Search role | componente di sistema, sempre |
| Sidebar iPad | superficie di sistema sopra il contenuto |
| Navigation bar e toolbar | item nativi raggruppati per relazione |
| Sheet, popover, menu e dialog | presentazione nativa senza background custom |
| Pulsante primario | `glassProminent` di sistema con tint brand |
| Controlli custom | `CycleVisualization` glass soltanto quando è un controllo interattivo |

La variante glass `regular` è il default. `clear` è esclusa dalla UI ordinaria: potrà
essere valutata soltanto sopra uno sfondo visualmente ricco e dopo verifica di contrasto.
Più elementi glass adiacenti appartengono allo stesso container visuale; non si
sovrappongono più strati di vetro.

### Dove non usarlo

- card informative, righe di lista, grafici e background dell'app;
- ogni elemento di Oggi o Routine soltanto per renderlo più evidente;
- contenitori annidati o decorativi;
- superfici che diventano opache o rumorose con Riduci trasparenza;
- indicatori di stato che dipendono dall'effetto ottico per essere compresi.

## Token semantici

I nomi seguenti sono il contratto per l'Asset Catalog e il modulo `RoutallyDesign` di
E03. Le view usano il ruolo semantico, mai un colore hardcoded.

### Colore

| Token | Sorgente | Uso |
|---|---|---|
| `brandAccent` | asset dinamico Routally Indigo | selezione, CTA e progresso principale |
| `contentPrimary` | `primary` | testo e simboli principali |
| `contentSecondary` | `secondary` | contesto e metadati |
| `surfacePrimary` | `systemBackground` | contenuto principale |
| `surfaceGrouped` | `systemGroupedBackground` | form e gruppi |
| `surfaceRaised` | `secondarySystemBackground` | riepiloghi e card indispensabili |
| `separator` | `separator` | separazioni native |
| `statusComplete` | system green | completato, sempre con checkmark/testo |
| `statusUpcoming` | secondary | in arrivo, sempre con clock/testo |
| `statusDue` | `brandAccent` | da fare, sempre con simbolo/testo |
| `statusAttention` | system orange | richiede attenzione, mai errore |
| `statusDestructive` | system red | eliminazione o perdita dati |

`brandAccent` usa queste varianti iniziali, da riportare senza conversioni arbitrarie
nell'Asset Catalog:

| Aspetto | sRGB |
|---|---|
| Light | `#4C46D8` |
| Dark | `#A9A5FF` |
| Light + Increase Contrast | `#3429BD` |
| Dark + Increase Contrast | `#CAC7FF` |

Gli accenti Plus sono token di scelta, non token di stato. Le coppie Light/Dark sono:

| Token | Light | Dark |
|---|---|---|
| `accentOcean` | `#006B9E` | `#6BCBFF` |
| `accentTeal` | `#007D72` | `#67D8C8` |
| `accentAmber` | `#9A5B00` | `#FFBF66` |
| `accentCoral` | `#B5414D` | `#FF9BA4` |
| `accentViolet` | `#7042B4` | `#C6A4FF` |

Le stesse coppie restano leggibili con Increase Contrast; l'Asset Catalog espone anche
la variante di contrasto per consentire una futura correzione senza cambiare il token.
Nessun accento può sostituire rosso, verde o arancione semantici.

### Tipografia

| Token | Stile SwiftUI | Uso |
|---|---|---|
| `screenTitle` | `.largeTitle` | titolo radice quando il sistema lo mostra |
| `sectionTitle` | `.headline` | sezioni e gruppi |
| `itemTitle` | `.body` con enfasi semantica | nome routine o follow-up |
| `itemContext` | `.subheadline` | momento, sorgente e conseguenze |
| `supporting` | `.footnote` | spiegazioni e metadati |
| `cycleValue` | `.title2`, design rounded | valore centrale del ciclo |

San Francisco e Dynamic Type sono obbligatori. Non si fissano dimensioni in punti e non
si riduce il testo per farlo entrare. `cycleValue` è l'unico uso ordinario di SF Rounded.

### Spaziatura, forma ed elevazione

I componenti nativi mantengono metriche, margini e forme del sistema. Per componenti
Routally ricorrenti sono ammessi soltanto i token `space4`, `space8`, `space12`,
`space16`, `space24` e `space32`. Il margine di contenuto normale è `space16`; a testo
accessibility diventa il minimo, non un vincolo orizzontale.

Le forme custom usano angoli continui e concentrici rispetto al contenitore. Il raggio
`radius16` è riservato a riepiloghi e anteprime Kit; i cicli restano circolari. Non
esistono token di shadow custom: profondità, separazione e vibrancy sono del sistema.

### Movimento e feedback

- navigazione, sheet e controlli usano transizioni e spring di sistema;
- una registrazione aggiorna i valori nello stesso contesto e presenta il riepilogo;
- il ciclo può effettuare una sola transizione breve verso la soglia o il reset;
- il feedback aptico conferma un'azione ma non è mai l'unico segnale;
- con Riduci movimento, morph, scale e profondità diventano aggiornamenti immediati o
  dissolvenze discrete;
- con Riduci trasparenza, l'interfaccia resta gerarchica senza richiedere fallback custom.

## Componenti Routally

### Componenti Apple di base

| Esigenza | Componente/pattern SwiftUI |
|---|---|
| shell e destinazioni | `TabView`, search role, `NavigationStack` |
| layout adattivo iPad | `NavigationSplitView` |
| contenuti e configurazione | `List`, `Form`, `Section`, `LabeledContent` |
| input | `TextField`, `Picker`, `DatePicker`, `Stepper`, `Toggle` |
| azioni | `Button`, `Menu`, `swipeActions`, toolbar |
| presentazioni | `sheet`, `popover`, `confirmationDialog`, `alert` |
| ricerca | `searchable`, suggestion e scope di sistema |
| feedback | `ContentUnavailableView`, `ProgressView`, sheet di riepilogo |
| simboli | SF Symbols con rendering semantico |

La prima implementazione usa questi elementi senza wrapper visuali generici. Un wrapper
nasce soltanto quando applica una semantica Routally ricorrente, non per rinominare una
API SwiftUI.

### Componenti distintivi

| Componente | Responsabilità | Varianti/stati | Accessibilità |
|---|---|---|---|
| `RoutineRow` | nome, contesto, progresso e azione | normale, soglia, follow-up; enabled/disabled | un contenitore leggibile, azione nominata |
| `CycleVisualization` | progresso e stato del ciclo | attivo, soglia, follow-up, completato | valore testuale completo; non solo anello/colore |
| `LinkedRoutineRow` | sorgente e conseguenza | incremento, durata, quantità | frase naturale sulla relazione |
| `ConsequenceSummary` | esito e correzione della registrazione | semplice, collegato, errore parziale; esclusione per singolo effetto | titolo annunciato e azioni nominate con il target |
| `KitPreview` | beneficio e contenuto installato | Free, Plus, limite raggiunto | piano e costo in testo, non solo badge |
| `AllClearState` | conferma che non serve agire | nuovo utente, giornata libera | messaggio breve, nessuna animazione obbligatoria |
| `AttentionIndicator` | livello di attenzione | in arrivo, da fare, attenzione | simbolo + etichetta + colore |

Pulsanti, picker, toggle, menu, search, tab, sheet e barre non vengono ricreati.

## Direzione dell'icona

La direzione confermata è un **monogramma `R` costruito attorno a un ciclo**, definito nella
sezione 4.8 del Master Plan. Il ciclo è la forma dominante, il fianco ne continua la tangente
verticale fino alla base, la gamba completa la lettera e un arco esterno di progresso termina
in una testa piena.

Le direzioni precedenti — azione centrale e conseguenze collegate, `R` con due cicli,
onde originate da un gesto, tre elementi che chiudono un ciclo e tally marks collegati —
sono archiviate.

Ogni variante combinata mantiene gruppi SVG nominati. Per non presumere il comportamento di
Icon Composer, il confronto usa però i file autonomi di
`docs/DESIGN/icon/composer-layers/`, con coordinate già trasformate. A1 è soltanto la
candidata preferita; A3 e T1 restano confronti obbligatori. T1 è il benchmark della
silhouette e non viene sostituito automaticamente dal sistema alle piccole dimensioni.

Le tavole SVG verificano in modo riproducibile dimensioni e contesti piatti, ma non simulano
Liquid Glass. La scelta resta nel Decision Gate `DG-ICON` e richiede Icon Composer,
dispositivi reali, user test cieco e verifica figurativa prima del file `.icon` definitivo.

## Benchmark applicato

| Fonte | Pattern adottato | Limite mantenuto |
|---|---|---|
| HIG e app Apple | struttura e controlli nativi con Liquid Glass | niente glass decorativo nel contenuto |
| Health | Search come destinazione separata e globale | non diventa una quinta area di prodotto |
| Reminders | liste leggibili, azioni familiari e undo | Routally non diventa un task manager |
| Tody e DoneAgo | priorità reale e stato calmo | niente debito permanente o streak |
| KountEm | progresso di utilizzo leggibile | il ciclo resta collegato all'evento sorgente |

Le fonti competitive e i pattern rifiutati sono documentati nella sezione 3.1.3 del
Master Plan; questa specifica non amplia il benchmark né introduce nuove feature.

## Oggi — Calm View

### Composizione

1. navigation bar Liquid Glass con titolo `Oggi` e Profilo;
2. contenuto scrollabile edge-to-edge;
3. sezioni presenti soltanto quando contengono elementi: Adesso, Più tardi, Questa
   settimana;
4. righe compatte, con una sola azione primaria visibile;
5. stato `Tutto sotto controllo` quando non esiste alcuna azione utile;
6. riepilogo conseguenze in sheet nativa dopo una registrazione collegata.

Nel riepilogo collegato ogni conseguenza derivata offre `Escludi`. L'azione mantiene
l'evento sorgente e gli altri effetti, registra la correzione e ricalcola progresso,
soglia e follow-up del solo elemento escluso. Il riepilogo si aggiorna nello stesso
contesto; `Annulla` continua invece a invertire l'intera registrazione.

Le card grandi sono ammesse soltanto per il riepilogo settimanale o per uno stato
importante. La tab bar può minimizzarsi durante uno scroll verso il basso e torna
immediatamente disponibile con scroll inverso o selezione della tab.

### Stati obbligatori per le preview di E03

- profilo vuoto e primo ingresso;
- giornata senza elementi;
- una routine in Adesso;
- più routine con Più tardi e Questa settimana;
- soglia raggiunta con follow-up non ancora pronto;
- follow-up pronto;
- conseguenze multiple appena applicate;
- errore recuperabile senza perdita dell'evento;
- offline con modifiche pendenti;
- Free e Plus dove il comportamento differisce.

## Criteri di accettazione E02

- ogni colore UI è collegato a un token semanticamente nominato;
- tutte le strutture e i controlli previsti hanno un equivalente SwiftUI nativo;
- Liquid Glass è dominante nel livello interattivo e assente dal contenuto decorativo;
- Oggi è specificata per stato vuoto, ordinario, soglia, follow-up ed errore;
- Light, Dark, Increase Contrast, Reduce Transparency e Reduce Motion non cambiano il
  significato dell'interfaccia;
- nessun elemento essenziale dipende da colore, gesto, animazione o aptica soltanto;
- le scelte restano verificabili tramite le preview e la matrice di E03.

### Tracciabilità dell'epic

| Requisito E02 | Evidenza |
|---|---|
| baseline HIG e componenti Apple | gerarchia Liquid Glass, componenti Apple e riferimenti in questo documento |
| token semantici | colore, tipografia, spaziatura, forma, movimento e feedback in questo documento |
| navigazione iPhone/iPad | [navigation.md](navigation.md) |
| flusso Oggi | sezione Oggi e stati obbligatori in questo documento |
| flusso di creazione | [creation-flow.md](creation-flow.md) |
| vertical slice | criteri `E02-VS-01`…`E02-VS-13` in [creation-flow.md](creation-flow.md) |
| esplorazione icona | direzioni, vincoli e `DG-ICON` in questo documento |
| accessibilità | [accessibility.md](accessibility.md) |

E02 è documentata quando tutte queste evidenze sono presenti e coerenti. Preview,
Simulator, Asset Catalog e implementazione interattiva appartengono a E03 e non sono
usati per dichiarare completato lavoro non ancora iniziato.

## Riferimenti

- Master Plan, sezioni 4.6–4.9, 7, 9, 23, 25.5, 26.5 e 49.
- Apple HIG — [Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- Apple HIG — [Color](https://developer.apple.com/design/human-interface-guidelines/color)
- Apple — [Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
