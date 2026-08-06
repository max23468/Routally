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
| DG-DOMAIN | Registrazione dominio, DNS ed email | Decision Gate | 1.0 | Servono ownership e recovery definitive | Blocca dominio e identificativi pubblici definitivi | — |
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
