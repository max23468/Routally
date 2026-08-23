# Claude Code

`docs/MASTER_PLAN.md` è la fonte canonica. Non leggerlo integralmente: leggi sempre le
sezioni 0, 5, 6, 40, 50 e 51, poi quelle che il tuo intervento tocca secondo la matrice in
`docs/ENGINEERING/agent-workflow.md`. Un technical gate aperto della sezione 40 precede
l'implementazione che vincola, e le dimensioni trasversali della sezione 0.4 — Free/Plus,
accessibilità, localizzazione, privacy, persistenza, correzione, notifiche e test — valgono
anche quando la loro sezione non compare nella riga usata. Segui `AGENTS.md` e lo stesso
workflow.

Claude Code è alternativo a Codex, non un revisore simultaneo. Inizia soltanto dopo un
handoff esplicito e non modifica decisioni o servizi esterni senza approvazione.

Il gate `codex-review` delle pull request è un controllo di integrazione continua della
repository, non una revisione dell'agente Codex sul tuo task: non richiede handoff e non
viola l'esclusività fra i due agenti.
