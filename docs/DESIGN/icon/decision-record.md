# Decision record — DG-ICON

- **Stato:** Open
- **Candidata preferita:** `a1-air-medium`
- **Decisione definitiva:** non presa
- **Responsabile della chiusura:** Product Owner

Questo documento diventa l'evidenza di chiusura di `DG-ICON`. Non va impostato su
`Confirmed` finché le sezioni obbligatorie non sono compilate.

## Candidate ammesse al confronto finale

| Variante | Ruolo |
|---|---|
| A1 Lavender, testa 54 | baseline e candidata preferita |
| A1 Lavender, testa 50 | rifinitura della testa terminale |
| A1 Amber, testa 54 | rifinitura cromatica con token esistente |
| A1 Amber, testa 50 | rifinitura combinata |
| A3 | controllo su arco più breve e maggiore distacco |
| T1 | benchmark della silhouette e possibile fallback globale |

## Evidenze tecniche

| Evidenza | Stato | Riferimento |
|---|---|---|
| Asset canonici allineati al generatore | Da eseguire sul commit finale | `scripts/check-icon-assets.mjs` |
| Asset di revisione allineati al builder | Da eseguire sul commit finale | `scripts/check-icon-review-assets.mjs` |
| Invarianti geometriche indipendenti | Da eseguire sul commit finale | `scripts/validate-icon-assets.mjs` |
| Livelli autonomi per Icon Composer | Preparati | `composer-layers/` |
| Confronto 180/120/60/40/29 pt | Preparato in SVG | `evidence/candidate-comparison.svg` |
| Matrice testa/colore | Preparata in SVG | `evidence/refinement-matrix.svg` |
| Icona pubblica/Dev | Preparata in SVG | `evidence/dev-comparison.svg` |
| Import in Icon Composer | Mancante | compilare checklist |
| Default, Dark e Mono | Mancante | compilare checklist |
| File `.icon` e collegamento Xcode | Mancante | percorso e commit |
| iPhone e iPad reali | Mancante | modelli, sistemi e screenshot |
| User test cieco | Mancante | protocollo compilato |
| Verifica figurativa | Solo scansione preliminare | esito professionale o accettazione rischio |

## Risultati Icon Composer

- **macOS:**
- **Icon Composer:**
- **Xcode:**
- **File `.icon`:**
- **Variante importata senza correzioni:**
- **Correzioni richieste dallo strumento:**
- **Esito Default:**
- **Esito Dark:**
- **Esito Mono:**
- **Esito Clear/Tinted:**

## Risultati su dispositivo

| Dispositivo | Sistema | Contesti verificati | Esito | Evidenza |
|---|---|---|---|---|
| iPhone |  |  |  |  |
| iPad |  |  |  |  |

## Risultati user test

- **Partecipanti:**
- **Ordine randomizzato:** sì/no
- **Variante preferita prima della spiegazione:**
- **Associazioni prevalenti:**
- **Associazioni a routing/rete/sincronizzazione:**
- **Chiarezza mediana:**
- **Conclusione:**

## Verifica di originalità

- **Banche dati e classi verificate:**
- **Segni materialmente vicini:**
- **Parere o responsabile della valutazione:**
- **Rischio residuo accettato:** sì/no
- **Note:**

## Decisione finale

- **Variante scelta:**
- **Colore dell'accento:**
- **Raggio della testa:**
- **Motivazione:**
- **Alternative scartate e motivo:**
- **Commit del file `.icon`:**
- **Data:**
- **Approvazione Product Owner:**

## Chiusura del gate

`DG-ICON` può passare da `Open` a `Confirmed` soltanto dopo:

1. compilazione completa delle evidenze mancanti;
2. scelta di una sola variante;
3. file `.icon` versionato e build verificata;
4. approvazione esplicita del Product Owner;
5. aggiornamento coerente di Master Plan, Decision Register e questo documento.
