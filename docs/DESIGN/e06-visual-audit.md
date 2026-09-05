# E06 — Audit e checkpoint visuale della vertical slice

- **Stato:** Confirmed — DG-VISUAL chiuso il 5 settembre 2026
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
| Stati degradati | Offline ed errore recuperabile sono presenti ma prima erano alimentati da snapshot | offline ora accompagna scritture locali reali; retry ricrea anche uno store che non si è inizializzato |
| Accessibilità | I controlli nativi conservano ordine e semantica, ma i campi compilati non devono perdere il proprio nome | `Nome routine` e `Follow-up` mantengono un'etichetta esplicita anche quando contengono un valore |

## Linguaggio visuale approvato

La vertical slice conserva la direzione E02:

1. strutture e presentazioni sono componenti SwiftUI nativi;
2. Liquid Glass resta nel livello interattivo, non nelle card di contenuto;
3. una sola azione primaria prominente è visibile per contesto;
4. la visualizzazione del ciclo, la riga collegata e il riepilogo delle conseguenze sono
   gli elementi distintivi Routally;
5. ogni automazione mostra origine, risultato e correzione disponibile;
6. caricamento, errore e offline non sostituiscono né nascondono i dati locali validi.

La revisione Trama sostituisce la baseline visuale descritta nell’audit iniziale.
Il riferimento vincolante è [Trama Fase 1](trama-phase-one.md), formalizzato nella
[UI Foundation](ui-foundation.md). Il 5 settembre il Product Owner ha approvato la
resa reale `92f97de` con «Mi piace» dopo il confronto concept–SwiftUI.

## Evidenze richieste da DG-VISUAL

| Evidenza | Stato | Artefatto |
|---|---|---|
| screenshot audit schermate esistenti | completato su Simulator | `evidence/e06/` |
| revisione di gerarchia, spaziature, tipografia, colori e componenti | completata nel codice e in questo audit | questo documento |
| prototipo SwiftUI curato del flusso principale | implementato e verificato a runtime | `RoutallyFeatureModel` e viste E06 |
| verifica iPhone Simulator | completata su iPhone 17 Pro, iOS 26.5 | [Oggi](evidence/e06/iphone-today.jpg), [conseguenze](evidence/e06/iphone-consequences.jpg), [follow-up pronto](evidence/e06/iphone-follow-up-ready.jpg) |
| verifica iPad Simulator | completata su iPad Pro 11-inch (M5), iOS 26.5, portrait e landscape | [Oggi portrait](evidence/e06/ipad-today-portrait.jpg), [routine landscape](evidence/e06/ipad-routines-landscape.jpg), [conseguenze landscape](evidence/e06/ipad-consequences-landscape.jpg) |
| approvazione visiva Product Owner | completata il 5 settembre 2026 sulla revisione Trama `92f97de` | [Trama Fase 1](trama-phase-one.md) e [QA](../../design-qa.md) |
| formalizzazione del linguaggio approvato | completata; riferimento vincolante E07–E11 | [UI Foundation](ui-foundation.md) |

## Verifica tecnica e runtime del 27 agosto 2026

- suite `Routally Tests`: 69 test superati, nessun fallimento o test saltato;
  i 18 test di integrazione E06 sono inclusi nel target Xcode e non restano più soltanto
  presenti nel filesystem;
- iPhone: registrazione `Palestra` 1/3 → 2/3, propagazione
  `Asciugamano palestra` 3/4 → 4/4, creazione del follow-up, arrivo a casa,
  fallback idempotente, una sola notifica, completamento e reset 0/4;
- creazione iPhone: percorso completo fino al salvataggio di `Corsa`, con nome dei
  campi, stepper, picker, interruttori, riepilogo e azione finale esposti nell'albero
  accessibile;
- correzione: `Annulla registrazione` ripristina atomicamente sorgente ed effetto;
  dopo `Escludi` l'undo non applica due volte la correzione;
- tempo e ripresa: follow-up, cambio di settimana e modifica manuale dell'orologio
  vengono ricalcolati senza riavvio; caricamenti e scritture sono serializzati;
- le sei evidenze iPhone/iPad già acquisite sono state riesaminate e riutilizzate su
  richiesta del Product Owner; le correzioni successive non cambiano il rendering;
- iPad: le evidenze runtime esistenti confermano rendering accessibile in portrait e
  landscape, lista/dettaglio coordinati e riepilogo equivalente a iPhone; la build
  universale corrente è verde, mentre un nuovo lancio iPad è rimasto bloccato nel
  servizio locale Simulator e non ha prodotto nuove schermate;
- il conflitto UIKit tra le scorciatoie globali e quelle duplicate nella toolbar,
  emerso soltanto su iPad, è stato rimosso mantenendo i comandi globali.

## Criteri dell'approvazione

L'approvazione deve confermare che:

- la registrazione e le conseguenze si comprendono senza spiegazione tecnica;
- soglia raggiunta e follow-up pronto sono distinguibili anche senza colore;
- `Escludi`, `Annulla registrazione`, `Visualizza` e `Fatto` hanno gerarchia chiara;
- iPhone e iPad mantengono contenuto, azioni e ordine di lettura;
- l'interfaccia appare calma, Apple-native e coerente con Routally.

La conferma è stata ricevuta. Le evidenze aggiornate iPhone/iPad, incluse dark mode e
Dynamic Type massimo, sono in [Trama Fase 1](trama-phase-one.md); le acquisizioni E06
qui sopra restano la baseline storica.

## Verifica di chiusura E06/M03 — 5 settembre 2026

**E06/M03 e DG-VISUAL sono chiusi.** Il 5 settembre il Product Owner ha rimosso
esplicitamente il requisito del flusso su dispositivo fisico da M03 e dal prerequisito
di M04. La sezione 48.3 richiede ora il flusso end-to-end su iPhone e iPad Simulator,
coperto dalle evidenze sotto. Nessuna prova hardware viene attestata.

| Criterio M03 | Evidenza e risultato |
|---|---|
| Flusso end-to-end su Simulator | registrazione, propagazione, correzione, follow-up e reset nelle evidenze E06; resa Trama verificata su iPhone e iPad |
| Offline e persistenza locale | store E05 e regressioni di riapertura, scritture offline e recovery in `VerticalSliceTests` e test dati |
| Undo/correction | esclusioni revisionali, tombstone e annullamento senza doppia correzione verificati dai test e dal percorso Simulator |
| Follow-up e reset | soglia, momento utile, completamento e ciclo successivo coperti dalle regressioni E06 |
| Reminder/fallback testabili | arrivo e fallback idempotenti, selezione del luogo e recovery coperti; trigger OS completi in E12 |
| Accessibilità base | controlli etichettati, Dynamic Type massimo, contrasto, scuro e layout iPad nelle evidenze Trama; audit completo in E19 |
| Screenshot e design approvato | gallerie fase 1 e revisione complessiva; DG-VISUAL chiuso |
| Dominio generico | quattro archetipi nei test di dominio; il catalogo Palestra è una fixture Dev |

La fixture `demo connectedGymCycle` attraversa store E05, reducer E04 e feature model
reali, con dati sintetici in memoria. La persistenza su disco e la riapertura sono
verificate separatamente dai test dati; una fixture in-memory non le certifica.
CloudKit, geofencing e notifiche OS complete restano nelle milestone pertinenti, così
come l’audit completo di accessibilità e le rispettive prove hardware.
La pubblicazione tecnica è autorizzata dal Product Owner il 5 settembre 2026.

### Autorizzazione tecnica

Il Product Owner ha approvato anche il pacchetto complessivo `1119333` con «Approvo»
il 5 settembre 2026. La [revisione approvata](design-review.md) completa la
formalizzazione e chiude DG-VISUAL secondo i sei requisiti della sezione 48.3.

Il lavoro corrente segue il [piano DG-VISUAL](dg-visual-plan.md) per la chiusura di E06
e la formalizzazione del design approvato.
La chiusura di DG-VISUAL non autorizza l’implementazione di E07–E11. La richiesta
successiva «integra eventuali findings, poi pubblica» autorizza push, PR e merge secondo
il workflow del repository. TestFlight e App Store restano fuori dal perimetro.
