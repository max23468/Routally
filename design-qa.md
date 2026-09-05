# Trama Fase 1 — Revisione del 5 settembre 2026

Ambito: Oggi, dettaglio Routine e riepilogo delle conseguenze.
Stato: revisione implementata e verificata localmente; accettazione visuale del Product Owner ricevuta il 5 settembre 2026 («Mi piace»), sulla revisione `92f97de`.
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

Differenze esplicite presenti nel confronto approvato dal proprietario:

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

Il Product Owner ha approvato questa revisione reale il 5 settembre 2026. La
formalizzazione in Trama Fase 1, UI Foundation, Master Plan e Decision Register conserva
questa approvazione. Il lavoro complessivo prosegue nel [piano DG-VISUAL](docs/DESIGN/dg-visual-plan.md);
la sola approvazione della fase 1 non dichiara chiuso tutto il design. Nessuna pubblicazione
è implicita in questo rapporto.

## Revisione complessiva Trama — 5 settembre 2026

Ambito: i quattro passaggi autorizzati del [piano DG-VISUAL](docs/DESIGN/dg-visual-plan.md).
La [specifica di revisione](docs/DESIGN/design-review.md) e la
[galleria locale](docs/DESIGN/evidence/trama-design-review/index.html) raccolgono il risultato.
Non sostituisce il riferimento Oggi/dettaglio/conseguenze della fase 1 approvata.

### Verifiche del prototipo

- Build isolata `Routally Dev / Development` riuscita. La configurazione inesistente
  `Debug` era la causa del primo errore di risoluzione dei moduli; nessuna modifica
  alla configurazione di progetto è stata necessaria.
- `node scripts/verify-change.mjs --base origin/main`: build Dev e Routally riuscite,
  format e controlli documentali/asset riusciti, **74 test in 5 suite verdi** prima della regressione di localizzazione.
- Il test aggiunto nel file FoundationTests esistente controlla opt-in del prototipo,
  argomento mancante e sconosciuto; il percorso visuale non apre i dati locali.
- iPhone 17 Pro, iOS 26.5: catture degli stati di creazione, permesso/luogo, uscita,
  salvataggio, errore, successo, vuoti, follow-up, cronologia, modifica, Esplora e Kit.
- Tastiera software realmente visibile, con campo e azione sopra il bordo; testo
  inserito e Continua attivato. La cattura della tastiera vuota dimostra l’ingombro.
- Errore → Riprova → conferma Routine creata e arrivo al dettaglio: interazione percorsa
  sul Simulator. La riuscita è una transizione della fixture, non una scrittura di dominio.
- AX del riepilogo: quattro azioni con nome e valore, Chiudi, Indietro e Crea routine;
  messaggio di errore leggibile nella gerarchia. Non equivale a VoiceOver parlato.
- iPhone a testo massimo AX5, scuro e contrasto aumentato: riepilogo, posizione negata,
  follow-up, Esplora, Kit e correzione. Layout verticale e scroll; le catture iniziali
  mostrano solo la porzione superiore delle schermate lunghe.
- Corretto il contrasto delle CTA native nel prototipo: testo nero sul lavanda in scuro,
  bianco sull’indaco in chiaro; catture scure ripetute dopo la correzione.

### Copertura e limiti

Le fixture documentano una sola soluzione per stato e riusano colori, tipografia e
componenti Apple. I valori e le transizioni sono sintetici e in memoria. Le prove non
certificano creazione generale, notifiche/geofence, installazione Kit, ricalcolo,
sincronizzazione o recupero persistente. Non sono un avvio di E07–E11.

La nuova copy Modifica distingue correttamente obiettivo (ricalcolo del periodo corrente)
e nuova sorgente di un collegamento (eventi futuri), come nella sezione 16.4 del Master Plan.
La schermata di correzione conserva l’originale e mostra il contesto del ricalcolo;
la previsione esatta dipenderà dall’integrazione funzionale futura.

VoiceOver parlato, Voice Control, audit di tutte le categorie Dynamic Type, Reduce
Transparency, tastiera/puntatore iPad e aptica/device reali restano non certificati.
Il prototipo non usa animazioni di contenuto indispensabili al significato; questo
non sostituisce il gate Reduce Motion dell’app completa.

Il checkpoint finale del Product Owner resta aperto. Non sono richiesti push, PR,
status trusted remoti, merge o release: gli status legati all’HEAD si registreranno nel
ciclo di pubblicazione se autorizzato. Nessuna approvazione viene dedotta dai test verdi.

### iPad e localizzazione

Su iPad Pro 11-inch (M5), iPadOS 26.5, sono raccolti riepilogo, errore, posizione
negata, cronologia, modifica, Esplora e Kit. La sheet conserva la dimensione form;
la cronologia mantiene lista e dettaglio affiancati. Le righe lunghe proseguono nello scroll.

La prova inglese ha riprodotto un difetto del bundle host: dichiarava soltanto italiano,
impedendo la selezione inglese dei bundle SwiftPM. `Configuration/Info.plist` dichiara
IT/EN e il recupero delle localizzazioni dai bundle; il plist generato è stato riletto.
Riepilogo e controlli nativi in inglese verificati sul Simulator, con orario locale
`8:00 PM`. Riferimenti Apple: [CFBundleLocalizations](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundlelocalizations)
e [CFBundleAllowMixedLocalizations](https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleallowmixedlocalizations).

La regressione di localizzazione controlla il bundle compilato con la configurazione
condivisa: i test sono hostless, quindi `Bundle.main` appartiene al runner Apple.
La selezione effettiva nell’app è verificata separatamente nelle catture IT/EN.
