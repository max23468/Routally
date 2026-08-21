# Rapporto di validazione una tantum

- **Data:** 21 agosto 2026
- **GitHub Actions run:** `32468397569`
- **Job:** `96729835805`
- **Working tree validato e materializzato nel commit:** `89062f387148ec7e769ee704cc12fdda9a4977e2`
- **Esito:** superato

Il job temporaneo è stato usato soltanto per disporre di un checkout Linux completo del
repository, generare gli asset e registrare l'evidenza. Non costituisce un workflow CI
permanente dell'icona e viene rimosso prima della revisione finale della PR.

## Comandi eseguiti

```sh
node scripts/build-icon-assets.mjs
node scripts/check-icon-assets.mjs
node scripts/build-icon-review-assets.mjs
node scripts/check-icon-review-assets.mjs
node scripts/validate-icon-assets.mjs
node scripts/check-reading-matrix.mjs
node scripts/check-roadmap-hierarchy.mjs
git diff --check
```

## Risultati

| Controllo | Risultato |
|---|---:|
| SVG canonici generati e allineati | 32 file |
| Asset di revisione generati | 64 file |
| Livelli autonomi per Icon Composer | 52 file |
| Microvarianti A1 | 7 file |
| Tavole di evidenza | 5 file |
| Asset di revisione allineati al builder | 64 file |
| Controlli indipendenti dell'icona | 607 superati |
| Matrice di lettura del Master Plan | 54 sezioni, nessuna irraggiungibile |
| Gerarchia roadmap | 12 milestone, 22 epiche, 35 requisiti, 7 gate |
| Whitespace e patch | `git diff --check` superato |

## Difetto trovato durante il controllo

Il primo tentativo ha prodotto due falsi negativi sulla tangenza del secondo ciclo. Il
validatore considerava anche il piede orizzontale della gamba e selezionava quel segmento al
posto del fianco destro. Il test è stato corretto limitando la scelta ai due bordi
longitudinali del quadrilatero. Dopo la correzione, la stessa matrice ha superato tutti i 607
controlli.

## Limiti

Questa validazione copre file, geometria, tangenze, angoli, centraggio, contrasti, metadati,
assenza di raster, livelli autonomi, riproducibilità del builder e coerenza documentale. Non
prova:

- import effettivo in Icon Composer;
- materiali Liquid Glass;
- Default, Dark e Mono prodotti dallo strumento;
- file `.icon` e integrazione Xcode;
- resa su iPhone o iPad reali;
- user test o clearance figurativa professionale.

Questi elementi restano condizioni bloccanti nel [decision record](decision-record.md).
