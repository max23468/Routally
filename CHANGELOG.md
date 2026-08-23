# Changelog

Le modifiche rilevanti a Routally saranno documentate in questo file.

## Unreleased

- Semplificato il Master Plan: scope 1.0 concentrato sul ciclo
  collegato locale, sei milestone, dodici epiche e tre Technical Gate senza duplicazioni.
- Spostati nella roadmap 1.1+ CloudKit, geofencing, iPad ottimizzato, Analisi, ricerca,
  integrazioni estese, otto Kit e commercio ricorrente; le revisioni precedenti restano
  nella cronologia Git senza creare un secondo Master Plan.
- Semplificati dominio e dati in journal deterministico, SwiftData locale e backup
  lossless; rimossi dal piano proiezioni materializzate, Consistency Engine, adapter
  futuri e client analytics nullo.
- Ridotta la governance: eliminata la matrice di lettura, raggruppati gli aggiornamenti
  Actions e spostato CodeQL su `main`, pianificazione settimanale o avvio manuale.

- Inizializzata la baseline di repository e governance.
- Allineati bootstrap Git, workflow degli agenti e segnalazioni di sicurezza private.
- Aggiunto il gate required della review Codex sull'HEAD corrente delle pull request.
- Completata la baseline GitHub con CodeQL Swift, Dependabot Actions e policy SHA-pinned.
- Aggiunti Decision Register e ADR baseline per iOS 26, dominio event-sourced e SwiftData/CloudKit.
- Adottato il workflow di design SwiftUI-first con Xcode Previews, Simulator e Icon Composer.
- Completata E02 con UI Foundation Liquid Glass, token semantici, navigazione adattiva,
  flusso di creazione, vertical slice e criteri di accessibilità.
- Implementata E03 con progetto Xcode, target Dev/Public/Test, xcconfig, moduli SwiftPM
  locali, feature flag, fixture Dev, token Asset Catalog, preview matrix e vertical slice
  SwiftUI interattiva su iPhone e iPad.
- Riallineata la UI Foundation E03 al contratto Liquid Glass: CTA primarie glass,
  `CycleVisualization` riusabile, stati accessibili e preview dedicate.
- Revisione critica del Master Plan: limiti Free portati a 10 routine e 5 collegamenti
  perché i 4 Kit
  introduttivi fossero davvero installabili, conseguenze del downgrade rese visibili,
  lettura selettiva del piano per sezioni, linea di galleggiamento pre-approvata della 1.0,
  spike TG-RECALC sul ricalcolo retroattivo, soglie di beta dichiarate qualitative e
  regola deterministica per «Questa settimana».
- Aggiunto ADR-0005: la review delle pull request è un gate di CI e non un ruolo di agente.
- Consolidata la preparazione di `DG-ICON`: livelli SVG autonomi per tutte le varianti,
  rifiniture A1 testa/Lavender/Amber, tavole dimensionali riproducibili, validazione
  geometrica indipendente, checklist Icon Composer e dispositivi, protocollo di user test,
  ricerca preliminare di originalità e decision record ancora aperto.
- Promossa A1 Lavender con testa 50 a baseline canonica dell'icona e riallineati asset, derivata Dev, controlli e protocolli residui.
