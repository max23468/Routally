# Accessibilità della UI Foundation

- **Stato:** Confirmed
- **Epic:** E02 — Apple-native UI Direction
- **Fonte canonica:** [Master Plan](../MASTER_PLAN.md), sezioni 3.4 e 10

## Principio

L'accessibilità determina struttura e componenti prima dell'implementazione. L'uso
preponderante di Liquid Glass non può ridurre contrasto, comprensione o prevedibilità:
Routally adotta componenti di sistema e lascia che Increase Contrast e Reduce
Transparency ne controllino l'aspetto.

## Contratto dei componenti

- ogni controllo ha label, valore e hint soltanto quando aggiunge informazione;
- le righe con azione interna espongono chiaramente corpo e azione, senza target annidati
  ambigui;
- stato e progresso usano testo o simbolo oltre al colore;
- i target interattivi misurano almeno 44 × 44 pt, anche quando il simbolo è più piccolo;
- il focus segue ordine visuale e semantico, non l'ordine accidentale delle subview;
- aggiornamenti importanti, errori e risultati vengono annunciati senza ripetizioni;
- swipe e pressione prolungata sono scorciatoie, mai l'unico accesso;
- controlli nativi mantengono Voice Control e il comportamento di focus di sistema.

## Dynamic Type e layout

- tutti i testi usano stili semantici e possono superare il 200%;
- nessun titolo o valore essenziale usa una singola riga obbligatoria;
- righe con testo e CTA passano a disposizione verticale alle categorie accessibility;
- grafici e Cycle Visualization mantengono una descrizione testuale equivalente;
- i layout iPhone restano scorrevoli e non perdono azioni a testo massimo;
- truncation è ammessa soltanto per dati ripetibili e mai per azioni, errori o stato.

## Colore, contrasto e vetro

- il testo ordinario mira almeno a WCAG AA: 4,5:1; testo grande o bold almeno 3:1;
- ogni variante viene verificata in Light, Dark e Increase Contrast;
- il brand accent non comunica completamento, errore o attenzione da solo;
- Reduce Transparency deve produrre superfici di sistema leggibili senza materiale
  custom sostitutivo;
- non si colloca testo secondario direttamente sopra contenuto variabile senza una
  superficie di sistema responsabile del contrasto;
- immagini e colori che scorrono sotto Liquid Glass non possono essere necessari per
  comprendere i controlli sovrastanti.

## Movimento e aptica

- Reduce Motion elimina scale, morph e profondità non indispensabili;
- nessuna animazione automatica continua, lampeggiante o ripetitiva;
- un cambio di stato resta percepibile con testo e simbolo anche senza animazione;
- l'aptica conferma, ma non sostituisce visuale o annuncio;
- gli aggiornamenti multipli vengono raggruppati in un solo riepilogo comprensibile.

## Matrice E03

| Scenario | VoiceOver/Voice Control | Dynamic Type | Aspetto | Input |
|---|---|---|---|---|
| Oggi vuoto | ordine e CTA | AX5 | Light/Dark/contrast | focus sistema |
| Oggi popolato | sezioni, righe, azioni | AX5 | Light/Dark/contrast | focus sistema |
| Routine e dettaglio | selezione e stato | AX5 | Light/Dark/contrast | focus sistema |
| Nuova routine | campi, errori, CTA | AX5 | Light/Dark/contrast | Return/Escape |
| Consequence Summary | annuncio ed effetti | AX5 | transparency on/off | focus sheet |
| Follow-up/reset | stato e completamento | AX5 | motion on/off | keyboard action |

`AX5` indica la categoria di testo accessibility più grande disponibile nella toolchain
usata da E03; la denominazione effettiva viene registrata nella preview matrix.

## Criteri di accettazione E02

- ogni componente custom in `ui-foundation.md` ha una semantica accessibile definita;
- ogni flusso possiede ordine di focus, alternativa ai gesti e comportamento a testo
  massimo;
- nessun token cromatico rappresenta due significati incompatibili;
- Liquid Glass resta controllato dal sistema e leggibile con contrasto e trasparenza
  modificati;
- la matrice copre iPhone, Light/Dark, contrasto, trasparenza, movimento, input e
  tecnologie assistive;
- le dichiarazioni App Store restano sospese fino all'audit reale previsto dal piano.

## Riferimenti

- Apple HIG — [Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
- Apple HIG — [Color](https://developer.apple.com/design/human-interface-guidelines/color)
- Apple HIG — [Layout](https://developer.apple.com/design/human-interface-guidelines/layout)
- Apple — [Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
