# Trama — Fase 1

Stato: direzione visuale approvata dal Product Owner il 4 settembre 2026; implementazione
SwiftUI implementata localmente e in revisione visuale. Questa approvazione del concept non chiude DG-VISUAL: resta da
approvare la resa del prototipo reale su iPhone e iPad.

## Target approvato

Proposta 3, Trama, con pulsante Registra meno glossy: indaco satinato, riflessi ridotti,
profondità discreta. Il modulo comprende sorgente, punti di progresso e un filo continuo fino alle conseguenze;
la stessa anatomia si riusa nel dettaglio e nel riepilogo dopo la registrazione.

La personalità resta «Calma intelligente». L’«Impulso Routally» rende leggibile il rapporto
fra un evento reale e le sue conseguenze, senza trasformarlo in un editor di workflow.

Fase 1: Oggi, dettaglio Routine e conseguenze. Le altre superfici restano fuori da questo
intervento; l’estensione richiede l’approvazione della Fase 1.

## Comportamento e accessibilità

- `Registra` usa un Button nativo con label satinata, indaco dinamico e forma continua:
  è l’eccezione approvata alla precedente prescrizione universale di `glassProminent`.
- Barre, navigazione, ricerca e sheet mantengono Liquid Glass di sistema.
- Il contenuto usa una superficie opaca chiara/scura, testi neutri e una sola famiglia di
  simboli SF Symbols; le conseguenze restano leggibili anche senza connettori o colore.
- «Se registri ora» si espande e comprime nello stesso modulo. L’anteprima esegue il reducer
  su una copia del registro con un evento ipotetico; non salva, non notifica e non modifica
  il riepilogo delle operazioni già eseguite. Non esistono contatori incrementati nella view.
- Se il calcolo non è disponibile, la UI lo dichiara. Registra resta l’azione reale; un errore
  di anteprima non viene presentato come un errore di persistenza.
- Il follow-up futuro mostra il momento configurato; non viene presentato come già pronto.
  Dopo il raggiungimento della soglia il ciclo riparte soltanto al completamento previsto.
- Escludi e Annulla mantengono le operazioni sul registro e il ricalcolo esistenti.
- Il dettaglio consente di registrare direttamente e apre lo stesso riepilogo di Oggi.
- Dynamic Type può espandere il contenuto e disporre il pulsante sotto il titolo; i controlli
  hanno target di almeno 44 pt. Reduce Motion elimina l’animazione del connettore.
- La conferma aptica accompagna una registrazione riuscita, senza sostituire il riepilogo.
- La classificazione temporale della vertical slice resta quella del modello esistente:
  la fixture Palestra resta nel gruppo settimanale, dichiarato nel sottotitolo; la data della fixture compare sotto Oggi quando non ci sono altri gruppi. Non si forza Adesso per imitare il mockup,
  né si introducono Camminata e Lettura come righe di produzione fittizie.

## Riferimenti forniti dal proprietario

- <https://beautifului.dev>
- <https://beui.dev>
- <https://rareui.com>
- <https://transitions.dev>
- <https://ui.shadcn.com>
- <https://ui-skills.com>
- <https://coss.com/ui>
- <https://designsystemchecklist.com>
- <https://reui.io/components>
- <https://emilkowal.ski/ui/you-dont-need-animations>

Sono riferimenti di design, non dipendenze. Si affiancano alle HIG e al benchmark
competitivo della sezione 3 del Master Plan. Il concept approvato prevale sulle tre
precedenti direzioni e sulle revisioni non approvate della chat Verifica DG-VISUAL.

## Verifica

Build Dev e pubblica, formatter e 73 test sono passati nelle verifiche locali. Il controllo
completo viene ripetuto sull’HEAD finale prima dell’handoff. I due nuovi test nella suite
esistente verificano anteprima senza scritture, corrispondenza con la registrazione,
localizzazione, annullamento e reset del ciclo.

La matrice e il confronto con il concept sono in [design-qa.md](../../design-qa.md).
Le acquisizioni reali sono in [evidence/trama-phase-one](evidence/trama-phase-one).
Le prove sono state eseguite con la fixture `connectedGymCycle` in memoria, senza account,
notifiche reali o modifiche ai dati personali. La conferma aptica richiede una prova fisica;
la presenza delle etichette nell’albero di accessibilità non equivale a un audit VoiceOver.

Il controllo di scorrimento AX5 ha portato a usare sezioni native `insetGrouped`, senza
header trasparenti fissati sopra il contenuto; il testo dell’anteprima cresce in altezza.
I simboli decorativi mantengono una dimensione limitata; alle dimensioni accessibili
precedono il testo in verticale. Anche il fondo di Registra cresce insieme al testo.
La revisione del 5 settembre corregge il primo tentativo, respinto dal proprietario per
scarsa fedeltà: pulsante compatto, scala tipografica del concept, filo continuo, valori
previsti in indaco e riga secondaria senza barra duplicata. I simboli predefiniti e delle
fixture usano ora dumbbell/tshirt; il follow-up usa basket. Le scelte salvate dall’utente
non vengono sostituite o migrate.
Il testo del pulsante usa bianco in chiaro e nero in scuro: il contrasto teorico sui token
indaco è rispettivamente 6,61:1 e 9,51:1, più alto con Aumenta contrasto.

Nessuna pubblicazione o chiusura di DG-VISUAL è implicita in questo documento.
