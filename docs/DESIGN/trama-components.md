# Trama — contratto dei componenti e degli stati

**Ambito:** consolidamento del design DG-VISUAL / E06.
**Riferimento approvato:** resa SwiftUI `92f97de`, approvata il 5 settembre 2026.
**Stato:** anatomia della fase 1 consolidata; applicazioni alle superfici future da
valutare con i concept. Questo documento non avvia E07–E11.

## Gerarchia comune

| Livello | Regola | Riferimento |
|---|---|---|
| Navigazione | titoli, barre, sheet e ricerca di sistema; gerarchia stabile | [Navigazione](navigation.md) |
| Contenuto ordinario | righe compatte, testo e separatori; superficie neutra | riga dipendente di Trama |
| Relazione significativa | un solo modulo espanso per sorgente e conseguenze | `RoutineCausalCard` approvata |
| Azione | una primaria per contesto; secondarie testuali o native | Registra, Escludi, Annulla |
| Stato | testo e simbolo insieme al colore; spiegazione utile all’azione | soglia distinta dal momento del follow-up |

Il filo identifica la relazione fra un evento e le conseguenze. Non rappresenta una
percentuale generale, l’avanzamento obbligatorio di un form o un collegamento già salvato
quando l’utente sta ancora configurando. L’anteprima deve dichiarare il suo carattere
ipotetico. Nessun filo decorativo sulle righe prive di relazioni.

## Anatomia e misure

Le basi seguenti documentano la resa approvata. Crescono con Dynamic Type: non sono
altezze o dimensioni bloccate da riprodurre rigidamente.

| Elemento | Base e composizione | Adattamento |
|---|---|---|
| Titolo di pagina | titolo nativo di navigazione | dimensione e collasso di sistema |
| Sorgente nel modulo | SF `title3`, semibold; simbolo e testo allineati | nome multilinea, azione sotto al titolo a testo accessibile |
| Conseguenza | testo 14 pt scalabile, semibold; contesto 12 pt scalabile | simbolo sopra al testo alle dimensioni accessibili |
| Metadati sorgente | 12 pt scalabile, secondario; valori rilevanti indaco | nessuna riduzione del font per far entrare il testo |
| Registra | 13 pt scalabile, semibold; target minimo 44 pt | fondo che cresce insieme al testo |
| Spazi interni | 4/8/12/16 pt; intervalli 20/24 pt per la relazione Trama | spazi verticali espandibili, priorità al contenuto |
| Superficie causale | angolo continuo 24 pt, lavanda molto tenue, bordo discreto | variante scura e contrasto dinamico |
| Simboli | SF Symbols coerenti, supporto al testo; cerchio neutro | dimensione contenuta, niente simboli che sottraggono la larghezza al nome |
| Filo | continuo, ancorato a nodi reali; origine ed effetti leggibili in testo | eliminabile senza perdere informazione |

Il valore `prima → dopo` resta completo. In presenza di poco spazio si va a capo: non si
tronca una conseguenza, non si riduce il carattere e non si sostituisce una frase con un
simbolo ambiguo.

## Tipografia delle sheet di configurazione

Le sheet condividono gli stili di sistema e la [UI Foundation](ui-foundation.md#tipografia).
Non si ingrandisce tutta una tavola per correggere la leggibilità di singoli elementi.

| Ruolo | Stile | Base standard |
|---|---|---|
| Domanda principale | `.largeTitle` bold | 34 pt |
| Titolo sorgente nel modulo Trama | `.title3` semibold | 20 pt |
| Frase e valori modificabili | `.body` | 17 pt |
| Titolo della barra, azioni e pulsanti | metriche native, corpo standard | 17 pt |
| Contesto secondario, quando necessario | `.subheadline` | 15 pt |
| Metadati, quando necessari | `.footnote` | 13 pt |

I numeri descrivono la dimensione standard, non misure fisse da imporre a Dynamic Type.
Corpo e valori selezionabili mantengono la stessa dimensione; colore e chevron distinguono
l’interazione. Testi lunghi vanno a capo e i controlli conservano il target minimo di 44 pt.
La scala vale per tutto il flusso, senza alterare le metriche specifiche della card causale
già approvata. I pixel del raster non equivalgono ai punti della UI nativa.

## Pulsanti e controlli

| Ruolo | Trattamento | Vincolo |
|---|---|---|
| Registrazione quotidiana | Registra satinato approvato | indaco dinamico, nessuna brillantezza aggiuntiva |
| Creazione o conferma in sheet | primaria nativa coerente con la UI Foundation | l’eccezione satinata di Registra non approva automaticamente un nuovo stile globale |
| Configurazione facoltativa | azione secondaria testuale esplicita | non deve sembrare obbligatoria per poter creare |
| Esclusione puntuale | azione nominata con il suo oggetto | distinta dall’annullamento di tutta la registrazione |
| Annullamento | azione esplicita nello stesso contesto | non soltanto gesto o feedback aptico |
| Azione distruttiva | trattamento e conferma nativi con impatto comprensibile | non deve sembrare una normale navigazione |
| Campo e scelta | etichetta visibile; picker, stepper e input nativi | valore e nome del campo restano distinti anche dopo la compilazione |

Non introdurre una famiglia diversa di pillole, badge, icone o card per ogni nuova
schermata. Barre e sheet adottano il materiale di sistema; il contenuto rimane leggibile
su superfici semplici. [UI Foundation](ui-foundation.md) resta il contratto completo.

## Stati da portare nei concept

| Stato | Informazione indispensabile | Azione/resa prevista |
|---|---|---|
| Primo ingresso | nessun dato creato implicitamente | orientamento breve; ingresso canonico alla creazione |
| Nessuna necessità | tutto sotto controllo | non suggerire lavoro per riempire lo spazio |
| Routine ordinaria | nome, contesto utile, azione primaria | riga compatta |
| Routine collegata | origine ed effetti | modulo Trama, anteprima espandibile |
| Soglia raggiunta | soglia distinta da reset | progresso conservato fino alla chiusura configurata |
| Follow-up futuro | quando diventa utile | non presentarlo come già pronto |
| Follow-up pronto | passo concreto e origine | Fatto; rinvio quando applicabile |
| Registrazione applicata | cosa è cambiato e perché | riepilogo con esclusione puntuale e annullamento |
| Anteprima indisponibile | impossibilità di mostrare la previsione | non confondere con un errore di salvataggio |
| Modulo incompleto | campo o scelta ancora necessari | CTA non attiva; spiegazione contestuale, senza errori prematuri |
| Salvataggio | operazione in corso | controllo pertinente disabilitato, dati visibili |
| Errore recuperabile | dati preservati e problema comprensibile | Riprova nello stesso contesto |
| Offline | continuità dell’uso locale | stato discreto quando utile |
| Correzione/chiusura con modifiche | impatto sulle conseguenze o sui dati inseriti | conferma nativa chiara e recupero previsto |

Questa tabella specifica la copertura visuale. Non dichiara implementate le azioni delle
epiche successive e non sostituisce gli invarianti del dominio.

## iPhone, iPad e accessibilità

- iPhone: una colonna; form in sheet nativa; nessuna tab bar ricreata dentro la sheet.
- iPad: lista e dettaglio mantengono `NavigationSplitView`; il form conserva una larghezza
  leggibile, senza allargare campi e pulsanti fino ai bordi dell’intero display.
- Testo massimo: titoli, valore, errore e CTA devono essere raggiungibili tramite scroll;
  righe e footer diventano verticali, senza altezza fissa.
- Tastiera: il controllo attivo e l’azione utile restano raggiungibili; il footer non copre
  il campo o il riepilogo. Non duplicare le scorciatoie globali nei singoli controlli.
- Dark e contrasto aumentato: asset dinamici già approvati; non invertire un raster chiaro.
- Riduci movimento: significato e risultato completi senza animazione del filo.
- VoiceOver/Voice Control: nome specifico per ogni azione, ordine titolo → controllo →
  contesto/errore → riepilogo → azione. Le immagini dei concept non certificano questi test.

## Benchmark e verifica

La direzione usa l’ingresso rapido con dettaglio progressivo documentato da
[Apple Reminders](https://support.apple.com/en-gb/102484) e i criteri HIG per
[l’inserimento dei dati](https://developer.apple.com/design/human-interface-guidelines/entering-data).
Il benchmark competitivo e i riferimenti del proprietario restano quelli della
UI Foundation e di Trama Fase 1: non vengono introdotti nuovi pattern di gamification.

Il presente consolidamento riusa le evidenze della fase 1. Per ogni applicazione futura
si confrontano concept e resa reale nello stesso stato e nelle stesse proporzioni, senza
usare un’immagine generata come prova di implementazione o accessibilità.
