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

    store.excludeTowelEffect()

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 2)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 3)
    #expect(store.snapshot.followUps.isEmpty)
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
    store.excludeTowelEffect()

    store.undoWorkout()

    #expect(store.snapshot.routines.first { $0.id == "gym" }?.progress == 1)
    #expect(store.snapshot.routines.first { $0.id == "gym-towel" }?.progress == 3)
    #expect(store.snapshot.followUps.isEmpty)
  }

  @Test("Una nuova registrazione dopo Escludi usa il progresso corrente")
  func recordAfterExclusionUsesCurrentProgress() {
    let store = RoutallyStore(snapshot: DemoFixtures.snapshot(for: .thresholdReached))
    store.recordWorkout()
    store.excludeTowelEffect()
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
}
