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

1. creare il documento 1024 × 1024;
2. importare `background`, `symbol`, `accent` e, per Dev, `overlay`;
3. verificare che ogni file resti un artwork separato;
4. configurare Default, Dark e Mono;
5. verificare anche Clear light/dark e Tinted light/dark;
6. controllare arco, testa, contatore e fascia Dev a 29 e 40 pt;
7. annotare warning o conversioni applicate dallo strumento.

## Salvataggio e Xcode

- versionare il file `.icon`;
- collegarlo al target pubblico;
- collegare la derivata Dev a `Routally Dev`;
- eseguire build pulite dei due target;
- verificare bundle, catalogo compilato e archiviazione.

## Dispositivi

Provare almeno un iPhone e un iPad compatibili con iOS/iPadOS 26 in Home Screen, App
Library, Spotlight, Impostazioni e notifiche, con wallpaper chiari, scuri e fotografici.
Verificare Default, Dark, Clear e Tinted, oltre a Riduci trasparenza e Aumenta contrasto
quando pertinenti.

La checklist è superata se A1 Lavender 50 funziona in tutti i contesti. Amber può sostituire
Lavender soltanto se le prove mostrano un vantaggio concreto; T1 può sostituire A1 soltanto
come fallback globale se la composizione completa fallisce alle misure minime.
