# DG-VISUAL — piano di lavoro sul design

## Perimetro confermato

Il lavoro corrente riguarda E06, il checkpoint DG-VISUAL e il completamento del design.
Non autorizza l’implementazione funzionale di E07 o delle epiche successive.
L’approvazione di un concept o la rimozione di un prerequisito non avviano automaticamente
la relativa epica di prodotto.

La resa Trama Fase 1 del commit `92f97de` è approvata dal Product Owner il 5 settembre 2026.
È il riferimento da conservare, non una direzione da riaprire.

## Sequenza concordata

| Passo | Risultato di design | Stato |
|---|---|---|
| Trama Fase 1 | Oggi, dettaglio Routine e conseguenze, confronto concept–SwiftUI su iPhone e iPad | approvato; evidenze in [Trama Fase 1](trama-phase-one.md) |
| Formalizzazione | approvazione registrata, linguaggio comune, evidenze e limiti coerenti | fase 1 consolidata in [Trama](trama-phase-one.md) e [contratto componenti](trama-components.md); consegna complessiva aperta |
| Navigazione e componenti condivisi | specificare anatomia, tipografia, spaziature, pulsanti, righe, sheet e stati sulla base Trama | contratto documentato in [trama-components.md](trama-components.md), applicazioni future da valutare |
| Nuova routine | proposta visuale del flusso rapido e della configurazione progressiva, con collegamenti comprensibili | composizione 3 del passaggio minimo scelta e corretta senza duplicare l’obiettivo; studio visuale di «Cosa succede dopo» in corso; [vincoli](creation-flow.md#proposta-visuale-trama--dg-visual) |
| Copertura delle superfici | design di stati vuoti, follow-up, cronologia e modifica di Oggi/Routine; poi Esplora e Kit | da completare come specifiche e concept |
| Consegna visuale finale | raccordare decisioni, copertura, evidenze e problemi aperti per concludere il lavoro DG-VISUAL | da consolidare |

I concept delle superfici future descrivono l’esperienza prevista dal Master Plan.
Non introducono implementazioni di creazione generale, catalogo installabile, modifica,
cronologia o gestione del ciclo di vita delle routine. Queste capacità restano nelle loro
epiche di implementazione, da avviare con un incarico distinto.

## Regole delle prossime proposte

- Mantenere Trama, Calma intelligente e Impulso Routally; usare i riferimenti visuali
  raccolti nella [specifica approvata](trama-phase-one.md).
- Conservare navigazione canonica, flusso unico progressivo e framework Apple nativi.
- Rendere confrontabili proposta e risultato reale; distinguere concept, prototipo e
  funzionalità completa.
- Mostrare stati ordinari, errori, testo grande e alternative senza movimento o colore.
- Riutilizzare la vertical slice per le verifiche pertinenti a E06. Eventuali prototipi
  visuali non devono essere presentati come implementazioni complete delle epiche future.
- Usare un solo Simulator per volta e spegnerlo al termine.

## Evidenze e confini

[QA della fase 1](../../design-qa.md), [audit E06](e06-visual-audit.md) e
[UI Foundation](ui-foundation.md) descrivono il riferimento verificato. Build e 73 test
appartengono al codice `92f97de`; l’approvazione riguarda la sua resa visuale.
VoiceOver parlato, aptica su dispositivo fisico e audit completo di accessibilità restano
limiti dichiarati, senza essere sostituiti dalle sole etichette AX.

Il checkpoint della fase 1 è approvato. La chiusura dell’intero lavoro sul design non si
confonde con questa approvazione, con il completamento delle epiche successive o con la
pubblicazione. Push, PR, merge, TestFlight e App Store non fanno parte dell’incarico corrente.
