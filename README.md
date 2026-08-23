# Routally

**Le tue routine, finalmente collegate.**

Routally è un gestore calmo di routine e cicli personali: registra un evento reale una
sola volta e aggiorna obiettivi, cicli e passi successivi collegati.

## Stato

Il progetto è in fase pre-1.0. La fonte canonica per prodotto, UX, architettura,
distribuzione e roadmap è [docs/MASTER_PLAN.md](docs/MASTER_PLAN.md).

## Piattaforme

La 1.0 è progettata e verificata per iPhone con iOS 26, Swift 6 e SwiftUI. La Foundation
resta adattiva su iPad, la cui esperienza ottimizzata è pianificata per la 1.1.

## Roadmap sintetica

Foundation → motore e dati locali → vertical slice → esperienza essenziale → fondamenta
di release → alpha, beta e App Store 1.0.

CloudKit, geofencing, iPad ottimizzato, Analisi, ricerca e commercio ricorrente sono
conservati nella [roadmap 1.1+](docs/PRODUCT/ROADMAP.md), senza vincolare la 1.0.

## Build

Apri `Routally.xcodeproj` con Xcode 26.6 o usa la riga di comando:

```sh
xcodebuild build \
  -project Routally.xcodeproj \
  -scheme "Routally Dev" \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro"

xcodebuild test \
  -project Routally.xcodeproj \
  -scheme "Routally Tests" \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

`Routally Dev` include soltanto fixture sintetiche e diagnostica locale. `Routally` è il
prodotto pubblico e non collega il modulo `RoutallyFixtures`.

La baseline completa della toolchain è in
[docs/ENGINEERING/toolchain.md](docs/ENGINEERING/toolchain.md).

## Proprietà e contributi

Questo repository è pubblico ma proprietario. Non è software open source e non accetta
contributi, issue, richieste di funzionalità o supporto tramite GitHub.

Copyright © 2026 Matteo. All rights reserved.
