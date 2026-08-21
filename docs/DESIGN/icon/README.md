# Icona Routally — asset e import in Icon Composer

Direzione, regole di costruzione e stato del gate stanno nella sezione 4.8 del
[Master Plan](../../MASTER_PLAN.md). Qui c'è soltanto cosa contiene questa cartella e come
portarla in Icon Composer.

## Cosa c'è

| File | Uso |
|---|---|
| `a1-air-medium-*.svg` | variante preferita in revisione, in attesa di `DG-ICON` |
| `t1-cycle-consequence-*.svg` | versione ridotta senza arco, per le misure minime |
| `a2`, `a3` | stesso segno con più aria attorno all'arco |
| `t2`, `v1`–`v3` | letture alternative: soglia sul ciclo singolo, secondo ciclo incastrato |
| `dev-app-icon-*.svg` | build Dev della sezione 30.1 |
| `layers/` | gli stessi segni con un file per livello, pronti per l'import |

Il suffisso `-indigo` è il segno chiaro su fondo indaco, `-light` è il segno indaco su
fondo chiaro. **La versione indaco è quella primaria**: su uno sfondo chiaro il riquadro
bianco si dissolve e l'icona perde il proprio contorno.

**Ogni** file combinato espone già i livelli come gruppi nominati, quindi qualunque variante
è importabile e separabile. La cartella `layers/` aggiunge, per il segno approvato e per la
build Dev, gli stessi livelli come file distinti con le coordinate già trasformate, che non
dipendono da alcun `transform` esterno: ricompongono il file unico corrispondente con uno
scarto dello 0,06 per cento dei pixel, confinato all'antialiasing sul filo dell'arco.

## Livelli

| Livello | Contenuto | Perché è separato |
|---|---|---|
| `background` | il fondo pieno | Icon Composer può anche generarlo da un colore |
| `symbol` | ciclo, fianco e gamba | è il soggetto e porta il contrasto pieno |
| `accent` | arco di progresso e testa | è secondario e deve poter ricevere un trattamento proprio |
| `overlay` | fascia diagonale, solo Dev | non appartiene al segno |

## Import

Icon Composer fa parte di Xcode 26 e gira su macOS: **questi passaggi non sono stati
eseguiti**, perché l'esplorazione è stata condotta su Linux. Vanno confermati alla prima
apertura dello strumento.

1. Nuovo documento in Icon Composer, tela 1024.
2. Importa i tre file di `layers/` per `a1-air-medium`, nell'ordine fondo, simbolo, accento.
3. Verifica che lo strumento accetti i livelli come artwork separati e non li appiattisca.
4. Genera gli aspetti previsti e controlla il risultato in chiaro, scuro e monocromatico.
5. Esporta e collega l'asset al target.

## Cosa guardare, una volta dentro lo strumento

Sono i punti che il rendering piatto non può prevedere.

- **Come reagisce l'arco al materiale e alla riflessione speculare di iOS 26.** È l'elemento
  più sottile del segno ed è il primo candidato a sparire o a diventare rumore.
- **Se il monocromatico distingue ancora accento e simbolo**, che lì restano separati solo
  per luminanza.
- **Le misure minime su dispositivo**, 29 e 40 punti: sul foglio l'attacco sottile della
  rastremazione regge, ma va visto a distanza di lettura. Se non tiene, la risposta è
  `t1-cycle-consequence`, non un arco più spesso.

## Rigenerare gli asset

Gli SVG di questa cartella sono prodotti da una sorgente parametrica versionata.

```sh
node scripts/build-icon-assets.mjs    # rigenera gli asset
node scripts/check-icon-assets.mjs    # verifica che i file coincidano con la sorgente
```

Una modifica alla geometria si fa sulla sorgente, non ritoccando gli SVG a mano: le misure
tengono insieme tangenze, contrasto di spessore, compensazione ottica e centraggio, e una
correzione su un file solo li disallinea fra i due trattamenti cromatici, i livelli
separati e la derivata Dev. Il controllo fallisce proprio in quel caso, oltre che se un
file manca o se ne avanza uno non più prodotto dalla sorgente.
