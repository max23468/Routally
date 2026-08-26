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

Il gate `codex-review` distingueva già P0/P1 bloccanti da P2/P3 advisory, mentre la branch
protection richiedeva comunque la risoluzione di ogni conversazione. Auto-merge era
disabilitato.

## Decisione

La pubblicazione usa un modello proporzionato e deterministico:

1. un classificatore condiviso sceglie i controlli locali e CI in base ai file modificati;
2. ogni PR produce un unico `publication-gate` aggregato sull'HEAD e sempre conclusivo;
3. format, build/test, verifiche documentali e CodeQL applicabili girano in parallelo;
4. CodeQL Swift valida la PR, mentre `main` mantiene soltanto la scansione settimanale;
5. la review Codex invalida subito i vecchi SHA, esegue polling ogni 30 secondi e scade
   dopo un'ora;
6. P2/P3 non bloccano tramite la risoluzione generica delle conversazioni;
7. lo squash auto-merge integra la PR quando i gate richiesti sono verdi;
8. dopo il merge si verifica l'equivalenza del tree anziché ripetere gli stessi gate.

Le modifiche UI continuano a richiedere evidenza visuale reale, registrata marcando il
checkbox dedicato nel corpo della PR; il gate la verifica e resta rosso se manca. Release,
deploy, TestFlight e App Store conservano le rispettive autorizzazioni e prove manuali.

## Conseguenze

- Le modifiche documentali ordinarie non avviano runner macOS.
- Master Plan, ADR e governance mantengono controlli semantici e strutturali dedicati.
- Il tempo di una PR Swift è il massimo dei gate paralleli, non la loro somma.
- Un monitor settimanale fallito genera lavoro correttivo ma non cambia retroattivamente
  l'evidenza di una PR già validata e pubblicata.
- Il workflow trusted di `main` invalida subito l'esito precedente, classifica il diff ed
  esegue i job sul merge proposto con permessi di sola lettura; soltanto il job finale
  pubblica `publication-gate` sull'HEAD, inclusi i PR Dependabot.
- Il repository richiede `codex-review` e `publication-gate`, consente auto-merge e non
  richiede la risoluzione generica delle conversazioni.

## Riferimenti

- Master Plan, sezioni 28.3.1–28.3.3.
- `scripts/change-policy.mjs`, `scripts/verify-change.mjs` e
  `scripts/verify-merge-tree.mjs`.
- `.github/workflows/publication-gate.yml` e `.github/workflows/codex-review-gate.yml`.
