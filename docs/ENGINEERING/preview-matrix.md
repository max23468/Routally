# Preview matrix — E03

- **Stato:** Implemented
- **Epic:** E03 — Xcode & SwiftUI Foundation
- **Target:** iOS e iPadOS 26

Questa matrice rende verificabili gli stati della UI Foundation senza dati o servizi
reali. Le fixture sono sintetiche, deterministiche e collegate al solo target
`Routally Dev`; il target pubblico non dipende dal modulo `RoutallyFixtures`.

## Matrice eseguibile

| View/stato | Device/layout | Aspetto | Dynamic Type | Evidenza |
|---|---|---|---|---|
| Oggi vuoto | iPhone portrait | Light | Default | `RoutallyRootView` preview |
| Oggi soglia raggiunta | iPhone portrait | Dark | Default | `RoutallyRootView` preview |
| Routine + dettaglio | iPad 1024 × 768 | Light | AX5 | `RoutallyRootView` preview |
| Nuova routine vuota | iPhone portrait | Light | Default | `CreationSheet` preview |
| Nuova routine vuota | iPhone portrait | Dark | AX5 | `CreationSheet` preview |
| Riepilogo conseguenze | iPhone Simulator | Light/Dark | sistema | scenario Dev interattivo |
| Follow-up e reset | iPhone Simulator | Light/Dark | sistema | scenario Dev interattivo |
| Offline con modifiche pendenti | iPhone/iPad | sistema | sistema | fixture canonica |

`AX5` corrisponde a `DynamicTypeSize.accessibility5` nella toolchain Xcode 26.6.
Contrasto aumentato, Riduci trasparenza e Riduci movimento sono governati dai componenti
SwiftUI nativi; non esistono materiali, animazioni o fallback custom concorrenti.

## Fixture canoniche

`EmptyProfile`, `NewUser`, `TypicalUser`, `HighlyOrganizedUser`, `ThresholdReached`,
`OfflineWithPendingChanges`, `CloudConflict`, `FreeLimitReached`, `PlusUser` e
`LargeHistory` sono rappresentate da `DemoScenario` e verificate dalla suite Swift
Testing. Il launch argument canonico è:

```text
-launchMode demo -demoScenario connectedGymCycle
```

## Copertura vertical slice

I criteri `E02-VS-01`…`E02-VS-13` sono rappresentati dalla creazione nativa, dalla
fixture `ThresholdReached`, dallo state store interattivo, dalle azioni `Escludi` e
`Annulla`, dallo stato offline e dalla navigazione split su iPad. Motore event-sourced,
persistenza, geofencing e notifiche reali restano nelle epiche e nei Technical Gate
previsti dal Master Plan; E03 usa soltanto simulazioni locali esplicitamente Dev.
