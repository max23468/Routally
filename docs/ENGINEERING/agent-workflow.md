# Workflow degli agenti

Questo documento è la fonte comune per Codex e Claude Code. `AGENTS.md` e `CLAUDE.md`
sono i rispettivi punti di ingresso; `docs/MASTER_PLAN.md` resta la fonte canonica delle
decisioni di progetto.

## Avvio

1. Conferma obiettivo, scope e criteri di accettazione.
2. Dove utile, leggi integralmente il Master Plan e le specifiche o ADR pertinenti.
3. Verifica branch, working tree e modifiche concorrenti prima di intervenire.
4. Non usare contemporaneamente Codex e Claude Code sullo stesso task.

## Lavoro

- Dopo il commit radice di bootstrap, usa un branch breve e una pull request.
- Mantieni il cambiamento minimo coerente con lo scope approvato.
- Non aggiungere dipendenze o operare su servizi remoti senza autorizzazione.
- Esegui i controlli proporzionati al rischio e aggiungi una regressione per ogni bug.
- Non includere secret, credenziali o dati reali.

## Chiusura e handoff

- Commit e working tree pulito.
- Test eseguiti e risultati registrati.
- Decisioni, rischi residui e prossimo passo dichiarati.
- Nessun deploy o release senza approvazione esplicita.
