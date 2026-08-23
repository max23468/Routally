# Navigazione 1.0 iPhone

- **Stato:** Confirmed
- **Epic:** E02 — Apple-native UI Direction
- **Fonte canonica:** [Master Plan](../MASTER_PLAN.md), sezioni 2 e 3

## Principi

- Le aree stabili della 1.0 sono Oggi, Routine ed Esplora.
- Profilo è una sheet aperta dalla toolbar.
- Ogni tab conserva posizione e percorso quando si cambia area.
- La tab bar naviga; `+`, Profilo e azioni contestuali vivono nelle toolbar.
- Componenti SwiftUI nativi producono Liquid Glass e accessibilità di sistema.
- Analisi e Cerca restano prototipi Dev della Foundation e passano alla 1.1.

## Struttura iPhone

Un `TabView` contiene tre destinazioni, ognuna con il proprio `NavigationStack`.

| Destinazione | Radice | Toolbar | Dettaglio |
| --- | --- | --- | --- |
| Oggi | Calm View | Profilo | push alla routine o al follow-up |
| Routine | lista | `+`, Profilo | push |
| Esplora | quattro Kit | Profilo | push all'anteprima |

La tab bar resta l'orientamento persistente e può minimizzarsi con il comportamento di
sistema. Non viene nascosta programmaticamente.

## Presentazioni

- `+` apre Nuova routine in una sheet con `NavigationStack` dedicato;
- Profilo apre una sheet navigabile;
- il riepilogo conseguenze usa una sheet compatta espandibile;
- le azioni distruttive richiedono conferma;
- una sheet modificata chiede se conservare o scartare soltanto quando la chiusura
  perderebbe dati.

## Destinazioni e ritorno

- una notifica apre l'elemento pertinente in Oggi o Routine;
- un widget o App Intent apre una destinazione locale tipizzata;
- dopo la creazione si apre il dettaglio della nuova routine;
- `Annulla`, `Escludi` e `Fatto` non cambiano tab senza richiesta dell'utente.

Universal Links e routing da web sono 1.1. Nessun router 1.0 contiene placeholder per
Associated Domains.

## iPad e funzioni rinviate

La Foundation può continuare ad adattarsi a iPad e contenere preview di Analisi e Cerca.
Questi elementi non fanno parte della matrice di release 1.0. `NavigationSplitView`,
tastiera/pointer completi, search role e grafici sono definiti nella roadmap 1.1 e saranno
specificati quando promossi.

## Criteri di accettazione

- le tre tab sono raggiungibili e mantengono il proprio stato;
- il percorso di creazione ha un solo ingresso primario nella tab Routine;
- notifiche, widget e intento aprono contenuti locali esistenti senza duplicare logica;
- tab bar, toolbar e sheet usano superfici di sistema;
- ogni gesto ha un controllo visibile;
- VoiceOver annuncia area, titolo, stato e azione senza duplicazioni.

## Riferimenti

- Apple HIG — [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)
- Apple HIG — [Navigation and search](https://developer.apple.com/design/human-interface-guidelines/navigation-and-search)
- Apple — [Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/)
