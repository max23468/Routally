# Workflow degli agenti

Questo documento è la fonte comune per Codex e Claude Code. `AGENTS.md` e `CLAUDE.md`
sono i rispettivi punti di ingresso; `docs/MASTER_PLAN.md` resta la fonte canonica delle
decisioni di progetto.

## Avvio

1. Leggi integralmente il Master Plan prima di qualsiasi attività e poi le specifiche o
   ADR pertinenti.
2. Conferma obiettivo, scope e criteri di accettazione.
3. Verifica branch, working tree e modifiche concorrenti prima di intervenire.
4. Non usare contemporaneamente Codex e Claude Code sullo stesso task.

## Lavoro

- Dopo il commit radice di bootstrap, usa un branch breve e una pull request.
- Ogni PR richiede lo status `codex-review` sull'HEAD corrente. All'apertura o al
  passaggio da draft a ready parte la review nativa; dopo un nuovo commit usa una sola
  riga `@codex review`. `workflow_dispatch` resta solo per bootstrap o retry manuali.
- Mantieni il cambiamento minimo coerente con lo scope approvato.
- Non aggiungere dipendenze o operare su servizi remoti senza autorizzazione.
- Esegui i controlli proporzionati al rischio e aggiungi una regressione per ogni bug.
- Non includere secret, credenziali o dati reali.

## Chiusura e handoff

- Commit e working tree pulito.
- Test eseguiti e risultati registrati.
- Decisioni, rischi residui e prossimo passo dichiarati.
- Nessun deploy o release senza approvazione esplicita.
