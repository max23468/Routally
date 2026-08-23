# Changelog

Le modifiche rilevanti a Routally saranno documentate in questo file.

## Unreleased

- Chiuso `TG-DATA` con esito Adapt: spike SwiftData isolato, schema e migrazione
  versionati, deduplica UUID, revisioni/tombstone, recovery, condivisione app-widget,
  configurazione App Group/CloudKit e dataset canonico da 10.000 eventi coperti da test;
  la sincronizzazione CloudKit reale resta nelle epiche che possiedono gli asset Apple.
- Integrati i pacchetti Icon Composer Liquid Glass per i target pubblico e Dev, con una
  variante Dark realmente scura e verifiche dedicate di struttura, collegamento Xcode,
  Clear e Tinted sulla Home Screen del simulatore; prove real-device e user test sono
  pianificati in Alpha, mentre ratifica e chiusura di `DG-ICON` restano in Beta.
- Adottato il nuovo modello commerciale: Routally 1.0 completamente gratuita e senza
  limiti, core 1.0 gratuito permanente, tutti i 12 Kit inclusi e StoreKit differito;
  Plus 1.X richiede un Premium Value Gate in due checkpoint e sarà un acquisto una tantum
  da 29,99 €.
- Semplificato il Master Plan senza ridurre lo scope 1.0: reducer al posto di proiezioni e
  Consistency Engine, un solo confine di store, misure derivate da baseline reali,
  tracciabilità non duplicata e un'unica checklist operativa.
- Inizializzata la baseline di repository e governance.
- Allineati bootstrap Git, workflow degli agenti e segnalazioni di sicurezza private.
- Aggiunto il gate required della review Codex sull'HEAD corrente delle pull request.
- Completata la baseline GitHub con CodeQL Swift, Dependabot Actions e policy SHA-pinned.
- Aggiunti Decision Register e ADR baseline per iOS 26, registro eventi deterministico e SwiftData/CloudKit.
- Adottato il workflow di design SwiftUI-first con Xcode Previews, Simulator e Icon Composer.
- Completata E02 con UI Foundation Liquid Glass, token semantici, navigazione adattiva,
  flusso di creazione, vertical slice e criteri di accessibilità.
- Implementata E03 con progetto Xcode, target Dev/Public/Test, xcconfig, moduli SwiftPM
  locali, feature flag, fixture Dev, token Asset Catalog, preview matrix e vertical slice
  SwiftUI interattiva su iPhone e iPad.
- Riallineata la UI Foundation E03 al contratto Liquid Glass: CTA primarie glass,
  `CycleVisualization` riusabile, stati accessibili e preview dedicate.
- Stabilizzata M01 senza anticipare il Core Routine Engine: localizzazione SwiftUI
  differita tramite `LocalizedStringResource`, ownership unica del router, creazione
  suddivisa in step testabili con salvataggio ed errore recuperabile, coerenza del ciclo
  dopo le esclusioni e identità esplicita delle notifiche sintetiche.
- Master Plan: nella precedente baseline i limiti Free erano stati portati a 10 routine
  e 5 collegamenti; la parte commerciale di quella decisione è ora sostituita dal core
  1.0 completamente gratuito. Restano validi lettura selettiva, gestione dello scope,
  TG-RECALC, soglie beta qualitative e regola deterministica per «Questa settimana».
- Aggiunto ADR-0005: la review delle pull request è un gate di CI e non un ruolo di agente.
- Consolidata la preparazione di `DG-ICON`: livelli SVG autonomi per tutte le varianti,
  rifiniture A1 testa/Lavender/Amber, tavole dimensionali riproducibili, validazione
  geometrica indipendente, checklist Icon Composer e dispositivi, protocollo di user test,
  ricerca preliminare di originalità e decision record ancora aperto.
- Promossa A1 Lavender con testa 50 a baseline canonica dell'icona e riallineati asset, derivata Dev, controlli e protocolli residui.
