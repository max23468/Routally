# Preview matrix — E03

- **Stato:** Implemented
- **Epic:** E03 — Xcode & SwiftUI Foundation
- **Target:** iOS e iPadOS 26

La matrice rende verificabili gli stati della UI Foundation senza dati o servizi
reali. Le fixture di lancio sono sintetiche, deterministiche e collegate soltanto a
`Routally Dev`; il target pubblico non dipende da `RoutallyFixtures`. Le fixture usate
direttamente dalle preview sono racchiuse in `#if DEBUG` nel modulo UI.

Le stringhe UI generate dal catalogo restano `LocalizedStringResource` fino alla view,
così la `Locale` dell'ambiente SwiftUI viene applicata anche nelle preview. I pochi testi
che devono vivere come `String` nelle fixture sintetiche vengono invece risolti
esplicitamente nella locale richiesta dalla fixture; la preview inglese non dipende quindi
dalla locale del processo Xcode.

## Matrice eseguibile

| View/stato | Device/layout | Aspetto e lingua | Dynamic Type | Evidenza |
|---|---|---|---|---|
| Primo ingresso | iPhone portrait | Light, IT | Default | `RoutallyRootView` preview e Simulator |
| Adesso / Più tardi / settimana | iPhone portrait e landscape | Light, IT | Default | `RoutallyRootView` preview |
| Soglia in attesa | iPhone portrait | Dark, IT | Default | `RoutallyRootView` preview e Simulator |
| Follow-up pronto | iPhone portrait | Light, IT | Default | `RoutallyRootView` preview |
| Offline con modifiche pendenti | iPhone portrait | Light, EN | Default | `RoutallyRootView` preview |
| Errore recuperabile | iPhone portrait | Light, IT | Default | `RoutallyRootView` preview |
| Routine + dettaglio | iPad landscape e portrait | Light/Dark, IT | Default/AX5 | `RoutallyRootView` preview |
| Creazione iniziale | iPhone portrait | Light, IT | Default | `CreationSheet` preview e Simulator |
| Creazione riepilogo | iPhone portrait | Dark, IT/EN | Default/AX5 | `CreationSheet` preview e Simulator |
| Creazione con errore recuperabile | iPhone portrait | Light, IT | Default | `CreationSheet` preview |
| Conseguenze con esclusioni indipendenti | iPhone portrait | Light/Dark, IT | Default/AX5 | preview, Simulator e test store |
| Ricerca con risultati / vuota | iPhone portrait | Light/Dark, IT | Default/AX5 | `SearchView` preview |
| Profilo Free / Plus | iPhone portrait | Light/Dark, IT | Default | `ProfileSheet` preview |
| Ciclo attivo / soglia / follow-up / completo | iPhone portrait | Light/Dark | Default/AX5 | preview di `CycleVisualization` |

`AX5` corrisponde a `DynamicTypeSize.accessibility5`. Le preferenze di accessibilità
sono verificate sul Simulator perché contrasto aumentato, Riduci trasparenza e Riduci
movimento sono valori di sistema non iniettabili nelle preview. La prova combinata
Dark + contrasto aumentato + Riduci trasparenza + Riduci movimento + AX5 mantiene
leggibili e raggiungibili mediante scroll sia la routine sia le due azioni `Escludi`.

I controlli Liquid Glass usano gli stili SwiftUI nativi. Le superfici glass custom
del ciclo sono raggruppate in `GlassEffectContainer`; non esistono materiali o fallback
grafici concorrenti per versioni precedenti a iOS 26.

## Fixture canoniche

`EmptyProfile`, `NewUser`, `TypicalUser`, `HighlyOrganizedUser`, `ThresholdReached`,
`OfflineWithPendingChanges`, `CloudConflict`, `FreeLimitReached`, `PlusUser` e
`LargeHistory` sono rappresentate da `DemoScenario` nel solo modulo
`RoutallyFixtures` e verificate dalla suite Swift Testing. Il launch argument canonico
è:

```text
-launchMode demo -demoScenario connectedGymCycle
```

La build Release del target `Routally` non include il modulo, il bundle, i simboli o
gli argomenti degli scenari demo.

## Verifiche della vertical slice

La prova interattiva su iPhone copre:

1. creazione nativa in cinque passi con nome, simbolo, area, obiettivo, collegamento,
   soglia, follow-up, momento utile, fallback e riavvio ciclo configurabili;
2. apertura programmatica del dettaglio dopo la creazione e da `Visualizza Palestra`;
3. registrazione dell'evento sorgente e riepilogo delle conseguenze;
4. `Escludi` separato per ciclo collegato e follow-up, oltre ad `Annulla registrazione`;
5. IT/EN, stato offline, errore recuperabile e preferenze di accessibilità sopra elencate.

`CreationSheet` orchestra soltanto navigazione, dismissal e submit; stato e validazione
del form sono separati dalle view dei singoli step. Il fallback partecipa al dirty state,
l'area viene conservata come chiave stabile nella configurazione sintetica e resa visibile
nel dettaglio della routine creata.

La suite automatica protegge fixture, idempotenza arrivo/fallback, selezione corretta dei
follow-up per l'arrivo a casa, conteggio delle notifiche, undo atomico, esclusioni
indipendenti, applicazione del draft e path di navigazione. Motore event-sourced,
persistenza, geofencing e notifiche reali restano nelle epiche e nei Technical Gate
previsti dal Master Plan; E03 usa simulazioni locali Dev.
