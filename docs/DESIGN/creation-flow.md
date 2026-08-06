# Creazione e vertical slice

- **Stato:** Confirmed
- **Epic:** E02 — Apple-native UI Direction
- **Fonte canonica:** [Master Plan](../MASTER_PLAN.md), sezioni 10.3, 14 e 26.5

## Un solo flusso

Nuova routine è una sheet SwiftUI nativa aperta da:

- `+` nella tab Routine;
- `Crea una routine` nell'onboarding;
- `Configura e aggiungi` da un Kit.

Gli ingressi precompilano dati pertinenti ma usano lo stesso modello e la stessa
navigazione. Non esistono modalità rapida, guidata o avanzata separate.

## Struttura della sheet

- navigation bar Liquid Glass con titolo, Indietro e Chiudi;
- contenuto in `Form`/`List` nativa con una domanda primaria per schermata;
- opzioni consigliate visibili e `Altro`/`Personalizza` come progressive disclosure;
- riepilogo naturale aggiornato sotto le scelte pertinenti;
- azione primaria nella toolbar inferiore di sistema;
- nessun background glass custom sul contenuto della form.

Su iPhone la sheet parte ampia e può diventare full-height seguendo il sistema. Su iPad
resta una form sheet leggibile. La gerarchia, i campi e la validazione sono identici.

## Passi

### 1. Routine

Domanda: **Che cosa vuoi gestire?**

- nome obbligatorio;
- proposta di SF Symbol e Area modificabili;
- scelta iniziale: regolarità, obiettivo, ciclo, routine collegata o non sono sicuro.

### 2. Regola

Domanda adattiva: **Come vuoi misurarlo o quando deve accadere?**

Mostra soltanto i campi minimi dell'archetipo scelto. Quando nome e regola essenziale
sono validi, `Crea routine` diventa disponibile. `Continua a configurare` rimane
secondaria e porta alle conseguenze.

### 3. Cosa succede dopo

- collega una o più routine esistenti oppure ne prepara una dipendente;
- definisce incremento, soglia e follow-up;
- mostra subito la frase completa delle conseguenze;
- impedisce link circolari e configurazioni non spiegabili.

### 4. Quando ricordartelo

- momento utile: subito, questa sera, luogo salvato o scelta personalizzata;
- un reminder geografico richiede sempre un fallback temporale;
- il permesso viene chiesto soltanto dopo la scelta di un luogo;
- la negazione del permesso conserva la configurazione con fallback.

### 5. Riepilogo

Il riepilogo è una frase naturale e schede modificabili per Frequenza, Collegamenti,
Passo successivo e Promemoria. `Crea routine` salva in modo atomico; in caso di errore i
dati inseriti restano disponibili e l'utente può riprovare.

## Stati e feedback

| Stato | Comportamento |
|---|---|
| Incompleto | CTA disabilitata e spiegazione vicino al campo mancante |
| Valido minimo | `Crea routine` primaria, `Continua a configurare` secondaria |
| Modificato | chiusura esplicita offre Continua, Scarta o Annulla |
| Salvataggio | controllo disabilitato, progresso vicino alla CTA, nessuna sheet aggiuntiva |
| Errore | messaggio inline, focus sul problema, dati preservati |
| Successo | feedback visivo/aptico, dismiss e apertura del dettaglio creato |

Gli errori compaiono dopo l'interazione o il tentativo di avanzare, non mentre l'utente
sta ancora digitando. Il testo descrive come correggere, non soltanto cosa è sbagliato.

## Scenario canonico della vertical slice

Il percorso parte da `NewUser`, senza routine. L'utente crea Palestra con obiettivo
`3 volte a settimana`, collega Asciugamano palestra con soglia `4 utilizzi`, configura
`Prepara un asciugamano pulito` all'arrivo a Casa con fallback alle 20:00 e sceglie di
avviare il ciclo successivo al completamento.

Per verificare rapidamente soglia e follow-up, la fixture `ThresholdReached` riproduce
la stessa configurazione dopo tre allenamenti storici: Palestra è a `1/3` nel periodo
corrente e Asciugamano a `3/4`. Non cambia le regole e non introduce dati reali.

### Criteri di accettazione

| ID | Azione | Risultato verificabile |
|---|---|---|
| `E02-VS-01` | aprire Nuova routine | sheet nativa, focus sul nome, nessun permesso richiesto |
| `E02-VS-02` | configurare Palestra | riepilogo mostra obiettivo, collegamento, soglia, follow-up e fallback |
| `E02-VS-03` | creare | Palestra e Asciugamano risultano collegate; la nuova routine apre nel dettaglio |
| `E02-VS-04` | registrare il quarto evento della fixture | Palestra passa a `2/3`, Asciugamano a `4/4`, nasce un solo follow-up |
| `E02-VS-05` | leggere il riepilogo | ogni conseguenza e la sua origine sono visibili; `Annulla` e `Visualizza` disponibili |
| `E02-VS-06` | chiudere il riepilogo | Asciugamano resta a `4/4`; la soglia non resetta il ciclo |
| `E02-VS-07` | simulare arrivo a Casa | il follow-up entra in Adesso ed è notificabile una sola volta |
| `E02-VS-08` | far scattare anche il fallback | non viene creato né notificato un secondo follow-up |
| `E02-VS-09` | completare il follow-up | il follow-up è completato e Asciugamano apre un nuovo ciclo a `0/4` |
| `E02-VS-10` | annullare la registrazione | conseguenze, soglia e follow-up vengono rimossi o ricalcolati atomicamente |
| `E02-VS-11` | ripetere offline | tutte le azioni restano disponibili e indicano sincronizzazione pendente |
| `E02-VS-12` | usare iPad | lista e dettaglio restano coordinati durante creazione e completamento |

Ogni criterio deve essere verificabile in E03 con fixture e preview e, quando richiede
integrazione reale, nelle milestone tecniche pertinenti. E02 definisce il comportamento,
non simula servizi o anticipa il motore di dominio.

## Accessibilità del flusso

- una domanda primaria e un titolo VoiceOver per schermata;
- ordine: titolo, spiegazione, controllo, errore, riepilogo, CTA;
- Return avanza soltanto quando non causa salvataggi ambigui;
- il riepilogo delle conseguenze viene annunciato dopo la registrazione;
- Dynamic Type può trasformare righe orizzontali in stack verticali;
- nessun campo, passo o azione dipende da drag, swipe o long press;
- con Voice Control ogni azione possiede un'etichetta univoca e visibile.

## Riferimenti

- Apple HIG — [Sheets](https://developer.apple.com/design/human-interface-guidelines/sheets)
- Apple HIG — [Buttons](https://developer.apple.com/design/human-interface-guidelines/buttons)
- Apple HIG — [Feedback](https://developer.apple.com/design/human-interface-guidelines/feedback)
- Apple HIG — [Undo and redo](https://developer.apple.com/design/human-interface-guidelines/undo-and-redo)
