# ADR-0009 — Integrazione applicativa della vertical slice

- **Stato:** Confirmed
- **Data:** 2026-08-27
- **Ambito:** E06 — Vertical Slice Integration

## Contesto

E03 aveva reso interattivo il flusso canonico usando uno snapshot di presentazione
mutato direttamente dal modello UI. E04 ha poi introdotto registro, revisioni, reducer e
ricalcolo deterministico; E05 ha aggiunto lo store SwiftData transazionale. Mantenere due
implementazioni delle stesse regole avrebbe permesso alla UI e al dominio di divergere
proprio sui casi distintivi di Routally: conseguenze collegate, esclusione, undo,
follow-up e reset del ciclo.

L'integrazione ha inoltre reso visibili due rappresentazioni incomplete: una routine
guidata da un ciclo veniva adattata a una frequenza non pertinente e il fallback
geografico era espresso come intervallo, benché l'utente scelga un orario locale come le
20:00.

## Decisione

`RoutallyFeatureModel` è il confine applicativo `@MainActor` osservato da SwiftUI. Non
contiene un secondo motore: traduce le intenzioni dell'utente in catalogo, eventi,
revisioni e tombstone, invia una sola modifica a `RoutallyData.RoutallyStore` e pubblica
la proiezione restituita dal dominio.

Le operazioni visibili sono asincrone e serializzate dal modello di feature. Durante una
scrittura i controlli pertinenti sono disabilitati; un doppio tocco non genera due eventi.
Errori e cancellazioni non pubblicano una proiezione parziale. Le fixture puramente
visuali restano snapshot immutabili da preview, mentre lo scenario
`connectedGymCycle` usa realmente E04 ed E05 con uno store in-memory isolato.

La configurazione persistente della routine include `RoutineAppearance`, composto da
identificatore dell'area e nome SF Symbol. `FrequencyRule.cycleDriven` rappresenta una
routine il cui comportamento temporale deriva dal proprio ciclo, senza inventare una
frequenza periodica. Il fallback di `UsefulMomentPolicy.geographic` conserva un
`LocalTime`; il reducer calcola la prima occorrenza locale non precedente alla creazione
del follow-up.

E06 usa uno scheduler concreto in-memory che deduplica le consegne tramite l'identità del
follow-up e le invalida quando una correzione rimuove la conseguenza. Il luogo simulato
viene filtrato direttamente dalla feature. `RoutallyClock` resta iniettabile per rendere
deterministici data, periodo e fallback.

I confini nativi per notifiche e posizione verranno introdotti in E12, quando esisteranno
i relativi lifecycle di sistema. E14 aggiungerà gli stati iCloud senza esporre SwiftData
alla feature.

## Conseguenze

- creazione, registrazione, completamento, esclusione e undo attraversano lo stesso
  registro persistente;
- il riepilogo delle conseguenze è una proiezione dell'evento appena registrato, non una
  mutazione parallela;
- l'esclusione produce `EventRevision`, l'undo produce `EventTombstone` e il completamento
  produce un nuovo `RoutineEvent`;
- offline significa scrittura locale completa con stato pendente, senza dipendere da rete
  o CloudKit;
- i trigger di sistema completi, il dispositivo principale e la sincronizzazione reale
  restano fuori da E06;
- non viene mantenuta compatibilità con gli snapshot mutabili di E03: non esistono
  consumatori esterni e le regressioni vengono trasferite alla vertical slice reale.

## Riferimenti

- Master Plan, sezioni 14–16, 18, 21, 25, 35, 37.2, 40, 48.3 e 49.
- ADR-0002, ADR-0003 e ADR-0008.
- `docs/DESIGN/creation-flow.md`.
- `docs/ENGINEERING/preview-matrix.md`.
