# Icona Routally — asset, confronti e import

Direzione e regole vincolanti stanno nella sezione 4.8 del
[Master Plan](../../MASTER_PLAN.md). Il segno è un **monogramma `R` costruito attorno a un
ciclo**, con un arco esterno di progresso e una testa piena. `a1-air-medium` è la candidata
preferita, non l'icona definitiva: `DG-ICON` resta aperto.

## Struttura della cartella

| Percorso | Uso |
|---|---|
| `a1-air-medium-*.svg` | candidata preferita in Lavender |
| `a2-*`, `a3-*` | confronti sul distacco e sulla lunghezza dell'arco |
| `t1-cycle-consequence-*` | benchmark della silhouette senza arco |
| `t2-*`, `v1-*`–`v3-*` | alternative di soglia e secondo ciclo |
| `dev-app-icon-*` | derivata Dev con fascia diagonale |
| `layers/` | livelli autonomi storici per A1 e Dev |
| `composer-layers/` | livelli autonomi per tutte le varianti e i due trattamenti |
| `experiments/` | A1 testa 50, Amber e simulazione monocromatica |
| `evidence/` | tavole comparative SVG riproducibili |

Il suffisso `-indigo` indica segno chiaro su fondo indaco; `-light` indica segno indaco su
fondo chiaro. Il trattamento indaco resta la baseline perché conserva il perimetro visivo
dell'icona anche su sfondi chiari.

## Candidate per il confronto finale

Il confronto minimo comprende:

- `a1-air-medium`, candidata preferita;
- `a3-air-wide-short`, controllo su maggiore aria e gesto più breve;
- `t1-cycle-consequence`, benchmark della silhouette.

T1 non è un asset che iOS sostituisce automaticamente alle piccole dimensioni. Serve a
misurare quanto della silhouette rimane quando si rimuove l'accento e può diventare soltanto
un fallback globale, scelto esplicitamente se A1 non regge nei contesti minimi.

Le rifiniture controllate di A1 cambiano una sola variabile alla volta:

| Variante | Testa | Accento |
|---|---:|---|
| baseline | 54 | Lavender |
| `head50` | 50 | Lavender |
| `amber` | 54 | Amber |
| `head50-amber` | 50 | Amber |

Amber usa esclusivamente i token già presenti nella UI Foundation: `#FFBF66` sul fondo
indaco e `#9A5B00` sul fondo chiaro.

## Livelli per Icon Composer

Ogni file di `composer-layers/`:

- usa una tela 1024 × 1024;
- contiene un solo livello nominato;
- ha le coordinate già trasformate;
- non dipende da `transform` esterni;
- resta SVG nativo e non contiene raster.

Per ciascuna variante importare `background`, `symbol`, `accent` quando presente e `overlay`
soltanto per Dev. I gruppi interni agli SVG combinati restano utili alla lettura e alla
ricomposizione, ma non vengono più assunti come prova sufficiente dell'importabilità nello
strumento.

## Icon Composer

Icon Composer richiede **macOS Tahoe 26.4 o successivo**. I passaggi non sono stati eseguiti
in questa PR perché richiedono macOS e lo strumento Apple:

1. seguire [icon-composer-checklist.md](icon-composer-checklist.md);
2. importare almeno A1, A3 e T1 dai file autonomi;
3. configurare Default, Dark e Mono;
4. verificare anche Clear light/dark e Tinted light/dark;
5. salvare e versionare il file `.icon`;
6. trascinarlo in Xcode e selezionarlo nei target pubblico e Dev;
7. eseguire la prova su iPhone e iPad reali.

Le tavole in `evidence/` sono verifiche piatte e non simulano Liquid Glass, rifrazione,
highlight speculari o adattamento al wallpaper.

## Evidenze e decisione

- [validation-plan.md](validation-plan.md): matrice completa dei ventiquattro interventi;
- [icon-composer-checklist.md](icon-composer-checklist.md): prova Apple manuale;
- [user-test-protocol.md](user-test-protocol.md): test cieco su 5–8 persone;
- [originality-scan.md](originality-scan.md): ricerca preliminare del segno;
- [decision-record.md](decision-record.md): unica evidenza ammessa per chiudere `DG-ICON`.

La scelta finale non va presa sull'anteprima grande o sulla sola resa SVG: richiede confronto
in Icon Composer, 29 e 40 pt su dispositivo, user test e valutazione del rischio figurativo.

## Generazione e controllo una tantum

Gli SVG canonici restano prodotti dalla sorgente parametrica della PR #18. Le varianti di
revisione e le tavole sono generate da uno script separato per non cambiare accidentalmente
la baseline.

```sh
node scripts/build-icon-assets.mjs
node scripts/check-icon-assets.mjs
node scripts/build-icon-review-assets.mjs
node scripts/check-icon-review-assets.mjs
node scripts/validate-icon-assets.mjs
```

`check-icon-assets.mjs` verifica la corrispondenza con la sorgente parametrica;
`validate-icon-assets.mjs` legge invece i file versionati senza importare quel generatore e
controlla geometria, tangenze, angoli, contrasti, livelli autonomi, metadati e assenza di
raster. Non viene aggiunto un workflow CI permanente dedicato all'icona.
