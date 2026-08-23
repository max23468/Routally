# ADR 0001 — iOS 26 come versione minima

- **Stato:** Confirmed
- **Data:** 2026-08-05
- **Ambito:** Routally 1.0

## Contesto

Routally deve offrire una prima esperienza Apple-native concentrata su iPhone, usare
SwiftUI e Liquid Glass senza mantenere UI per versioni precedenti. La Foundation già si
adatta a iPad, ma una promessa universale completa allargherebbe prematuramente layout e
matrice di test.

## Decisione

Il deployment target della 1.0 è iOS 26. Il progetto usa Swift 6, SwiftUI, Observation e
controlli di sistema. Non vengono introdotti fallback per versioni precedenti. iPad può
eseguire l'interfaccia adattiva esistente, ma supporto e commercializzazione iPad completi
sono scope 1.1.

## Conseguenze

- una sola implementazione dell'interfaccia e una matrice di release iPhone contenuta;
- accesso alle API e ai pattern di navigazione correnti;
- pubblico iniziale limitato ai dispositivi compatibili con iOS 26;
- nessuna promessa 1.0 su split view, tastiera, pointer o materiali App Store iPad.

## Riferimenti

- Master Plan, sezioni 2.1, 3.4 e 9.
- Roadmap, sezione 1.1 «iPad ottimizzato».
