# Workflow degli agenti

Questo documento contiene il solo workflow operativo comune. Le decisioni di prodotto
restano in `docs/MASTER_PLAN.md`; lo scope successivo alla 1.0 resta in
`docs/PRODUCT/ROADMAP.md`.

## Lettura

Il Master Plan è intenzionalmente breve. Prima di un intervento non banale:

1. leggi le sezioni 0–2, 9–11;
2. leggi le sezioni direttamente toccate;
3. leggi l'ADR o la specifica operativa pertinente;
4. consulta la roadmap futura soltanto se il lavoro promuove o modifica una voce rinviata.

Per modifiche a scope, roadmap, pricing, architettura o release leggi il Master Plan
integralmente. Non esiste più una matrice numerica da mantenere: se il piano diventa troppo
grande per questa regola, si sposta il dettaglio nella specifica competente.

## Dimensioni trasversali

Per comportamento visibile verifica sempre l'applicabilità di:

- Free/Plus;
- accessibilità e IT/EN;
- persistenza locale, offline e backup;
- correzione, annullamento e recupero;
- notifiche e superfici di sistema;
- privacy e permessi;
- test e criteri di accettazione.

Una dimensione non applicabile si dichiara tale. Non richiede un documento separato.

## Avvio

1. Conferma obiettivo, scope e criterio di uscita.
2. Verifica branch, working tree, worktree e modifiche concorrenti.
3. Usa un worktree isolato per lavoro non banale quando esistono attività concorrenti.
4. Verifica che il Technical Gate applicabile sia chiuso prima dell'implementazione che
   vincola.
5. Non usare Codex e Claude Code contemporaneamente sullo stesso task.

## Lavoro

- Mantieni il cambiamento minimo coerente con lo scope approvato.
- Non aggiungere dipendenze o operare su servizi remoti senza autorizzazione.
- Non preparare astrazioni, capability o schema per una voce soltanto rinviata.
- Esegui controlli proporzionati al rischio e aggiungi una regressione per ogni bug.
- Usa dati sintetici e non includere secret o dati reali.
- Aggiorna soltanto la fonte competente; evita di duplicare scope, roadmap o DoD.

## Pull request

- branch breve e PR verso `main`;
- `swift-format`, build e test soltanto quando applicabili ai file cambiati;
- checker documentale per cambi alla roadmap;
- `codex-review` sull'HEAD corrente;
- P0/P1 bloccanti; P2/P3 advisory secondo `AGENTS.md`;
- squash merge e cancellazione del branch del ciclo corrente.

## Chiusura

- test eseguiti e risultati registrati;
- decisioni e rischi residui dichiarati;
- working tree pulito;
- nessun deploy, TestFlight, App Store o release senza l'autorizzazione richiesta;
- rimozione dei soli branch e worktree temporanei creati dal ciclo corrente e già
  assorbiti.
