# E06 — Audit e checkpoint visuale della vertical slice

- **Stato:** In corso — evidenze Simulator complete; approvazione del Product Owner pendente
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
| iPad | Lista e dettaglio usano `NavigationSplitView`; la creazione resta form sheet | verificato sul Simulator iPad con il flusso E06 reale in portrait e landscape |
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
| screenshot audit schermate esistenti | completato su Simulator | `evidence/e06/` |
| revisione di gerarchia, spaziature, tipografia, colori e componenti | completata nel codice e in questo audit | questo documento |
| prototipo SwiftUI curato del flusso principale | implementato e verificato a runtime | `RoutallyFeatureModel` e viste E06 |
| verifica iPhone Simulator | completata su iPhone 17 Pro, iOS 26.5 | [Oggi](evidence/e06/iphone-today.jpg), [conseguenze](evidence/e06/iphone-consequences.jpg), [follow-up pronto](evidence/e06/iphone-follow-up-ready.jpg) |
| verifica iPad Simulator | completata su iPad Pro 11-inch (M5), iOS 26.5, portrait e landscape | [Oggi portrait](evidence/e06/ipad-today-portrait.jpg), [routine landscape](evidence/e06/ipad-routines-landscape.jpg), [conseguenze landscape](evidence/e06/ipad-consequences-landscape.jpg) |
| approvazione visiva Product Owner | pendente | — |

## Verifica runtime del 27 agosto 2026

- suite `Routally Tests`: 51 test superati, nessun fallimento o test saltato;
- iPhone: registrazione `Palestra` 1/3 → 2/3, propagazione
  `Asciugamano palestra` 3/4 → 4/4, creazione del follow-up, arrivo a casa,
  fallback idempotente, una sola notifica, completamento e reset 0/4;
- correzione: `Annulla registrazione` ripristina atomicamente sorgente ed effetto;
  dopo `Escludi` l'undo non applica due volte la correzione;
- iPad: rendering accessibile in portrait e landscape, lista/dettaglio coordinati e
  riepilogo delle conseguenze equivalente a iPhone;
- il conflitto UIKit tra le scorciatoie globali e quelle duplicate nella toolbar,
  emerso soltanto su iPad, è stato rimosso mantenendo i comandi globali.

## Criteri dell'approvazione

L'approvazione deve confermare che:

- la registrazione e le conseguenze si comprendono senza spiegazione tecnica;
- soglia raggiunta e follow-up pronto sono distinguibili anche senza colore;
- `Escludi`, `Annulla registrazione`, `Visualizza` e `Fatto` hanno gerarchia chiara;
- iPhone e iPad mantengono contenuto, azioni e ordine di lettura;
- l'interfaccia appare calma, Apple-native e coerente con Routally.

Solo dopo questa conferma `DG-VISUAL` può essere registrato come chiuso.
