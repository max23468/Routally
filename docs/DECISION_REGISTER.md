# Decision Register

`docs/MASTER_PLAN.md` resta la fonte canonica. Questo registro rende rintracciabili le
decisioni difficili da invertire e i Decision Gate ancora aperti, senza duplicarne la
specifica completa.

| ID | Decisione | Stato | Versione | Motivazione | Impatto | Data |
|---|---|---|---|---|---|---|
| ADR-0001 | iOS e iPadOS 26 come minimo | Confirmed | 1.0 | Un solo linguaggio Apple-native basato su Liquid Glass | Nessuna UI legacy | 2026-08-05 |
| ADR-0002 | Eventi e revisioni come fonte canonica | Confirmed | 1.0 | Ricalcolo deterministico, correzione e sincronizzazione affidabile | Lo stato deriva da un reducer; cache solo dopo misure | 2026-08-05 |
| ADR-0003 | SwiftData e CloudKit come persistenza | Confirmed | 1.0 | Persistenza local-first e sincronizzazione privata Apple-native | `TG-DATA` può richiedere il fallback Core Data/CloudKit | 2026-08-05 |
| ADR-0004 | Design UI SwiftUI-first | Confirmed | 1.0 | Evitare divergenza tra specifiche statiche e interfaccia reale | Preview eseguibili e Simulator diventano la verifica visuale primaria | 2026-08-06 |
| ADR-0005 | La review delle pull request è un gate di CI | Confirmed | 1.0 | Risolve il conflitto fra esclusività degli agenti e gate required su ogni PR | Il gate vale per ogni PR e non richiede handoff fra agenti | 2026-08-14 |
| ADR-0006 | Core 1.0 gratuito e Plus additivo | Confirmed | 1.0–1.X | Prima validare il prodotto; monetizzare soltanto nuove capacità sostanziali | Elimina limiti e StoreKit dalla 1.0; introduce Premium Value Gate | 2026-08-23 |
| MP-FREE-LIMITS | Limiti Free a 10 routine e 5 collegamenti | Superseded | 1.0 | La strategia freemium quantitativa è stata abbandonata | Sostituita da `MP-FREE-CORE`; nessun limite commerciale nella 1.0 | 2026-08-23 |
| MP-FREE-CORE | Tutto il core pubblicato nella 1.0 resta gratuito e illimitato | Confirmed | 1.0+ | Adozione, fiducia e product–market fit precedono la monetizzazione | Nessun paywall retroattivo o quota su routine, link, Kit, cronologia, luoghi o widget | 2026-08-23 |
| MP-PLUS-1X | Plus additivo a 29,99 € una tantum, senza abbonamento | Confirmed | 1.X | Le capacità locali Apple non generano costi cloud ricorrenti | Acquisto permanente soltanto dopo `DG-PLUS-LAUNCH` | 2026-08-23 |
| MP-SCOPE-1.0 | Scope funzionale completo nella 1.0 | Confirmed | 1.0 | Il Product Owner accetta l’ampiezza e non autorizza rinvii automatici | Se la qualità non basta slitta la data; ogni taglio richiede change control | 2026-08-23 |
| MP-ICON-DIRECTION | Direzione dell’icona: monogramma `R` costruito attorno a un ciclo | Confirmed | 1.0 | Le direzioni alternative sono state costruite e archiviate | Vincola la costruzione; `DG-ICON` resta aperto per variante, resa Apple e originalità | 2026-08-21 |
| MP-ICON-BASELINE | Baseline icona A1 Lavender con testa 50 | Confirmed | 1.0 | Miglior equilibrio visivo dopo confronto SVG | Non chiude `DG-ICON`: restano prove Apple, dispositivi, user test e rischio figurativo | 2026-08-21 |
| TG-DATA | Spike SwiftData/CloudKit | Decision Gate — Adapt candidato | 0.1 | Evidenze locali positive e probe Dev multi-client/App Group pronto; il Personal Team attuale non abilita la prova firmata CloudKit | Blocca E05 finché sincronizzazione, recovery e schema Development non sono verificati su un team Apple Developer; schema Production definitivo in E21 | — |
| TG-RECALC | Spike sul ricalcolo retroattivo deterministico | Decision Gate | 0.2 | Il ricalcolo è il cuore differenziante e il candidato più probabile a non scalare | Determina la strategia di ricalcolo prima delle feature dipendenti | — |
| TG-STOREKIT | Spike sul prodotto non consumabile Plus | Decision Gate | 1.X | StoreKit non serve alla 1.0 gratuita e va validato sul bundle reale | Si apre dopo il checkpoint A di `DG-PLUS-LAUNCH` e precede il checkpoint B | — |
| DG-DOMAIN | Registrazione dominio, DNS ed email | Decision Gate | 0.5 | Servono ownership e recovery definitive | Blocca Universal Links, supporto e identificativi pubblici definitivi | — |
| DG-TRADEMARK | Verifica formale di Routally e Temisfera | Decision Gate | 1.0 | La verifica preliminare non equivale a clearance | Influenza tutela e uso commerciale del brand | — |
| DG-ICON | Scelta dell’icona definitiva | Decision Gate | 1.0 | Richiede SVG validati, Icon Composer, dispositivi, user test e verifica figurativa | Blocca file `.icon` e asset App Store finali | — |
| DG-DEVELOPER-IDENTITY | Identità legale dello sviluppatore | Decision Gate | 0.8 | Account Holder e trasferibilità devono essere definiti | Blocca gli asset Apple definitivi | — |
| DG-LAUNCH | Data di lancio ed eventuale preordine | Decision Gate | 0.9 | Richiede una Release Candidate stabile | Blocca comunicazione e rilascio pubblico | — |
| DG-PLUS-LAUNCH | Bundle e lancio di Routally Plus | Decision Gate | 1.X | Due checkpoint separano approvazione del bundle e autorizzazione al lancio | Il checkpoint A apre `TG-STOREKIT`; il checkpoint B autorizza la pubblicazione | — |
| DG-CLOUD-PRICING | Modello cloud e prezzi 2.0 | Decision Gate | 2.0 | Dipende dai costi reali del backend | Determina piani cloud preservando il core gratuito e i diritti Plus locali | — |
| DG-FUTURE-ANALYTICS | Eventuali analytics privacy-first | Decision Gate | Future | Valutabili solo se gli strumenti Apple risultano insufficienti | Richiede nuova decisione privacy e App Store | — |

## Regole di aggiornamento

- Una decisione cambia stato soltanto con approvazione del Product Owner.
- La motivazione completa resta nel Master Plan o nell’ADR collegato.
- La chiusura di un gate registra data, versione e documento che ne dimostra l’esito.
- Le decisioni sostituite restano nel Master Plan come `Superseded`.
