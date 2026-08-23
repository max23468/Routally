# Istruzioni per gli agenti

1. `docs/MASTER_PLAN.md` è la fonte canonica. Non leggerlo integralmente: leggi sempre le
   sezioni 0, 5, 6, 40, 50 e 51, poi quelle che il tuo intervento tocca secondo la matrice in
   `docs/ENGINEERING/agent-workflow.md`. In dubbio consulta l'Indice, non l'intero documento.
   Un technical gate aperto della sezione 40 precede l'implementazione che vincola. La
   matrice copre l'oggetto dell'intervento, non le dimensioni trasversali della sezione 0.4
   — core gratuito e, quando applicabile, Plus, accessibilità, localizzazione, privacy,
   persistenza, correzione, notifiche e test — che restano obbligatorie e sono mappate in `agent-workflow.md`.
2. Non reinterpretare scope, prodotto, pricing, UX, architettura o roadmap.
3. Non aggiungere dipendenze, servizi esterni, analytics, AI o backend senza approvazione.
4. Usa framework Apple nativi e la toolchain approvata.
5. Codex e Claude Code sono agenti alternativi: un solo agente lavora su un task.
6. Non operare su account, servizi remoti, deploy o release senza autorizzazione esplicita; una richiesta di pubblicazione autorizza il solo ciclo tecnico definito sotto.
7. Mantieni modifiche circoscritte, testate e prive di secret o dati reali.
8. Il repository è pubblico ma proprietario: niente community GitHub o licenza open source.
9. Documentazione di prodotto in italiano; nomi tecnici e codice in inglese.
10. Prima di un handoff, lascia working tree pulito e documenta verifiche e problemi aperti.
11. Segui il workflow operativo comune in `docs/ENGINEERING/agent-workflow.md`.

## Verifiche locali

```sh
swift format lint --recursive --strict RoutallyApp RoutallyTests RoutallyTGDataProbeWidget Packages/RoutallyModules
xcodebuild build -project Routally.xcodeproj -scheme "Routally Dev" -destination "platform=iOS Simulator,name=iPhone 17 Pro"
xcodebuild test -project Routally.xcodeproj -scheme "Routally Tests" -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

## Significato di `Pubblica`

Quando il proprietario, riferendosi alla repository o alla modifica corrente,
dice `Pubblica` o chiede in modo affermativo e inequivocabile di pubblicare,
autorizza l'intero ciclo tecnico applicabile. Domande, ipotesi, pianificazioni e
negazioni non costituiscono autorizzazione. L'agente non si ferma a stati
intermedi e completa tutti i passaggi applicabili: preparazione e verifiche,
branch e commit, versione e changelog quando richiesti, push, PR, soli gate
bloccanti, merge, tag e GitHub Release quando previsti, deploy o promozione
tecnica e verifica live. La sequenza concreta, in particolare tra versionamento,
merge, deploy e release, è quella definita dalla policy della repository.

I finding P2/P3 della review restano advisory e non autorizzano modifiche:
l'agente li implementa soltanto su richiesta esplicita del proprietario. Quando
la review è conclusa e l'evidenza si riferisce all'HEAD esatto, li riepiloga e
prosegue con la pubblicazione; i finding P0/P1 restano bloccanti.

La pulizia finale rimuove soltanto branch e worktree temporanei creati nel ciclo
corrente e già assorbiti; controlla stash e altri residui senza alterare elementi
preesistenti o estranei alla pubblicazione. Se un passaggio non è applicabile, lo
dichiara e prosegue con gli altri. La richiesta affermativa di pubblicazione
vale come autorizzazione a PR, merge, deploy tecnico e release previsti dal
ciclo, senza una seconda conferma. Non autorizza pubblicazione di temi Shopify
live, submission Shopify App Store, billing o nuove attivazioni produttive,
TestFlight o App Store, invii Aruba, email o scansioni reali, né aggiornamenti
Notion: queste azioni richiedono una richiesta esplicita separata. Una richiesta
riferita soltanto a una di queste azioni non avvia la pubblicazione della
repository. Non dichiarare `pubblicato` finché il ciclo applicabile e la
rilettura finale di PR, check, deploy, release e stato Git non sono completi.
