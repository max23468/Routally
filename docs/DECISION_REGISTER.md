# Decision Register

`docs/MASTER_PLAN.md` resta la fonte canonica. Questo registro rende rintracciabili le
decisioni difficili da invertire e i Decision Gate ancora aperti, senza duplicarne la
specifica completa.

| ID | Decisione | Stato | Versione | Motivazione | Impatto | Data |
|---|---|---|---|---|---|---|
| ADR-0001 | iOS e iPadOS 26 come minimo | Confirmed | 1.0 | Un solo linguaggio Apple-native basato su Liquid Glass | Nessuna UI legacy | 2026-08-05 |
| ADR-0002 | Eventi e revisioni come fonte canonica | Confirmed | 1.0 | Ricalcolo deterministico, correzione e sincronizzazione affidabile | Le proiezioni restano ricostruibili | 2026-08-05 |
| ADR-0003 | SwiftData e CloudKit come adapter predefinito | Confirmed | 1.0 | Persistenza local-first e sincronizzazione privata Apple-native | `TG-DATA` può richiedere un adapter Core Data/CloudKit | 2026-08-05 |
| ADR-0004 | Design UI SwiftUI-first | Confirmed | 1.0 | Evitare divergenza tra specifiche statiche e interfaccia reale | Preview eseguibili e Simulator diventano la verifica visuale primaria | 2026-08-06 |
| ADR-0005 | La review delle pull request è un gate di CI | Confirmed | 1.0 | Risolve il conflitto fra esclusività degli agenti e gate required su ogni PR | Il gate vale per ogni PR e non richiede handoff fra agenti | 2026-08-14 |
| MP-FREE-LIMITS | Limiti Free a 10 routine e 5 collegamenti | Confirmed | 1.0 | Con 5 e 2 un utente Free non poteva installare i 4 Kit introduttivi promessi | Rivedibile a 90 giorni, mai sotto la soglia dei 4 Kit | 2026-08-14 |
| MP-WATERLINE | Linea di galleggiamento pre-approvata della 1.0 | Confirmed | 1.0 | Trasforma il rischio di scope da processo a scelta già presa | Ordine di sacrificio attivabile dal solo Product Owner | 2026-08-14 |
| TG-RECALC | Spike sul ricalcolo retroattivo deterministico | Decision Gate | 0.2 | Il ricalcolo è il cuore differenziante e il candidato più probabile a non scalare | Determina la strategia di ricalcolo prima di proiezioni e interfaccia | — |
| DG-DOMAIN | Registrazione dominio, DNS ed email | Decision Gate | 0.5 | Servono ownership e recovery definitive | Blocca Universal Links, supporto e identificativi pubblici definitivi | — |
| DG-TRADEMARK | Verifica formale di Routally e Temisfera | Decision Gate | 1.0 | La verifica preliminare non equivale a clearance | Influenza tutela e uso commerciale del brand | — |
| DG-ICON | Scelta dell'icona definitiva | Decision Gate | 1.0 | Richiede esplorazione SVG, Icon Composer e user test | Blocca gli asset App Store finali | — |
| DG-DEVELOPER-IDENTITY | Identità legale dello sviluppatore | Decision Gate | 0.8 | Account Holder e trasferibilità devono essere definiti | Blocca gli asset Apple definitivi | — |
| DG-LAUNCH | Data di lancio ed eventuale preordine | Decision Gate | 0.9 | Richiede una Release Candidate stabile | Blocca comunicazione e rilascio pubblico | — |
| DG-CLOUD-PRICING | Modello cloud e prezzi 2.0 | Decision Gate | 2.0 | Dipende dai costi reali del backend | Determina piani cloud e diritti futuri | — |
| DG-FUTURE-ANALYTICS | Eventuali analytics privacy-first | Decision Gate | Future | Valutabili solo se gli strumenti Apple risultano insufficienti | Richiede nuova decisione privacy e App Store | — |

## Regole di aggiornamento

- Una decisione cambia stato soltanto con approvazione del Product Owner.
- La motivazione completa resta nel Master Plan o nell'ADR collegato.
- La chiusura di un gate registra data, versione e documento che ne dimostra l'esito.
- Le decisioni sostituite restano nel Master Plan come `Superseded`.
