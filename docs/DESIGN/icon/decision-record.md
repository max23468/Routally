# Decision record — DG-ICON

- **Stato:** Open
- **Baseline canonica per la validazione Apple:** A1 Lavender, testa 50
- **Controllo cromatico:** A1 Amber, testa 50
- **Fallback globale:** T1
- **Icona Dev:** fascia diagonale attuale
- **Responsabile della chiusura:** Product Owner

La conferma del Product Owner del 21 agosto 2026 è stata applicata anche al generatore
canonico. La selezione visuale preliminare è chiusa; `DG-ICON` resta aperto soltanto per le
evidenze Apple, umane e figurative pianificate in Alpha e Beta.

## Decisioni applicate

| Tema | Decisione |
|---|---|
| Forma | A1 |
| Testa | raggio 50, ora canonico |
| Accento | Lavender |
| Controllo | Amber 50 |
| Fallback | T1 globale ed esplicito |
| Alternative archiviate | A3, testa 54 e altre direzioni |
| Dev | stessa A1 con fascia diagonale |

## Evidenze tecniche

| Evidenza | Stato |
|---|---|
| Asset canonici allineati al generatore | superato nel run di canonicalizzazione |
| Asset di revisione allineati al builder | superato nel run di canonicalizzazione |
| Invarianti geometriche indipendenti | 607 controlli superati |
| Livelli autonomi | preparati |
| Import Icon Composer | superato per A1 Lavender 50 e derivata Dev |
| Default, Dark e Mono | verificati in Icon Composer, inclusi 29 e 40 pt |
| Clear e Tinted | verificati in modalità chiara e scura sulla Home Screen di iOS Simulator 26.5 |
| File `.icon` e build Xcode | versionabili; build Simulator pubblico/Dev superate |
| iPhone e iPad reali | mancanti |
| User test cieco | mancante |
| Verifica figurativa | preliminare soltanto |

## Ratifica finale

- **Variante prevista:** A1 Lavender 50
- **File `.icon`:** `RoutallyApp/AppIcon.icon` e `RoutallyApp/AppIconDev.icon`
- **Build pubblico/Dev:** superate su iPhone 17 Pro, iOS Simulator 26.5
- **Dispositivi verificati:**
- **Esito user test:**
- **Rischio figurativo accettato o verificato:**
- **Data:**
- **Approvazione finale Product Owner:**

`E20` / `M10` Alpha raccoglie prova su iPhone/iPad reali e user test sulla build
feature-complete. `E21` / `M11` Beta registra la decisione sul rischio figurativo, la
ratifica finale e la chiusura di `DG-ICON`.
