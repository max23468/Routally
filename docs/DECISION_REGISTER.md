# Decision Register

`docs/MASTER_PLAN.md` resta la fonte canonica. Questo registro rende rintracciabili le
decisioni difficili da invertire e i Decision Gate ancora aperti, senza duplicarne la
specifica completa.

| ID | Decisione | Stato | Versione | Motivazione | Impatto | Data |
|---|---|---|---|---|---|---|
| ADR-0001 | iOS 26, release 1.0 concentrata su iPhone | Confirmed | 1.0 | Ridurre layout e matrice di release mantenendo SwiftUI/Liquid Glass correnti | iPad ottimizzato passa alla 1.1 | 2026-08-23 |
| ADR-0002 | Journal eventi e reducer deterministico essenziale | Confirmed | 1.0 | Conservare correzione e collegamenti senza una piattaforma event-sourced | Niente proiezioni materializzate o Consistency Engine | 2026-08-23 |
| ADR-0003 | SwiftData locale con backup lossless | Confirmed | 1.0 | Local-first recuperabile senza anticipare conflitti multi-device | CloudKit passa alla 1.1; nessun adapter futuro | 2026-08-23 |
| ADR-0004 | Design UI SwiftUI-first | Confirmed | 1.0 | Evitare divergenza tra specifiche statiche e interfaccia reale | Preview eseguibili e Simulator diventano la verifica visuale primaria | 2026-08-06 |
| ADR-0005 | La review delle pull request è un gate di CI | Confirmed | 1.0 | Risolve il conflitto fra esclusività degli agenti e gate required su ogni PR | Il gate vale per ogni PR e non richiede handoff fra agenti | 2026-08-14 |
| MP-FREE-LIMITS | Limiti Free a 10 routine e 5 collegamenti | Confirmed | 1.0 | Permettono i 4 Kit introduttivi e una routine personale | Rivedibile soltanto senza impedire la prova del ciclo collegato | 2026-08-23 |
| MP-SIMPLIFICATION | Master Plan semplificato e scope 1.0 ridotto | Confirmed | 1.0 | Eliminare duplicazioni e infrastruttura prematura prima del motore | 6 milestone, 12 epiche, 3 gate; scope rinviato in roadmap 1.1+ | 2026-08-23 |
| MP-COMMERCE-SIMPLE | Solo Plus Lifetime nella 1.0 | Confirmed | 1.0 | Free è la prova permanente; rinnovi e downgrade aggiungevano complessità non validata | Annual, trial, grace e Family passano a `DG-ANNUAL` | 2026-08-23 |
| MP-ICON-DIRECTION | Direzione dell'icona: monogramma `R` costruito attorno a un ciclo | Confirmed | 1.0 | Le direzioni alternative sono state costruite e archiviate | Vincola la costruzione; `DG-ICON` resta aperto per variante, resa Apple e originalità | 2026-08-21 |
| MP-ICON-BASELINE | Baseline icona A1 Lavender con testa 50 | Confirmed | 1.0 | Miglior equilibrio visivo dopo confronto SVG | Non chiude `DG-ICON`: restano prove Apple, dispositivi, user test e rischio figurativo | 2026-08-21 |
| TG-DATA | SwiftData locale e backup lossless | Decision Gate | 0.2 | Validare transazioni, round-trip, import idempotente e 10.000 eventi | Non autorizza fallback o adapter preventivi | — |
| TG-RECALC | Ricalcolo mirato deterministico | Decision Gate | 0.2 | La correzione deve preservare gli effetti non coinvolti | Verifica idempotenza e reattività senza proiezioni generiche | — |
| TG-STOREKIT | Plus Lifetime | Decision Gate | 0.5 | Validare acquisto, restore, offline, rimborso e revoca | Blocca E11 commerce | — |
| DG-TRADEMARK | Verifica formale di Routally e Temisfera | Decision Gate | 1.0 | La verifica preliminare non equivale a clearance | Influenza tutela e uso commerciale del brand | — |
| DG-ICON | Scelta dell'icona definitiva | Decision Gate | 1.0 | Richiede SVG validati, Icon Composer, dispositivi, user test e verifica figurativa | Blocca file `.icon` e asset App Store finali | — |
| DG-DEVELOPER-IDENTITY | Identità legale dello sviluppatore | Decision Gate | 0.8 | Account Holder e trasferibilità devono essere definiti | Blocca gli asset Apple definitivi | — |
| DG-LAUNCH | Data di lancio ed eventuale preordine | Decision Gate | 0.9 | Richiede una Release Candidate stabile | Blocca comunicazione e rilascio pubblico | — |
| DG-DOMAIN | Dominio, DNS ed email | Decision Gate | 1.1 | Universal Links e supporto su dominio richiedono ownership definitiva | Non blocca la 1.0 | — |
| DG-ANNUAL | Eventuale Plus Annual | Decision Gate | 1.1 | Richiede retention e disponibilità a pagare osservate | Determina trial, grace, Family e downgrade | — |
| DG-CLOUDKIT | Sincronizzazione multi-device | Decision Gate | 1.1 | Dipende dal modello locale reale e dai test di conflitto | Determina schema, recovery e Production | — |
| DG-CLOUD-PRICING | Modello cloud e prezzi 2.0 | Decision Gate | 2.0 | Dipende dai costi reali del backend | Determina piani cloud e diritti futuri | — |
| DG-FUTURE-ANALYTICS | Eventuali analytics privacy-first | Decision Gate | Future | Valutabili solo se gli strumenti Apple risultano insufficienti | Richiede nuova decisione privacy e App Store | — |

## Regole di aggiornamento

- Una decisione cambia stato soltanto con approvazione del Product Owner.
- La motivazione completa resta nel Master Plan o nell'ADR collegato.
- La chiusura di un gate registra data, versione e documento che ne dimostra l'esito.
- Le decisioni sostituite restano nel Master Plan come `Superseded`.
