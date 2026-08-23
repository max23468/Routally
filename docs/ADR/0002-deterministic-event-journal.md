# ADR 0002 — Registro eventi deterministico

- **Stato:** Confirmed
- **Data:** 2026-08-05
- **Ambito:** Routally 1.0

## Contesto

Una registrazione può aggiornare più obiettivi e cicli, generare follow-up e venire
corretta o eliminata successivamente. Lo stato deve restare deterministico anche con
sincronizzazione offline e consegna CloudKit fuori ordine.

## Decisione

Eventi e revisioni sono la fonte canonica. Un reducer puro deriva lo stato necessario a
routine, Oggi, follow-up, ricerca, Analisi e widget. Cache o indici persistenti vengono
aggiunti soltanto per query misurate come lente e non costituiscono un sottosistema
autonomo.

## Conseguenze

- correzioni e annullamenti producono ricalcoli deterministici;
- retry e sincronizzazione devono essere idempotenti;
- ogni invariante di dominio richiede un test automatico;
- le cache non possono diventare fonte di verità;
- non esiste un Consistency Engine separato nella baseline 1.0.

## Riferimenti

- Master Plan, sezioni 15, 16, 21 e 35.
