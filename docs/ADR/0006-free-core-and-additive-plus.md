# ADR-0006 — Core 1.0 gratuito e Plus additivo

- **Stato:** Accepted
- **Data:** 23 agosto 2026
- **Ambito:** prodotto, roadmap, architettura commerciale e StoreKit

## Contesto

La baseline precedente prevedeva una 1.0 freemium con limiti quantitativi, piano annuale,
trial e acquisto Lifetime. Questo avrebbe richiesto StoreKit, paywall, downgrade e una
segmentazione commerciale prima di avere evidenza sufficiente su attivazione, retention e
valore reale di Routally.

Il cuore del prodotto — registrare un evento una volta e propagare conseguenze, soglie e
follow-up — deve poter essere provato e usato integralmente. Limitare routine o
collegamenti avrebbe reso il confine commerciale parte del motore fondamentale.

## Decisione

1. Routally 1.0 viene lanciata completamente gratuita e senza limiti commerciali.
2. Tutte le funzioni pubblicate nella 1.0 rimangono gratuite per tutti, incluse
   manutenzione, correzioni e normali evoluzioni del core.
3. Tutti i 12 Kit, routine, collegamenti, cronologia, luoghi, widget, Analisi, iCloud ed
   esportazione sono inclusi nella 1.0.
4. La 1.0 non contiene StoreKit, prodotti IAP, trial, abbonamenti, paywall, entitlement o
   downgrade commerciale.
5. `DG-PLUS-LAUNCH` usa due checkpoint: l’approvazione del bundle apre `TG-STOREKIT`
   senza autorizzare il lancio; la chiusura finale segue lo spike e autorizza la
   pubblicazione. Il bundle richiede almeno due nuove capacità principali, promessa
   coerente ed evidenza di valore.
6. Il modello Plus confermato è un acquisto non consumabile da 29,99 € una tantum, senza
   abbonamento nella 1.X.
7. Account, backend, web, Android, condivisione e servizi cloud ricorrenti appartengono a
   `DG-CLOUD-PRICING` della 2.0 e non riducono i diritti locali acquistati.

## Conseguenze

### Positive

- la 1.0 ottimizza adozione, fiducia e product–market fit;
- il motore non contiene quote o stati di downgrade;
- la release elimina StoreKit e una superficie significativa di test e App Review;
- Plus dovrà competere sul valore di nuove capacità, non sulla rimozione di limiti;
- il cloud futuro può avere un modello sostenibile separato.

### Negative e rischi

- la 1.0 non genera ricavi diretti;
- il lancio di Plus può essere rinviato se il bundle non supera il gate;
- il prezzo una tantum richiede che i costi ricorrenti restino fuori dal perimetro locale;
- la documentazione e le preview precedenti Free/Plus devono essere rimosse o riallineate.

## Decisioni sostituite

Sono sostituiti `MP-FREE-LIMITS`, Annual 14,99 €, trial di 14 giorni, Lifetime 39,99 €,
segmentazione 4 Kit Free/8 Plus, StoreKit nella 1.0, paywall, grace period e downgrade.
