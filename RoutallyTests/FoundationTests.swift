import Foundation
import RoutallyDomain
import RoutallyFixtures
import Testing

@testable import RoutallyFeatures

@Suite("M01 E03 Foundation")
@MainActor
struct FoundationTests {
  @Test("Le fixture canoniche sono tutte disponibili")
  func canonicalFixturesAreAvailable() {
    #expect(
      Set(DemoScenario.allCases)
        == Set([
          .emptyProfile,
          .newUser,
          .typicalUser,
          .highlyOrganizedUser,
          .thresholdReached,
          .offlineWithPendingChanges,
          .cloudConflict,
          .unrestrictedLibrary,
          .largeHistory,
        ]))
  }

  @Test("Le fixture senza limiti e con storico ampio restano distinte")
  func unrestrictedLibraryAndLargeHistoryRemainDistinct() {
    let unrestrictedLibrary = DemoFixtures.snapshot(for: .unrestrictedLibrary)
    let largeHistory = DemoFixtures.snapshot(for: .largeHistory)

    #expect(unrestrictedLibrary.routines.count == 30)
    #expect(unrestrictedLibrary.followUps.isEmpty)
    #expect(largeHistory.routines.count == 30)
    #expect(largeHistory.followUps.count == 120)
    #expect(largeHistory.followUps.allSatisfy { $0.state == .completed })
  }

  @Test("Le fixture richiedono esplicitamente la modalità demo")
  func fixturesRequireExplicitDemoLaunchMode() {
    let demo = DemoFixtures.snapshot(
      arguments: ["-launchMode", "demo", "-demoScenario", "largeHistory"]
    )
    let nonDemo = DemoFixtures.snapshot(
      arguments: ["-launchMode", "production", "-demoScenario", "largeHistory"]
    )

    #expect(demo.routines.count == 30)
    #expect(demo.followUps.count == 120)
    #expect(nonDemo.routines.isEmpty)
    #expect(nonDemo.followUps.isEmpty)
  }

  @Test("Il quarto allenamento crea una sola conseguenza collegata")
  func fourthWorkoutCreatesOneFollowUp() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))

    #expect(store.recordRoutine(id: "gym"))
    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 2)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 4)
    #expect(store.snapshot.followUps.count == 1)
    #expect(store.consequenceSummary?.effects.count == 3)
  }

  @Test("Arrivo e fallback non duplicano il follow-up")
  func arrivalAndFallbackAreIdempotent() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordRoutine(id: "gym")

    let revealedAtHome = store.revealFollowUpAtHome()
    let deliverableAtFallback = store.triggerFallback()
    store.simulateNotificationDelivery(for: revealedAtHome + deliverableAtFallback)

    #expect(store.snapshot.followUps.count == 1)
    #expect(store.snapshot.followUps.first?.state == .ready)
    #expect(store.snapshot.notificationCount == 1)
  }

  @Test("Arrivo a casa rende pronti solo i follow-up configurati per casa")
  func arrivalOnlyRevealsHomeFollowUps() {
    let store = RoutallyStore(snapshot: RoutallySnapshot())

    var eveningDraft = creationDraft(name: "Palestra")
    eveningDraft.towelThreshold = 1
    eveningDraft.usefulMoment = .evening
    store.createRoutine(from: eveningDraft)

    var homeDraft = creationDraft(name: "Corsa")
    homeDraft.towelThreshold = 1
    homeDraft.usefulMoment = .home
    store.createRoutine(from: homeDraft)

    store.recordRoutine(id: "gym")
    store.recordRoutine(id: "gym-2")
    let revealedFollowUpIDs = store.revealFollowUpAtHome()

    #expect(
      store.snapshot.followUps.first { $0.id == "clean-gym-towel" }?.state
        == .waitingForUsefulMoment
    )
    #expect(
      store.snapshot.followUps.first { $0.id == "clean-gym-2-towel" }?.state == .ready
    )
    #expect(store.snapshot.notificationCount == 0)

    store.simulateNotificationDelivery(for: revealedFollowUpIDs)
    #expect(store.snapshot.notificationCount == 1)
  }

  @Test("Escludere l'asciugamano preserva l'evento sorgente")
  func excludingTowelPreservesWorkout() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordRoutine(id: "gym")

    store.excludeEffect(id: "gym-towel")

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 2)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 3)
    #expect(store.snapshot.followUps.isEmpty)
  }

  @Test("Escludere solo il follow-up preserva il ciclo dell'asciugamano")
  func excludingFollowUpPreservesTowelCycle() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordRoutine(id: "gym")

    store.excludeEffect(id: "clean-gym-towel")

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 2)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 4)
    #expect(store.snapshot.followUps.isEmpty)
    #expect(
      store.consequenceSummary?.effects.first { $0.id == "gym-towel" }?.isExcluded == false
    )
    #expect(
      store.consequenceSummary?.effects.first { $0.id == "clean-gym-towel" }?.isExcluded
        == true
    )
  }

  @Test("Una registrazione successiva ricrea il follow-up escluso")
  func recordingAfterFollowUpExclusionRecoversCycle() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordRoutine(id: "gym")
    store.excludeEffect(id: "clean-gym-towel")
    store.clearConsequenceSummary()

    #expect(store.recordRoutine(id: "gym"))

    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 4)
    #expect(store.snapshot.followUps.first?.id == "clean-gym-towel")
    #expect(store.snapshot.followUps.first?.state == .waitingForUsefulMoment)
    #expect(
      store.consequenceSummary?.effects.contains { $0.id == "clean-gym-towel" } == true
    )
  }

  @Test("Un follow-up immediato escluso può essere ricreato")
  func excludingImmediateFollowUpAllowsRecreation() {
    let store = RoutallyStore(snapshot: RoutallySnapshot())
    var draft = creationDraft(name: "Corsa")
    draft.towelThreshold = 1
    draft.usefulMoment = .immediate
    store.createRoutine(from: draft)

    #expect(store.recordRoutine(id: "gym"))
    store.excludeEffect(id: "clean-gym-towel")
    store.clearConsequenceSummary()

    #expect(store.recordRoutine(id: "gym"))
    #expect(store.snapshot.followUps.first?.id == "clean-gym-towel")
    #expect(store.snapshot.followUps.first?.state == .ready)
  }

  @Test("Annullare ripristina atomicamente lo stato della fixture")
  func undoRestoresFixtureState() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordRoutine(id: "gym")

    store.undoLastRecording()

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 1)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 3)
    #expect(store.snapshot.followUps.isEmpty)
    #expect(store.consequenceSummary == nil)
  }

  @Test("Annullare dopo Escludi non sottrae due volte la conseguenza")
  func undoAfterExclusionDoesNotApplyEffectTwice() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordRoutine(id: "gym")
    store.excludeEffect(id: "gym-towel")

    store.undoLastRecording()

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 1)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 3)
    #expect(store.snapshot.followUps.isEmpty)
  }

  @Test("Annullare una registrazione successiva preserva il follow-up precedente")
  func undoLaterRecordingPreservesPriorFollowUp() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordRoutine(id: "gym")
    store.clearConsequenceSummary()

    store.recordRoutine(id: "gym")
    store.undoLastRecording()

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 2)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 4)
    #expect(store.snapshot.followUps.first?.id == "clean-gym-towel")
    #expect(store.snapshot.followUps.first?.state == .waitingForUsefulMoment)
  }

  @Test("Una nuova registrazione dopo Escludi usa il progresso corrente")
  func recordAfterExclusionUsesCurrentProgress() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordRoutine(id: "gym")
    store.excludeEffect(id: "gym-towel")
    store.clearConsequenceSummary()

    #expect(store.recordRoutine(id: "gym"))

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 3)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 4)
    #expect(store.consequenceSummary?.effects.first?.title.contains("3/3") == true)
  }

  @Test("Completare il follow-up riavvia il ciclo anche offline")
  func completingFollowUpResetsCycleOffline() {
    let store = RoutallyStore(
      snapshot: DemoFixtures.snapshot(for: .offlineWithPendingChanges)
    )
    store.recordRoutine(id: "gym")
    store.revealFollowUpAtHome()

    store.completeFollowUp(id: "clean-gym-towel")

    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 0)
    #expect(store.snapshot.followUps.first?.state == .completed)
    #expect(store.snapshot.hasPendingChanges)
  }

  @Test("La creazione applica tutte le scelte configurate")
  func creationAppliesConfiguredDraft() {
    let store = RoutallyStore(snapshot: RoutallySnapshot())
    let draft = RoutineCreationDraft(
      name: "  Corsa  ",
      symbol: "heart",
      area: "wellbeing",
      weeklyTarget: 5,
      linksTowel: true,
      towelThreshold: 6,
      followUpTitle: "  Prepara le scarpe  ",
      usefulMoment: .evening,
      fallbackMinutes: 1_200,
      startsNextCycle: false
    )

    #expect(store.createRoutine(from: draft) == "gym")
    #expect(store.snapshot.routines.first { $0.id == "gym" }?.name == "Corsa")
    #expect(store.snapshot.routines.first { $0.id == "gym" }?.symbol == "heart")
    #expect(store.snapshot.routines.first { $0.id == "gym" }?.target == 5)
    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 0)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.target == 6)
    #expect(store.creationDraft(forRoutineID: "gym")?.area == "wellbeing")
    #expect(store.creationDraft(forRoutineID: "gym")?.followUpTitle == "Prepara le scarpe")
    #expect(store.creationDraft(forRoutineID: "gym")?.startsNextCycle == false)
  }

  @Test("La creazione usa la locale richiesta per i testi sintetici")
  func creationUsesRequestedLocale() {
    let store = RoutallyStore(snapshot: RoutallySnapshot())
    let locale = Locale(identifier: "en")
    let draft = creationDraft(name: "Gym")

    #expect(store.createRoutine(from: draft, locale: locale) == "gym")
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.name == "Gym towel")
  }

  @Test("La registrazione usa la locale richiesta per conseguenze e follow-up")
  func recordingUsesRequestedLocale() {
    let store = RoutallyStore(snapshot: RoutallySnapshot())
    let locale = Locale(identifier: "en")
    var draft = creationDraft(name: "Gym")
    draft.towelThreshold = 1
    draft.followUpTitle = "Prepare the equipment"
    store.createRoutine(from: draft, locale: locale)

    #expect(store.recordRoutine(id: "gym", locale: locale))
    #expect(store.consequenceSummary?.title == "Workout logged")
    #expect(store.snapshot.followUps.first?.origin.contains("Gym towel") == true)
  }

  @Test("Creare una seconda routine preserva lo stato esistente")
  func creationPreservesExistingState() {
    let existingFollowUp = FollowUpSummary(
      id: "existing-follow-up",
      title: "Esistente",
      origin: "Test",
      state: .ready
    )
    let store = RoutallyStore(
      snapshot: RoutallySnapshot(
        routines: [
          RoutineSummary(
            id: "gym",
            name: "Palestra",
            symbol: "figure.strengthtraining.traditional",
            context: "3 volte",
            progress: 1,
            target: 3
          )
        ],
        followUps: [existingFollowUp],
        notificationCount: 1
      )
    )

    let createdID = store.createRoutine(from: creationDraft(name: "Corsa"))

    #expect(createdID == "gym-2")
    #expect(store.snapshot.routines.map(\.id) == ["gym", "gym-2", "gym-2-towel"])
    #expect(store.snapshot.routines.first?.progress == 1)
    #expect(store.snapshot.followUps == [existingFollowUp])
    #expect(store.snapshot.notificationCount == 1)
  }

  @Test("Lo store preserva conteggio e identità di consegna espliciti")
  func storePreservesExplicitNotificationState() {
    let mutedStore = RoutallyStore(
      snapshot: RoutallySnapshot(
        followUps: [
          FollowUpSummary(id: "ready", title: "Pronto", origin: "Test", state: .ready)
        ],
        notificationCount: 0
      )
    )
    let explicitStore = RoutallyStore(
      snapshot: RoutallySnapshot(
        followUps: [
          FollowUpSummary(id: "ready", title: "Pronto", origin: "Test", state: .ready)
        ],
        notificationCount: 7,
        notifiedFollowUpIDs: ["ready"]
      )
    )

    #expect(mutedStore.snapshot.notificationCount == 0)
    #expect(explicitStore.snapshot.notificationCount == 7)
    #expect(mutedStore.triggerFallback() == ["ready"])
    #expect(explicitStore.triggerFallback().isEmpty)
  }

  @Test("Una consegna storica non sopprime un nuovo follow-up pronto")
  func historicalDeliveryDoesNotSuppressNewReadyFollowUp() {
    let store = RoutallyStore(
      snapshot: RoutallySnapshot(
        followUps: [
          FollowUpSummary(
            id: "completed",
            title: "Completato",
            origin: "Test",
            state: .completed
          ),
          FollowUpSummary(id: "new-ready", title: "Nuovo", origin: "Test", state: .ready),
        ],
        notificationCount: 1
      )
    )

    #expect(store.triggerFallback() == ["new-ready"])
  }

  @Test("La creazione espone salvataggio, errore e retry")
  func creationSubmissionStateIsRecoverable() {
    var state = CreationSubmissionState.idle

    state.begin()
    #expect(state.isSaving)
    state.fail()
    #expect(state.hasFailed)
    state.begin()
    #expect(state.isSaving)
  }

  @Test("Ogni routine creata può registrare il proprio progresso")
  func everyCreatedRoutineCanBeRecorded() {
    let store = RoutallyStore(snapshot: RoutallySnapshot())
    store.createRoutine(from: creationDraft(name: "Palestra"))
    let secondRoutineID = store.createRoutine(from: creationDraft(name: "Corsa"))

    #expect(secondRoutineID == "gym-2")
    #expect(store.recordRoutine(id: "gym-2"))
    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 0)
    #expect(store.snapshot.routines.first { $0.id == "gym-2" }?.progress == 1)
    #expect(store.snapshot.routines.first { $0.id == "gym-2-towel" }?.progress == 1)
    #expect(store.consequenceSummary?.sourceRoutineID == "gym-2")
  }

  @Test("Ogni routine usa la propria configurazione di follow-up")
  func eachRoutineUsesItsOwnFollowUpConfiguration() {
    let store = RoutallyStore(snapshot: RoutallySnapshot())
    var firstDraft = creationDraft(name: "Palestra")
    firstDraft.towelThreshold = 1
    firstDraft.followUpTitle = "Prepara l'asciugamano"
    firstDraft.usefulMoment = .home
    store.createRoutine(from: firstDraft)

    var secondDraft = creationDraft(name: "Corsa")
    secondDraft.towelThreshold = 1
    secondDraft.followUpTitle = "Prepara le scarpe"
    secondDraft.usefulMoment = .immediate
    store.createRoutine(from: secondDraft)

    #expect(store.recordRoutine(id: "gym"))
    #expect(store.recordRoutine(id: "gym-2"))
    #expect(
      store.snapshot.followUps.first { $0.id == "clean-gym-towel" }?.title
        == "Prepara l'asciugamano"
    )
    #expect(
      store.snapshot.followUps.first { $0.id == "clean-gym-towel" }?.state
        == .waitingForUsefulMoment
    )
    #expect(
      store.snapshot.followUps.first { $0.id == "clean-gym-2-towel" }?.title
        == "Prepara le scarpe"
    )
    #expect(
      store.snapshot.followUps.first { $0.id == "clean-gym-2-towel" }?.state == .ready
    )
    #expect(store.snapshot.notificationCount == 0)

    store.simulateNotificationDelivery(for: ["clean-gym-2-towel"])
    #expect(store.snapshot.notificationCount == 1)
  }

  @Test("Il momento immediato resta notificabile dal fallback Dev")
  func immediateUsefulMomentCanBeDeliveredByFallback() {
    let store = RoutallyStore(snapshot: RoutallySnapshot())
    var draft = creationDraft(name: "Corsa")
    draft.towelThreshold = 1
    draft.usefulMoment = .immediate
    store.createRoutine(from: draft)

    #expect(store.recordRoutine(id: "gym"))
    #expect(store.snapshot.followUps.first?.state == .ready)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.state == .followUpReady)
    #expect(store.snapshot.notificationCount == 0)

    let deliverableAtFallback = store.triggerFallback()
    #expect(deliverableAtFallback == ["clean-gym-towel"])
    store.simulateNotificationDelivery(for: deliverableAtFallback + deliverableAtFallback)
    #expect(store.snapshot.notificationCount == 1)
    #expect(store.triggerFallback().isEmpty)
  }

  @Test("La navigazione programmatica apre il dettaglio della routine")
  func programmaticRoutineNavigationSetsPath() {
    let router = AppRouter()

    router.showRoutine(id: "gym")

    #expect(router.selectedTab == .routines)
    #expect(router.selectedRoutineID == "gym")
    #expect(router.routinesPath == [.detail(id: "gym")])
  }

  @Test("Lista e stack mantengono sincronizzato il dettaglio selezionato")
  func routineNavigationRepresentationsStaySynchronized() {
    let router = AppRouter()

    router.selectRoutine(id: "gym")
    #expect(router.routinesPath == [.detail(id: "gym")])

    router.updateRoutinesPath([.detail(id: "studio")])
    #expect(router.selectedRoutineID == "studio")

    router.updateRoutinesPath([])
    #expect(router.selectedRoutineID == nil)
  }

  private func creationDraft(name: String) -> RoutineCreationDraft {
    RoutineCreationDraft(
      name: name,
      symbol: "figure.run",
      area: "wellbeing",
      weeklyTarget: 3,
      linksTowel: true,
      towelThreshold: 4,
      followUpTitle: "Prepara l'attrezzatura",
      usefulMoment: .home,
      fallbackMinutes: 1_200,
      startsNextCycle: true
    )
  }
}
