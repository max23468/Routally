# E06 — Audit e checkpoint visuale della vertical slice

- **Stato:** In corso — evidenze Simulator e approvazione del Product Owner pendenti
- **Epic:** E06 — Vertical Slice Integration
- **Gate:** DG-VISUAL
- **Fonte canonica:** Master Plan, sezione 48.3

## Perimetro

Il checkpoint riguarda soltanto il percorso Palestra → Asciugamano palestra → follow-up
e gli stati indispensabili per comprenderlo e correggerlo. Non completa né anticipa le
schermate di E07–E11.

## Audit della baseline E03

| Area | Osservazione | Esito E06 |
|---|---|---|
| Gerarchia | Il contenuto usa già `List`, `Form`, sezioni e toolbar native; non serve una nuova grammatica visuale | confermata la gerarchia system-native |
| Caricamento | Lo store reale poteva mostrare per un istante lo stato vuoto prima della lettura locale | aggiunto indicatore iniziale accessibile, senza overlay decorativi |
| Azioni | Registrazione, completamento e correzione erano sincroni e non esponevano lo stato occupato | operazioni asincrone serializzate e controlli pertinenti disabilitati durante la scrittura |
| Conseguenze | Il riepilogo distingue già origine, effetto, `Escludi` e undo completo | mantenuto il pattern; i figli interattivi restano elementi accessibili separati |
| Colore | Indaco per azioni/progresso, verde per effetto applicato, arancione per attenzione | confermati i token semantici; nessun significato dipende dal solo colore |
| Tipografia | Stili Dynamic Type e SF Rounded limitato al valore del ciclo | confermata; nessuna dimensione fissa introdotta |
| iPad | Lista e dettaglio usano `NavigationSplitView`; la creazione resta form sheet | da verificare sul Simulator iPad con il flusso E06 reale |
| Stati degradati | Offline ed errore recuperabile sono presenti ma prima erano alimentati da snapshot | offline ora accompagna scritture locali reali; retry rilegge lo store |

## Linguaggio visuale proposto

La vertical slice conserva la direzione E02:

1. strutture e presentazioni sono componenti SwiftUI nativi;
2. Liquid Glass resta nel livello interattivo, non nelle card di contenuto;
3. una sola azione primaria prominente è visibile per contesto;
4. la visualizzazione del ciclo, la riga collegata e il riepilogo delle conseguenze sono
   gli elementi distintivi Routally;
5. ogni automazione mostra origine, risultato e correzione disponibile;
6. caricamento, errore e offline non sostituiscono né nascondono i dati locali validi.

Questa formulazione è provvisoria finché il Product Owner non approva le evidenze
Simulator. Dopo l'approvazione diventa la base vincolante per E07–E11.

## Evidenze richieste da DG-VISUAL

| Evidenza | Stato | Artefatto |
|---|---|---|
| screenshot audit schermate esistenti | pendente Simulator | — |
| revisione di gerarchia, spaziature, tipografia, colori e componenti | completata nel codice e in questo audit | questo documento |
| prototipo SwiftUI curato del flusso principale | implementato, verifica runtime pendente | `RoutallyFeatureModel` e viste E06 |
| verifica iPhone Simulator | pendente | — |
| verifica iPad Simulator | pendente | — |
| approvazione visiva Product Owner | pendente | — |

## Criteri dell'approvazione

L'approvazione deve confermare che:

- la registrazione e le conseguenze si comprendono senza spiegazione tecnica;
- soglia raggiunta e follow-up pronto sono distinguibili anche senza colore;
- `Escludi`, `Annulla registrazione`, `Visualizza` e `Fatto` hanno gerarchia chiara;
- iPhone e iPad mantengono contenuto, azioni e ordine di lettura;
- l'interfaccia appare calma, Apple-native e coerente con Routally.

Solo dopo questa conferma `DG-VISUAL` può essere registrato come chiuso.
