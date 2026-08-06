# ADR 0004 — Design UI SwiftUI-first

- **Stato:** Confirmed
- **Data:** 2026-08-06
- **Ambito:** Routally 1.0

## Contesto

Routally è un prodotto Apple-native sviluppato da un unico team operativo. Una
rappresentazione visuale separata dall'interfaccia reale introdurrebbe una seconda fonte
da mantenere, con rischio di divergenza su comportamento nativo, accessibilità e layout
adattivi.

## Decisione

- Il Master Plan e le specifiche `docs/DESIGN/` definiscono IA, flussi e criteri di
  accettazione.
- SwiftUI è la rappresentazione eseguibile e primaria dell'interfaccia.
- Le view mantengono `#Preview` locali con fixture fittizie e stati rappresentativi.
- Xcode Previews, Simulator e dispositivi reali verificano interazioni, iPhone/iPad,
  Light/Dark Mode, Dynamic Type e accessibilità.
- Asset Catalog contiene colori e asset semantici; costanti dedicate vengono introdotte
  soltanto quando esiste una ricorrenza reale.
- Le alternative dell'icona usano livelli SVG e Icon Composer.
- I materiali App Store usano esclusivamente schermate della release candidate reale.

## Conseguenze

- E02 chiude la direzione UI e i criteri di accettazione.
- E03 realizza la foundation SwiftUI eseguibile insieme al progetto Xcode.
- Non esiste una dipendenza da strumenti di prototipazione esterni.
- Le modifiche visuali vengono verificate nello stesso artefatto destinato alla build.

## Riferimenti

- Master Plan, sezioni 0.1, 26.5, 37.1, 48.1 e 49.
