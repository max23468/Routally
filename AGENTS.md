# Istruzioni per gli agenti

1. Leggi integralmente `docs/MASTER_PLAN.md` prima di qualsiasi attività.
2. Il Master Plan è la fonte canonica: non reinterpretare scope, prodotto, pricing, UX,
   architettura o roadmap.
3. Non aggiungere dipendenze, servizi esterni, analytics, AI o backend senza approvazione.
4. Usa framework Apple nativi e la toolchain approvata.
5. Codex e Claude Code sono agenti alternativi: un solo agente lavora su un task.
6. Non operare su account, servizi remoti, deploy o release senza autorizzazione esplicita; una richiesta di pubblicazione autorizza il solo ciclo tecnico definito sotto.
7. Mantieni modifiche circoscritte, testate e prive di secret o dati reali.
8. Il repository è pubblico ma proprietario: niente community GitHub o licenza open source.
9. Documentazione di prodotto in italiano; nomi tecnici e codice in inglese.
10. Prima di un handoff, lascia working tree pulito e documenta verifiche e problemi aperti.
11. Segui il workflow operativo comune in `docs/ENGINEERING/agent-workflow.md`.

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
