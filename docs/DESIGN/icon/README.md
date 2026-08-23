# Icona Routally — asset, baseline e import

La baseline canonica per la validazione Apple è **A1 Lavender con testa 50**. Il segno è un
monogramma `R` costruito attorno a un ciclo; `DG-ICON` resta aperto per le prove Apple e
umane, non per una nuova esplorazione visuale.

## Struttura della cartella

| Percorso | Uso |
|---|---|
| `a1-air-medium-*.svg` | baseline canonica Lavender 50 |
| `dev-app-icon-*.svg` | stessa baseline con fascia Dev |
| `t1-cycle-consequence-*` | fallback globale |
| `a2-*`, `a3-*`, `t2-*`, `v1-*`–`v3-*` | alternative archiviate |
| `composer-layers/` | livelli autonomi per tutte le varianti |
| `../../../RoutallyApp/AppIcon.icon` | pacchetto Icon Composer pubblico |
| `../../../RoutallyApp/AppIconDev.icon` | pacchetto Icon Composer Dev |
| `experiments/a1-air-medium-amber-*` | controllo Amber 50 |
| `experiments/a1-air-medium-head54-*` | confronto storico archiviato |
| `experiments/*monochrome*` | simulazione piatta, non resa Apple |
| `evidence/` | tavole comparative SVG riproducibili |

Il generatore canonico produce direttamente testa 50 sia per A1 sia per la derivata Dev. Il
trattamento primario usa fondo `#4C46D8`, monogramma bianco e accento `#CAC7FF`.

## Confronto residuo

Le sole varianti ammesse alle verifiche mancanti sono:

1. A1 Lavender 50 — baseline;
2. A1 Amber 50 — controllo cromatico;
3. T1 — fallback globale.

A3 e testa 54 sono archiviate e si riaprono soltanto se Icon Composer o i dispositivi
mostrano un problema concreto.

## Icon Composer

I livelli A1 sono importati in due pacchetti distinti, entrambi iOS-only: `AppIcon.icon` per
il target pubblico e `AppIconDev.icon` per il target Dev. I gruppi usano Liquid Glass in
modalità Individual con riflesso speculare, translucenza e ombra al 50%; la sfocatura resta
disattivata per preservare il segno alle dimensioni minime. La variante Dark è annotata con
una palette realmente scura e mantiene l'indaco nei dettagli, mentre Mono resta affidato al
rendering di sistema.

Default, Dark e Mono sono stati controllati in Icon Composer anche a 29 e 40 pt. Clear e
Tinted sono stati verificati sulla Home Screen di iOS Simulator 26.5 in modalità chiara e
scura, per entrambe le build. Le prove su iPhone/iPad reali e lo user test sono assegnati
a `E20` / `M10` Alpha; decisione figurativa e ratifica appartengono a `E21` / `M11` Beta.

T1 resta il benchmark della silhouette e non è una sostituzione automatica alle piccole dimensioni: è un eventuale fallback globale
scelto esplicitamente.

## Evidenze

- [validation-plan.md](validation-plan.md): stato degli interventi;
- [icon-composer-checklist.md](icon-composer-checklist.md): prova Apple;
- [user-test-protocol.md](user-test-protocol.md): test cieco;
- [originality-scan.md](originality-scan.md): ricerca preliminare;
- [decision-record.md](decision-record.md): ratifica e chiusura di `DG-ICON`.

## Rigenerazione e controlli

```sh
node scripts/build-icon-assets.mjs
node scripts/check-icon-assets.mjs
node scripts/check-icon-composer-assets.mjs
node scripts/build-icon-review-assets.mjs
node scripts/check-icon-review-assets.mjs
node scripts/validate-icon-assets.mjs
```

Il builder elimina esclusivamente gli SVG generati e conserva qualsiasi evidenza manuale non
SVG presente nelle cartelle.
