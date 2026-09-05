# Trama Fase 1 — Revisione del 5 settembre 2026

Ambito: Oggi, dettaglio Routine e riepilogo delle conseguenze.
Stato: revisione implementata e verificata localmente; accettazione visuale del Product Owner aperta.
Il primo tentativo è stato respinto per scarsa fedeltà al concept. Le sue immagini e il
rapporto precedente sono conservati in `docs/DESIGN/evidence/trama-phase-one/rejected/`
e non certificano questa revisione.

## Confronto con il concept

Target: `docs/DESIGN/evidence/trama-phase-one/00-target-approved.png`, proposta 3 Trama
con Registra meno glossy, approvata nella conversazione del 4 settembre.

La revisione introduce un filo continuo ancorato al progresso e ai simboli delle
conseguenze, tre punti per l’obiettivo canonico, pulsante satinato compatto con target
44 pt, valori futuri in indaco e riga secondaria compatta. La tipografia usa San Francisco
con metriche scalabili, senza bloccare Dynamic Type.

Restano differenze esplicite da sottoporre alla valutazione del proprietario:

- status bar, navigation bar, tab bar e navigazione a colonne sono native;
- data e routine provengono dalla fixture canonica, quindi non coincidono con i dati
  illustrativi del raster; Camminata e Lettura non sono dati aggiunti all’app;
- i simboli sono SF Symbols: dumbbell, tshirt e basket; tshirt non riproduce il disegno
  dell’asciugamano del concept;
- la superficie e il pulsante sono opachi e adattivi, senza la texture raster.

Il concept misura 852 × 1846 px; iPhone 17 Pro misura 1206 × 2622 px (402 × 874 pt).
Il confronto completo normalizza la larghezza, senza deformare le proporzioni. Non è
una sovrapposizione pixel-perfect: safe area e contenuti differiscono.

## Verifiche

Le acquisizioni della revisione corrente sono nella directory del target. Tutte le
operazioni usano `connectedGymCycle` in memoria.

- `01-oggi-light.png`: Oggi finale, testo standard, anteprima aperta.
- `02-dettaglio-light.png`: stesso modulo nel dettaglio Routine.
- `04-oggi-dark.png`: testo standard in dark mode.
- `05a-oggi-dark-ax5-top.png` e `05-oggi-dark-ax5-contrast.png`: testo AX5 e contrasto
  aumentato, parte superiore e conseguenze dopo scorrimento.
- `06-esclusione-dark.png`: esclusione della conseguenza nel riepilogo.
- `07-ipad-oggi-light.png`, `08-ipad-dettaglio-light.png`, `09-ipad-conseguenze.png`:
  iPad Pro 11 M5, Oggi, navigazione a colonne e riepilogo dopo registrazione dal dettaglio.
  L’annullamento ripristina 1/3 e 3/4 anche su iPad.

L’ultima correzione dispone simbolo e testo delle conseguenze verticalmente alle dimensioni
accessibili e fa crescere il fondo del pulsante insieme al testo. Il valore futuro rimane
leggibile e il follow-up completo si raggiunge scorrendo. La resa standard non cambia.

Interazioni iPhone: compressione/espansione, apertura del dettaglio, registrazione
(Palestra 2/3, Asciugamano 4/4), esclusione (Asciugamano 3/4) e annullamento
(ripristino Palestra 1/3 e anteprima 3/4 → 4/4) osservati nel runtime. Le interazioni e le
acquisizioni standard dark precedono soltanto l’ultima correzione AX, che non modifica
le operazioni sul registro.

`node scripts/verify-change.mjs --base origin/main` ha superato formatter, controlli
asset, build Dev e Routally e 73 test in 5 suite dopo la correzione AX. Nessun nuovo test
file è stato aggiunto. Il primo tentativo della ripresa è stato interrotto per un’attesa
nel bridge CoreSimulator; il tentativo dopo il riavvio è riuscito.

L’anteprima usa lo stesso reducer della registrazione su una copia del registro. I test
nella suite VerticalSliceTests verificano assenza di scritture, parità con la registrazione,
localizzazione IT/EN, annullamento e reset del ciclo.

Il confronto affiancato locale è in
`/Users/Matteo/.codex/visualizations/2026/09/04/01a06e4b-24c6-7860-82cf-a889d3af2861/trama-confronto.html`.

Dopo la richiesta del proprietario le prove usano un solo Simulator per volta; i dispositivi
sono spenti al termine. È stato chiuso anche l’iPhone Air trovato attivo durante il recupero
della toolchain. Le prove finali iPad sono state eseguite con tutti gli iPhone spenti.

## Limiti

VoiceOver parlato, feedback aptico fisico e audit completo delle dichiarazioni di
accessibilità restano da eseguire. Le etichette AX e le prove di layout non li sostituiscono.
Nessun account, servizio remoto o notifica reale viene usato per queste prove.

L’approvazione del concept non chiude DG-VISUAL. La revisione reale deve essere valutata
dal Product Owner prima di estendere Trama alle altre superfici. Nessuna pubblicazione
è implicita in questo rapporto.
