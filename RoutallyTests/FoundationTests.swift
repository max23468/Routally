import RoutallyDomain
import RoutallyFeatures
import RoutallyFixtures
import Testing

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
          .freeLimitReached,
          .plusUser,
          .largeHistory,
        ]))
  }

  @Test("Il quarto allenamento crea una sola conseguenza collegata")
  func fourthWorkoutCreatesOneFollowUp() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))

    #expect(store.recordWorkout())
    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 2)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 4)
    #expect(store.snapshot.followUps.count == 1)
    #expect(store.consequenceSummary?.effects.count == 3)
  }

  @Test("Arrivo e fallback non duplicano il follow-up")
  func arrivalAndFallbackAreIdempotent() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordWorkout()

    store.revealFollowUpAtHome()
    store.triggerFallback()

    #expect(store.snapshot.followUps.count == 1)
    #expect(store.snapshot.followUps.first?.state == .ready)
    #expect(store.snapshot.notificationCount == 1)
  }

  @Test("Escludere l'asciugamano preserva l'evento sorgente")
  func excludingTowelPreservesWorkout() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordWorkout()

    store.excludeEffect(id: "gym-towel")

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 2)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 3)
    #expect(store.snapshot.followUps.isEmpty)
  }

  @Test("Escludere solo il follow-up preserva il ciclo dell'asciugamano")
  func excludingFollowUpPreservesTowelCycle() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordWorkout()

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

  @Test("Annullare ripristina atomicamente lo stato della fixture")
  func undoRestoresFixtureState() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordWorkout()

    store.undoWorkout()

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 1)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 3)
    #expect(store.snapshot.followUps.isEmpty)
    #expect(store.consequenceSummary == nil)
  }

  @Test("Annullare dopo Escludi non sottrae due volte la conseguenza")
  func undoAfterExclusionDoesNotApplyEffectTwice() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordWorkout()
    store.excludeEffect(id: "gym-towel")

    store.undoWorkout()

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 1)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 3)
    #expect(store.snapshot.followUps.isEmpty)
  }

  @Test("Una nuova registrazione dopo Escludi usa il progresso corrente")
  func recordAfterExclusionUsesCurrentProgress() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordWorkout()
    store.excludeEffect(id: "gym-towel")
    store.clearConsequenceSummary()

    #expect(store.recordWorkout())

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 3)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 4)
    #expect(store.consequenceSummary?.effects.first?.title.contains("3/3") == true)
  }

  @Test("Completare il follow-up riavvia il ciclo anche offline")
  func completingFollowUpResetsCycleOffline() {
    let store = RoutallyStore(
      snapshot: DemoFixtures.snapshot(for: .offlineWithPendingChanges)
    )
    store.recordWorkout()
    store.revealFollowUpAtHome()

    store.completeFollowUp()

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
    #expect(store.createdDraft?.followUpTitle == "Prepara le scarpe")
    #expect(store.createdDraft?.startsNextCycle == false)
  }

  @Test("La navigazione programmatica apre il dettaglio della routine")
  func programmaticRoutineNavigationSetsPath() {
    let router = AppRouter()

    router.showRoutine(id: "gym")

    #expect(router.selectedTab == .routines)
    #expect(router.selectedRoutineID == "gym")
    #expect(router.routinesPath == [.detail(id: "gym")])
  }
}
