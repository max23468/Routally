# Decision record — DG-ICON

- **Stato:** Open
- **Baseline approvata dal Product Owner per la validazione Apple:** A1 Lavender, testa 50
- **Alternativa di controllo:** A1 Amber, testa 50
- **Fallback globale:** T1 senza arco
- **Icona Dev:** fascia diagonale attuale
- **Decisione definitiva:** subordinata a Icon Composer, dispositivi, user test e rischio figurativo
- **Responsabile della chiusura:** Product Owner

La conferma del Product Owner del 21 agosto 2026 chiude la selezione visuale preliminare, ma
non chiude `DG-ICON`: la baseline deve ancora superare le verifiche Apple e umane elencate
sotto.

## Decisioni già prese

| Tema | Decisione |
|---|---|
| Forma principale | A1, monogramma `R` costruito attorno a un ciclo |
| Testa terminale | raggio 50 |
| Colore dell'accento | Lavender |
| Controllo cromatico nel test | Amber, sempre con testa 50 |
| T1 | solo benchmark/fallback globale esplicito |
| A3 e testa 54 | archiviate dopo il confronto SVG piatto; recuperabili soltanto se i test Apple evidenziano un problema |
| Icona Dev | fascia diagonale attuale |

## Varianti ammesse alla validazione residua

| Variante | Ruolo |
|---|---|
| A1 Lavender, testa 50 | baseline approvata dal Product Owner |
| A1 Amber, testa 50 | unico controllo cromatico nel test cieco |
| T1 | fallback globale, da usare soltanto se A1 non supera le misure minime |

## Evidenze tecniche

| Evidenza | Stato | Riferimento |
|---|---|---|
| Asset canonici allineati al generatore | Superato nel controllo una tantum | `scripts/check-icon-assets.mjs` |
| Asset di revisione allineati al builder | Superato nel controllo una tantum | `scripts/check-icon-review-assets.mjs` |
| Invarianti geometriche indipendenti | 607 controlli superati | `scripts/validate-icon-assets.mjs` |
| Livelli autonomi per Icon Composer | Preparati | `composer-layers/` |
| Confronto 180/120/60/40/29 pt | Completato in SVG | `evidence/candidate-comparison.svg` |
| Matrice testa/colore | Completata; decisione preliminare presa | `evidence/refinement-matrix.svg` |
| Icona pubblica/Dev | Verifica piatta completata | `evidence/dev-comparison.svg` |
| Import in Icon Composer | Mancante | compilare checklist |
| Default, Dark, Mono, Clear e Tinted | Mancante | compilare checklist |
| File `.icon` e collegamento Xcode | Mancante | percorso, commit e build |
| iPhone e iPad reali | Mancante | modelli, sistemi e screenshot |
| User test cieco | Mancante | protocollo compilato |
| Verifica figurativa | Solo scansione preliminare | esito professionale o accettazione esplicita del rischio |

## Risultati Icon Composer

- **macOS:**
- **Icon Composer:**
- **Xcode:**
- **File `.icon`:**
- **Import A1 Lavender testa 50:**
- **Import A1 Amber testa 50:**
- **Import T1:**
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
- **Confronto:** A1 Lavender 50 / A1 Amber 50 / T1
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

## Ratifica finale

- **Variante prevista:** A1
- **Colore previsto:** Lavender
- **Raggio previsto:** 50
- **Fallback previsto:** T1
- **Motivazione:** equilibrio migliore della testa, coerenza con il tono calmo e maggiore distintività rispetto a T1
- **Commit del file `.icon`:**
- **Data della ratifica:**
- **Approvazione finale Product Owner:**

## Chiusura del gate

`DG-ICON` può passare da `Open` a `Confirmed` soltanto dopo:

1. import riuscito in Icon Composer;
2. verifica di tutti i modi di rendering Apple;
3. file `.icon` versionato e build dei target pubblico e Dev;
4. prova su iPhone e iPad reali;
5. user test cieco completato;
6. verifica figurativa formale oppure accettazione esplicita del rischio;
7. ratifica finale del Product Owner e aggiornamento coerente di Master Plan e Decision Register.
