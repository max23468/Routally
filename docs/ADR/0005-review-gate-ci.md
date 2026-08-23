# ADR 0005 — La review delle pull request è un gate di CI

- **Stato:** Confirmed
- **Data:** 2026-08-14
- **Ambito:** Governance della repository

## Contesto

La baseline 1.4 del Master Plan conteneva due regole in conflitto diretto.

La vecchia sezione 27.2 stabiliva che Codex e Claude Code sono agenti alternativi e che non esiste
«nessuna revisione automatica obbligatoria dell'altro». La sezione 28.3.1 richiede invece
lo status `codex-review` sull'HEAD corrente di **ogni** pull request.

La contraddizione era già operativa: il workflow `codex-review-gate.yml` è presente su
`main` e lo status è required, quindi una pull request aperta da Claude Code veniva
comunque sottoposta alla review Codex. Letta alla lettera, la sezione 27.2 rendeva
irregolare ogni pull request prodotta dall'agente non-Codex.

La contraddizione nasce da un'ambiguità reale: «Codex» indica sia un'interfaccia di
sviluppo con cui il proprietario lavora, sia lo strumento di review integrato in GitHub.
Sono due cose diverse che condividono il nome.

## Decisione

Il gate `codex-review` è un **controllo di integrazione continua della repository**, allo
stesso titolo di CodeQL e `swift-format`. Non è un ruolo di agente e non è un intervento
dell'agente Codex sul task di un altro agente.

Ne consegue che:

- il gate si applica a ogni pull request, indipendentemente dall'interfaccia che l'ha prodotta;
- non viola l'esclusività della sezione 27.2, perché non assegna il task a un secondo agente;
- l'agente che ha aperto la pull request resta l'unico a lavorarci e a rispondere ai finding;
- un finding non richiede handoff e non trasferisce il lavoro all'altra interfaccia;
- la sostituzione futura dello strumento di review non cambia queste regole.

Resta invariato il comportamento del gate ora definito in `AGENTS.md`: finding P0/P1
bloccanti sull'HEAD esatto, P2/P3 advisory, nessun riuso di segnali riferiti a commit
precedenti.

## Alternative considerate

- **Rendere il gate opzionale per le pull request non-Codex.** Scartata: indebolisce un
  controllo di qualità in base a chi ha scritto il codice, non in base al rischio del
  codice, e rende il gate aggirabile cambiando interfaccia.
- **Rinunciare al gate per rispettare la sezione 27.2 alla lettera.** Scartata: la review
  automatica sull'HEAD esatto è l'unico controllo automatico di correttezza attivo finché
  non esiste il progetto Xcode e una suite di test.

## Conseguenze

- Il Master Plan semplificato non duplica più la governance operativa degli agenti.
- `AGENTS.md`, `CLAUDE.md` e `docs/ENGINEERING/agent-workflow.md` riportano la stessa regola.
- Nessuna modifica al workflow, allo script del gate o alla branch protection.

## Riferimenti

- `AGENTS.md` e `docs/ENGINEERING/agent-workflow.md`.
- `.github/workflows/codex-review-gate.yml` e `scripts/codex-review-gate.mjs`.
