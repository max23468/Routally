# ADR-0007 — Pubblicazione proporzionata con gate aggregato

- **Stato:** Confirmed
- **Data:** 2026-08-27
- **Ambito:** Governance della repository

## Contesto

Il ciclo precedente eseguiva controlli corretti ma non sempre proporzionati. La review
Codex interrogava GitHub ogni tre minuti e poteva occupare un runner per cinque ore;
CodeQL Swift partiva soltanto dopo il merge e aggiungeva circa venti-trenta minuti alla
rilettura finale. Build, test e format potevano inoltre essere ripetuti senza distinguere
fra documentazione, dominio, UI e configurazioni critiche.

Auto-merge era disabilitato.

## Decisione

La pubblicazione usa un modello proporzionato e deterministico:

1. un classificatore condiviso sceglie i controlli locali e CI in base ai file modificati;
2. ogni PR produce un unico `publication-gate` aggregato sull'HEAD e sempre conclusivo;
3. verifiche documentali, format e CodeQL applicabili girano in parallelo; build/test
   Simulator restano sul Mac controllato e sono attestati da uno status trusted sull'HEAD esatto;
4. CodeQL Swift valida la PR quando cambiano sorgenti Swift applicativi, configurazioni
   Xcode/SwiftPM o la configurazione CodeQL dedicata; modifiche esclusivamente ai test Swift
   non avviano una scansione che non li includerebbe, mentre `main` mantiene la scansione settimanale;
   il package graph viene risolto prima dell'inizializzazione CodeQL e riusato dalla build
   strumentata con risoluzione automatica e aggiornamenti disabilitati; l'analisi PR non carica
   il database CodeQL e consegna al job trusted soltanto il SARIF; la scansione settimanale
   applica lo stesso confine fra analisi read-only e upload privilegiato senza checkout;
5. lo squash auto-merge integra la PR quando i gate richiesti sono verdi;
6. dopo il merge si verifica l'equivalenza del tree anziché ripetere gli stessi gate.

Le modifiche UI continuano a richiedere evidenza visuale reale. Il checkbox dedicato nel corpo
della PR la documenta, ma il gate accetta soltanto `manual-evidence/visual` registrato sull'HEAD
da un workflow manuale trusted; build e test Apple usano `manual-evidence/apple`. Il workflow
non esegue codice del repository e riesegue il consolidatore relativo allo stesso HEAD. Release,
deploy, TestFlight e App Store conservano le rispettive autorizzazioni e prove manuali.

## Conseguenze

- Le modifiche documentali ordinarie non avviano runner macOS.
- Master Plan, ADR e governance mantengono controlli semantici e strutturali dedicati.
- Una modifica alla sola orchestrazione del gate conserva build, format e test di governance,
  ma non ricompila l'app sotto CodeQL; una modifica alla configurazione CodeQL dedicata sì.
- La pre-risoluzione SwiftPM esterna all'estrazione elimina dal percorso CodeQL il costo di
  preparazione del package graph senza riutilizzare artefatti Swift già compilati.
- Un aggiornamento al solo titolo o corpo della PR riusa l'analisi riuscita soltanto se GitHub
  conferma lo stesso merge SHA, la categoria PR prevista e il job trusted di upload; qualsiasi
  assenza, errore o divergenza provoca una nuova scansione completa.
- Le modifiche esclusivamente ai test Swift mantengono format, build e test Apple applicabili,
  ma non attendono una scansione dello scheme applicativo che non compila quei file.
- Il tempo di una PR Swift è il massimo dei gate paralleli, non la loro somma.
- Un monitor settimanale fallito genera lavoro correttivo ma non cambia retroattivamente
  l'evidenza di una PR già validata e pubblicata.
- La scansione settimanale non espone `security-events: write` a checkout, package resolution,
  build o analisi; solo il job di upload senza checkout riceve quel permesso.
- Il workflow trusted di `main` invalida subito l'esito precedente, classifica il diff ed
  esegue i job sul merge proposto con permessi di sola lettura; CodeQL produce un SARIF come
  dato, disabilita l'upload ridondante del database e lascia a un job trusted separato il
  caricamento del risultato. Soltanto i job trusted pubblicano stato,
  incluso `publication-gate` sull'HEAD dei PR Dependabot.
- Il repository richiede `publication-gate` e consente auto-merge.

## Riferimenti

- Master Plan, sezioni 28.3.1–28.3.2.
- `scripts/change-policy.mjs`, `scripts/verify-change.mjs` e
  `scripts/verify-merge-tree.mjs`.
- `.github/workflows/publication-gate.yml`.
- `.github/workflows/manual-evidence.yml` e `.github/workflows/codeql.yml`.
