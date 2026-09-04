# Icona Routally — asset di prodotto e fallback

La baseline canonica per la validazione Apple è **A1 Lavender con testa 50**. Il segno è un
monogramma `R` costruito attorno a un ciclo; `DG-ICON` resta aperto per le prove Apple e
umane, non per una nuova esplorazione visuale.

## Asset mantenuti

| Percorso | Uso |
|---|---|
| `../../../RoutallyApp/AppIcon.icon` | pacchetto Icon Composer pubblico |
| `../../../RoutallyApp/AppIconDev.icon` | pacchetto Icon Composer Dev |
| `t1-cycle-consequence-*.svg` | benchmark e fallback globale T1 |
| `composer-layers/t1-cycle-consequence-*` | livelli autonomi del solo fallback T1 |

I pacchetti `.icon` sono la sorgente reale dei target. Il laboratorio SVG usato per
selezionare e canonicalizzare A1 è chiuso: generatori, alternative, esperimenti, tavole e
607 controlli indipendenti restano consultabili nella cronologia Git, senza continuare a
gravare sui gate correnti.

## Icon Composer

I pacchetti sono distinti e iOS-only. `AppIcon.icon` serve il target pubblico;
`AppIconDev.icon` aggiunge la fascia Dev. I gruppi usano Liquid Glass in modalità
Individual con riflesso speculare, translucenza e ombra al 50%; la sfocatura resta
disattivata per preservare il segno alle dimensioni minime.

Default, Dark e Mono sono stati controllati in Icon Composer anche a 29 e 40 pt. Clear e
Tinted sono stati verificati sulla Home Screen di iOS Simulator 26.5 in modalità chiara e
scura, per entrambe le build. Le prove su iPhone/iPad reali e lo user test sono assegnati
a `E20` / `M10` Alpha; decisione figurativa e ratifica appartengono a `E21` / `M11` Beta.

T1 resta il benchmark della silhouette e non sostituisce automaticamente A1: è un fallback
globale da scegliere esplicitamente soltanto se le verifiche residue mostrano un problema.

## Evidenze e controllo corrente

- [validation-plan.md](validation-plan.md): stato e verifiche residue;
- [icon-composer-checklist.md](icon-composer-checklist.md): prova Apple;
- [user-test-protocol.md](user-test-protocol.md): test cieco;
- [originality-scan.md](originality-scan.md): ricerca preliminare;
- [decision-record.md](decision-record.md): ratifica e chiusura di `DG-ICON`.

Il controllo automatizzato corrente valida direttamente i due pacchetti di prodotto:

```sh
node scripts/check-icon-composer-assets.mjs
```
