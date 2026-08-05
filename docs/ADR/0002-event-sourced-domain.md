# ADR 0002 — Dominio event-sourced

- **Stato:** Accepted
- **Data:** 2026-08-05
- **Ambito:** Routally 1.0

## Contesto

Una registrazione può aggiornare più obiettivi e cicli, generare follow-up e venire
corretta o eliminata successivamente. Lo stato deve restare deterministico anche con
sincronizzazione offline e consegna CloudKit fuori ordine.

## Decisione

Eventi e revisioni sono la fonte canonica. Stato corrente, Oggi, follow-up, ricerca,
Analisi e widget sono proiezioni materializzate e ricostruibili.

## Conseguenze

- correzioni e annullamenti producono ricalcoli deterministici;
- retry e sincronizzazione devono essere idempotenti;
- ogni invariante di dominio richiede un test automatico;
- le cache non possono diventare fonte di verità.

## Riferimenti

- Master Plan, sezioni 15, 16, 21 e 35.
