# Changelog

Le modifiche rilevanti a Routally saranno documentate in questo file.

## Unreleased

- Approvato e formalizzato Trama per Oggi, dettaglio e conseguenze, con anteprima
  calcolata dal reducer senza scritture, prototipi Dev degli altri stati, localizzazione
  IT/EN e prove iPhone/iPad Simulator. DG-VISUAL chiuso; E06/M03 resta aperta per la
  prova end-to-end su dispositivo fisico. Le epiche E07–E11 non sono implementate.

- Implementata E05 con il modulo `RoutallyData`: schema SwiftData locale V1, piano di
  migrazione baseline, store `ModelActor` testabile, configurazioni in-memory/file/Apple
  esplicite e iniettate, payload V1 dichiarati, deduplica UUID anche per record già
  materializzati, rilevamento delle routine coinvolte incluse quelle eliminate dal
  catalogo, commit atomico dopo il ricalcolo, offline e recovery su disco; le garanzie E05
  dello spike dati duplicato sono state assorbite nelle regressioni del modulo di prodotto.
- Registrato `DG-VISUAL`: il checkpoint visuale di E06 deve essere approvato e
  formalizzato prima di estendere il linguaggio dell'interfaccia alle epiche E07-E11.
- Reso proporzionato il ciclo di pubblicazione: classificazione condivisa locale/CI,
  gate PR aggregato, CodeQL pre-merge, review Codex più reattiva, P2/P3 non bloccanti,
  riaperture serializzate, squash auto-merge ed equivalenza del tree al posto delle
  verifiche duplicate; disattivata fino a E13 l'estrazione App Intents non applicabile,
  eliminandone il warning Xcode.
- Implementata E04 come motore di dominio puro: tipi forti, calendario locale, registro
  eventi con revisioni e tombstone, reducer deterministico, collegamenti diretti, cicli,
  follow-up, correzioni retroattive, invarianti e test dei quattro archetipi canonici.
- Chiuso `TG-RECALC` con esito **Async boundary** sul dataset da 10.000 eventi: reducer
  sincrono puro, ricalcolo cancellabile fuori dal `MainActor`, convergenza tra ordini di
  consegna e risultato atomico senza proiezioni persistenti.
- Completato l'audit di E03: gli accenti Asset Catalog espongono ora tutte le varianti
  Light/Dark e Increase Contrast con controllo CI dedicato, mentre le fixture di lancio
  vengono caricate soltanto con la modalità `demo` esplicita.
- Chiuso `TG-DATA` con esito Adapt: spike SwiftData isolato, schema e migrazione
  versionati, deduplica e riconciliazione UUID, revisioni/tombstone, recovery locale,
  condivisione app-widget, configurazione App Group/CloudKit e dataset canonico da 10.000
  eventi coperti da test; la prova reale CloudKit Development resta pianificata in M10.
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
