# Baseline prestazionale del motore

- **Data:** 2026-09-04
- **Stato:** baseline di sviluppo
- **Dispositivo:** iPhone 17 Pro Simulator, iOS 26.5
- **Configurazione:** Development, Xcode 26.6
- **Baseline Git:** `origin/main` `508d0e6`
- **Dataset:** 50 routine attive, 200 archiviate, 10.000 eventi, 100 link, 500 cicli,
  500 revisioni e 100 tombstone

Questa baseline misura il percorso usato da caricamento e commit dello store. Non sostituisce
il gate Release Candidate su dispositivo fisico previsto dalla sezione 36 del Master Plan.

## Metodo

`PerformanceTests` esegue cinque iterazioni per misura tramite `XCTClockMetric` e
`XCTMemoryMetric`. I test TG-RECALC e persistenza sono stati ripetuti cinque volte a
processo caldo per includere rispettivamente due ordini di replay e il percorso SwiftData.

```sh
xcodebuild test \
  -project Routally.xcodeproj \
  -scheme "Routally Tests" \
  -configuration Development \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=26.5' \
  -only-testing:'Routally Tests/PerformanceTests'
```

## Collo di bottiglia

Prima dell'intervento, il reducer completo richiedeva in media 0,663 s; lo stesso dataset
senza cicli richiedeva 0,248 s. Il 63% circa del tempo era quindi attribuibile
all'aggiornamento delle proiezioni dei cicli: ogni contributo leggeva e riscriveva nel
dizionario tutte le proiezioni coinvolte. La risoluzione canonica del ledger creava inoltre
un array intermedio per ciascun UUID tramite `Dictionary(grouping:)`.

## Risultati

Tutti i valori sono medie di cinque esecuzioni comparabili.

| Misura | Prima | Dopo | Variazione |
| --- | ---: | ---: | ---: |
| Risoluzione ledger | 0,102 s | 0,070 s | -31,4% |
| Riduzione completa | 0,663 s | 0,379 s | -42,8% |
| Picco memoria riduzione | 39,2 MB | 35,0 MB | -10,9% |
| TG-RECALC end-to-end | 1,323 s | 0,846 s | -36,1% |
| Persistenza + ricalcolo | 2,579 s | 2,024 s | -21,5% |

## Intervento

- La selezione canonica di eventi, revisioni e tombstone ora avviene in un singolo passaggio,
  senza gli array intermedi creati dal raggruppamento.
- Il reducer aggiorna accumulatori locali condivisi per i cicli e materializza il dizionario
  pubblico una sola volta al termine.
- Nessuna cache, dipendenza o stato persistente derivato è stato introdotto.

## Verifica e limiti

La suite completa contiene 75 test e preserva convergenza, ordine canonico, correzioni,
tombstone, cancellazione e assenza di stato parziale. Cold launch, scroll, energia e memoria
su dispositivo minimo supportato restano misure obbligatorie della Release Candidate; questa
baseline Simulator non autorizza soglie o conclusioni su quel gate.
