# Skill del repository

Questa cartella contiene le Skill condivise dagli agenti che lavorano su Routally.
È la posizione nativa delle skill di repository per Codex (`$REPO_ROOT/.agents/skills`);
`.claude/skills/` contiene symlink agli stessi contenuti per Claude Code, così le due
toolchain leggono un'unica fonte.

Le regole di attivazione obbligatoria sono in [AGENTS.md](../../AGENTS.md#skill-e-delega)
e nella matrice di [agent-workflow.md](../../docs/ENGINEERING/agent-workflow.md).

## Skill installate

| Skill | Uso | Attivazione |
| --- | --- | --- |
| `write-swift` | Swift moderno: value type, concorrenza Swift 6.2+, `some`/`any`, API design, ARC, Swift Testing. | Obbligatoria su ogni intervento che scrive, rivede o migra Swift. |
| `apple-design` | Fondamenti Apple di interfaccia e movimento fluido: risposta immediata, manipolazione diretta, interrompibilità, spring, momentum, materiali, tipografia, reduced motion. | Obbligatoria sugli interventi con comportamento visibile o movimento. |
| `review-animations` | Revisione critica di animazioni e movimento contro una barra di qualità alta. | Invocazione esplicita: obbligatoria prima dell'evidenza visuale di una PR che tocca il movimento. |

## Provenienza e licenza

I file delle tre skill sono ripresi senza modifiche da
[emilkowalski/skills](https://github.com/emilkowalski/skills), commit
`d23d7f88a2e21c9e4b1418c7abe420f5c1052ba7` (21 agosto 2026), distribuito con licenza MIT.
Il testo della licenza è in [LICENSE-emilkowalski-skills](LICENSE-emilkowalski-skills) e
si applica soltanto a questi file, non al resto del repository: vedi
[COPYRIGHT.md](../../COPYRIGHT.md).

L'unica differenza rispetto a monte è la riga vuota finale rimossa da
`write-swift/SKILL.md`, richiesta dal controllo whitespace del repository.

Per aggiornarle, sostituisci le cartelle con la versione a monte, ripeti quella pulizia e
aggiorna commit e data qui sopra. Non modificare altro nei contenuti a monte: gli
adattamenti a Routally vivono in questo documento e nelle istruzioni del repository.

## Adattamento a Routally

Routally è un'app Apple nativa in SwiftUI. `apple-design` e `review-animations` derivano
dalle sessioni WWDC ma mostrano gli esempi in CSS e JavaScript: i principi valgono, il
codice no. Traduci così, e non introdurre idiomi web nel progetto.

| Nel testo della skill | In Routally |
| --- | --- |
| `damping` + `response` di una spring | `.spring(response:dampingFraction:)`; il default resta critically damped (`dampingFraction` 1.0) e il rimbalzo si usa solo dopo un gesto con momentum. |
| Motion / Framer Motion, `requestAnimationFrame` | `withAnimation`, `Animation`, `matchedGeometryEffect`, `PhaseAnimator`, `KeyframeAnimator`. |
| Pointer Events, `setPointerCapture` | `DragGesture` con `onChanged`/`onEnded`, `predictedEndTranslation` per la proiezione del momentum. |
| `backdrop-filter`, materiali translucidi | `.background(.ultraThinMaterial)` e i material di sistema; vale la regola Liquid Glass della sezione 7.5 del Master Plan. |
| `prefers-reduced-motion` | `@Environment(\.accessibilityReduceMotion)`; vedi anche la sezione 23 del Master Plan. |
| `prefers-reduced-transparency`, `prefers-contrast` | `accessibilityReduceTransparency`, `colorSchemeContrast`. |
| Dimensioni tipografiche e leading fissi | Dynamic Type e text style di sistema; nessuna dimensione fissa in punti. |
| Vibration API, feedback aptico | `.sensoryFeedback`, coerente con la sezione 0.4 sul feedback. |

Dove una skill e le fonti canoniche del progetto divergono, prevalgono `docs/MASTER_PLAN.md`,
gli ADR e [AGENTS.md](../../AGENTS.md): la skill è una guida di mestiere, non una decisione
di prodotto.
