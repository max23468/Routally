# Routally

**Le tue routine, finalmente collegate.**

Routally è un gestore calmo di routine e cicli personali: registra un evento reale una
sola volta e aggiorna obiettivi, cicli e passi successivi collegati.

## Stato

Il progetto è in fase pre-1.0. La fonte canonica per prodotto, UX, architettura,
distribuzione e roadmap è [docs/MASTER_PLAN.md](docs/MASTER_PLAN.md).

## Modello 1.0

Routally 1.0 sarà completamente gratuita e senza limiti commerciali. Tutto il core
pubblicato nella 1.0 resterà gratuito; un eventuale Routally Plus arriverà nella 1.X
soltanto con nuove capacità sostanziali e additive.

## Piattaforme

La 1.0 è prevista come app universale nativa per iPhone e iPad, sviluppata con Swift 6
e SwiftUI per iOS e iPadOS 26.

## Roadmap sintetica

Foundation → motore delle routine → vertical slice → esperienza completa → integrazioni
di sistema e commercio → alpha → beta → App Store 1.0.

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
