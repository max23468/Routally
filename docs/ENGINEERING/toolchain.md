# Toolchain baseline — M01 E03

- **Stato:** Confirmed
- **Rilevazione:** 15 agosto 2026
- **Epic:** E03 — Xcode & SwiftUI Foundation

| Componente | Versione/vincolo | Blocco operativo |
|---|---|---|
| Xcode | 26.6 (`17F113`) | `.xcode-version`, CI `DEVELOPER_DIR` |
| Swift compiler | 6.3.3 | language mode Swift 6 |
| Swift tools manifest | 6.2 | `Package.swift`; compatibile con il compiler bloccato |
| iOS Simulator SDK | 26.5 | Xcode 26.6 |
| Deployment target | iOS/iPadOS 26.0 | `Configuration/Base.xcconfig` |
| swift-format | 6.3.0 | `.swift-format`, workflow `swift-format.yml` |
| XcodeBuildMCP | 2.7.0 | baseline locale di build, test e Simulator |

La build Apple primaria resta destinata a Xcode Cloud; GitHub Actions esegue soltanto i
controlli complementari ammessi dal Master Plan. `codeql.yml` e `swift-format.yml` usano
il runner `macos-26` e selezionano Xcode 26.6 esplicitamente.

Il package locale `RoutallyModules` non dichiara dipendenze runtime esterne. La fixture e
la matrice visuale sono bloccate in [preview-matrix.md](preview-matrix.md). Schema
SwiftData e formato eventi dello spike sono versionati nel target isolato
`RoutallyDataSpike`; non appartengono ancora allo store di prodotto, che resta in `E05`.
`RoutallyTGDataProbeWidget` è un'estensione tecnica incorporata soltanto in `Routally Dev`
per validare l'App Group provvisorio di `TG-DATA`; il widget di prodotto resta in `E13`.
