# ADR 0001 — iOS 26 come versione minima

- **Stato:** Accepted
- **Data:** 2026-08-05
- **Ambito:** Routally 1.0

## Contesto

Routally deve offrire un'esperienza universale coerente su iPhone e iPad, usare SwiftUI
e adottare i componenti Apple-native e Liquid Glass senza mantenere una seconda UI.

## Decisione

Il deployment target della 1.0 è iOS 26 e iPadOS 26. Il progetto usa Swift 6, SwiftUI,
Observation e controlli di sistema. Non vengono introdotti fallback per versioni precedenti.

## Conseguenze

- una sola implementazione dell'interfaccia e una matrice di test più contenuta;
- accesso alle API e ai pattern di navigazione correnti;
- pubblico iniziale limitato ai dispositivi compatibili con iOS 26;
- supporto iPad completo, non una UI iPhone ingrandita.

## Riferimenti

- Master Plan, sezioni 7.1, 25 e 43.
