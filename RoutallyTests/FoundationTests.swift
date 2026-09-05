import Foundation
import RoutallyDomain
import RoutallyFixtures
import Testing

@testable import RoutallyFeatures

@Suite("Foundation")
@MainActor
struct FoundationTests {
  @Test("La configurazione condivisa permette la selezione italiana e inglese")
  func hostSupportsBothProductLanguages() throws {
    // I test sono hostless: Bundle.main è il runner Apple, non il bundle configurato.
    let configuredBundle = try #require(
      Bundle.allBundles.first { $0.bundleURL.pathExtension == "xctest" }
    )
    for language in ["it", "en"] {
      let selected = Bundle.preferredLocalizations(
        from: configuredBundle.localizations, forPreferences: [language]
      )
      #expect(selected.first == language)
    }
  }

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

  @Test("Lo studio visuale richiede un opt-in e non ricade sui dati locali per argomenti errati")
  func designReviewRequiresExplicitLaunchArgument() {
    #expect(DesignReviewScenario.requested(arguments: ["creation-review"]) == nil)
    #expect(DesignReviewScenario.requested(arguments: ["-launchMode", "demo"]) == nil)
    #expect(
      DesignReviewScenario.requested(arguments: ["-designReview", "creation-error"])
        == .creationError
    )
    #expect(DesignReviewScenario.requested(arguments: ["-designReview"]) == .gallery)
    #expect(
      DesignReviewScenario.requested(arguments: ["-designReview", "unknown-scenario"]) == .gallery
    )
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

  @Test("La fixture della vertical slice usa il dominio solo nello scenario canonico")
  func verticalSliceFixtureRequiresCanonicalLaunchArguments() {
    #expect(
      DemoFixtures.verticalSliceSeed(
        arguments: ["-launchMode", "demo", "-demoScenario", "connectedGymCycle"]
      ) != nil
    )
    #expect(
      DemoFixtures.verticalSliceSeed(
        arguments: ["-launchMode", "demo", "-demoScenario", "largeHistory"]
      ) == nil
    )
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

  @Test("La navigazione programmatica apre il dettaglio della routine")
  func programmaticRoutineNavigationSetsPath() {
    let router = AppRouter()

    router.showRoutine(id: "routine-id")

    #expect(router.selectedTab == .routines)
    #expect(router.selectedRoutineID == "routine-id")
    #expect(router.routinesPath == [.detail(id: "routine-id")])
  }

  @Test("Lista e stack mantengono sincronizzato il dettaglio selezionato")
  func routineNavigationRepresentationsStaySynchronized() {
    let router = AppRouter()

    router.selectRoutine(id: "first")
    #expect(router.routinesPath == [.detail(id: "first")])

    router.updateRoutinesPath([.detail(id: "second")])
    #expect(router.selectedRoutineID == "second")

    router.updateRoutinesPath([])
    #expect(router.selectedRoutineID == nil)
  }
}
