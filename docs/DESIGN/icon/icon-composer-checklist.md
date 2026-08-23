# Checklist Icon Composer e dispositivi

Questa checklist valida la baseline canonica **A1 Lavender 50**. Icon Composer richiede
macOS Tahoe 26.4 o successivo.

## Materiale da preparare

- A1 Lavender 50 dai livelli `composer-layers/a1-air-medium-*`;
- A1 Amber 50 duplicando A1 e applicando al solo accento i token Amber;
- T1 dai livelli `composer-layers/t1-cycle-consequence-*`;
- derivata Dev dai livelli `composer-layers/dev-app-icon-*`.

A3 e testa 54 non fanno parte del test residuo.

## Import e rendering

1. [x] creare il documento 1024 × 1024;
2. [x] importare `background`, `symbol`, `accent` e, per Dev, `overlay`;
3. [x] verificare che ogni file resti un artwork separato;
4. [x] configurare Default, Dark e Mono;
5. [x] verificare anche Clear light/dark e Tinted light/dark nel contesto di sistema;
6. [x] controllare arco, testa, contatore e fascia Dev a 29 e 40 pt;
7. [x] annotare warning o conversioni applicate dallo strumento: nessun warning.

La variante Dark usa un fondo quasi nero con sottotono indaco, monogramma avorio e accento
lavanda. È una specializzazione cromatica esplicita: evita che l'adattamento automatico
viola/ciano sembri una seconda variante colorata anziché una vera icona Dark.

Clear e Tinted sono stati verificati sulla Home Screen di iOS Simulator 26.5, in modalità
chiara e scura, con le build aggiornate dei target pubblico e Dev. Entrambe mantengono
leggibili il monogramma, il ciclo e la fascia diagonale Dev.

## Salvataggio e Xcode

- [x] preparare i file `.icon` per il versionamento;
- [x] collegare `AppIcon.icon` al target pubblico;
- [x] collegare `AppIconDev.icon` a `Routally Dev`;
- [x] eseguire build Simulator dei due target;
- [ ] `E21` / `M11` — verificare archiviazione e bundle di distribuzione nel ciclo di
  chiusura degli asset definitivi.

## Dispositivi

Questa sezione appartiene a `E20` / `M10` Alpha e si esegue sulla build feature-complete,
non durante la Foundation.

Provare almeno un iPhone e un iPad compatibili con iOS/iPadOS 26 in Home Screen, App
Library, Spotlight, Impostazioni e notifiche, con wallpaper chiari, scuri e fotografici.
Verificare Default, Dark, Clear e Tinted, oltre a Riduci trasparenza e Aumenta contrasto
quando pertinenti.

La checklist è superata se A1 Lavender 50 funziona in tutti i contesti. Amber può sostituire
Lavender soltanto se le prove mostrano un vantaggio concreto; T1 può sostituire A1 soltanto
come fallback globale se la composizione completa fallisce alle misure minime.
