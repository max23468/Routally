import Foundation
import RoutallyData
import RoutallyDomain
import RoutallyFixtures
import Testing

@testable import RoutallyFeatures

@Suite("E06 Vertical Slice Integration")
@MainActor
struct E06VerticalSliceTests {
  private let sourceID = "00000000-0000-4000-8000-000000000601"
  private let towelID = "00000000-0000-4000-8000-000000000602"

  @Test("La fixture parte da 1 su 3 e 3 su 4 usando il registro reale")
  func canonicalFixtureLoadsFromDomainAndPersistence() async throws {
    let (_, model, _) = try makeModel()

    await model.load(locale: italian)

    #expect(model.snapshot.routines.first { $0.id == sourceID }?.progress == 1)
    #expect(model.snapshot.routines.first { $0.id == sourceID }?.target == 3)
    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 3)
    #expect(model.snapshot.routines.first { $0.id == towelID }?.target == 4)
  }

  @Test("Il quarto allenamento persiste una sola conseguenza collegata")
  func fourthWorkoutCreatesOnePersistentFollowUp() async throws {
    let (persistence, model, fixture) = try makeModel()
    await model.load(locale: italian)

    #expect(await model.recordRoutine(id: sourceID, locale: italian))

    #expect(model.snapshot.routines.first { $0.id == sourceID }?.progress == 2)
    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 4)
    #expect(model.snapshot.followUps.count == 1)
    #expect(model.consequenceSummary?.effects.count == 3)

    let reloaded = RoutallyFeatureModel(
      persistence: persistence,
      calendar: fixture.calendar,
      clock: .fixed(fixture.asOf)
    )
    await reloaded.load(locale: italian)
    #expect(reloaded.snapshot.routines.first { $0.id == sourceID }?.progress == 2)
    #expect(reloaded.snapshot.routines.first { $0.id == towelID }?.progress == 4)
    #expect(reloaded.snapshot.followUps.count == 1)
  }

  @Test("Arrivo a casa e fallback condividono la stessa identità di consegna")
  func locationAndFallbackDoNotDuplicateDelivery() async throws {
    let (_, model, _) = try makeModel()
    await model.load(locale: italian)
    #expect(await model.recordRoutine(id: sourceID, locale: italian))

    let deliveredAtHome = await model.simulateArrival(at: "home", locale: italian)
    let deliveredAtFallback = await model.triggerFallback(locale: italian)

    #expect(deliveredAtHome.count == 1)
    #expect(deliveredAtFallback.isEmpty)
    #expect(model.snapshot.notificationCount == 1)
    #expect(model.snapshot.followUps.first?.state == .ready)
  }

  @Test("L'arrivo a casa seleziona soltanto il follow-up geografico corretto")
  func locationArrivalSelectsOnlyMatchingFollowUps() async throws {
    let persistence = try SwiftDataRoutallyStore(configuration: .inMemory())
    let fixture = DemoFixtures.connectedGymCycleSeed()
    let model = RoutallyFeatureModel(
      persistence: persistence,
      calendar: fixture.calendar,
      clock: .fixed(fixture.asOf)
    )
    await model.load(locale: italian)

    var eveningDraft = creationDraft(name: "Palestra", followUpTitle: "Promemoria serale")
    eveningDraft.usefulMoment = .evening
    eveningDraft.towelThreshold = 1
    let eveningID = try #require(
      await model.createRoutine(from: eveningDraft, locale: italian)
    )

    var homeDraft = creationDraft(name: "Corsa", followUpTitle: "Promemoria a casa")
    homeDraft.usefulMoment = .home
    homeDraft.towelThreshold = 1
    let homeID = try #require(await model.createRoutine(from: homeDraft, locale: italian))

    #expect(await model.recordRoutine(id: eveningID, locale: italian))
    #expect(await model.recordRoutine(id: homeID, locale: italian))
    let deliveredAtHome = await model.simulateArrival(at: "home", locale: italian)

    #expect(deliveredAtHome.count == 1)
    #expect(
      model.snapshot.followUps.first { $0.title == "Promemoria a casa" }?.state == .ready
    )
    #expect(
      model.snapshot.followUps.first { $0.title == "Promemoria serale" }?.state
        == .waitingForUsefulMoment
    )

    let deliveredAtFallback = await model.triggerFallback(locale: italian)
    #expect(deliveredAtFallback.count == 1)
    #expect(model.snapshot.notificationCount == 2)
  }

  @Test("Completare il follow-up riavvia il ciclo a zero")
  func completingFollowUpStartsNextCycle() async throws {
    let (_, model, _) = try makeModel()
    await model.load(locale: italian)
    #expect(await model.recordRoutine(id: sourceID, locale: italian))
    await model.simulateArrival(at: "home", locale: italian)
    let followUpID = try #require(model.snapshot.followUps.first?.id)

    #expect(await model.completeFollowUp(id: followUpID, locale: italian))

    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 0)
    #expect(model.snapshot.followUps.first?.state == .completed)
  }

  @Test("Escludere il collegamento crea una revisione e preserva la sorgente")
  func excludingLinkedEffectCreatesRevision() async throws {
    let (persistence, model, fixture) = try makeModel()
    await model.load(locale: italian)
    #expect(await model.recordRoutine(id: sourceID, locale: italian))
    let effectID = try #require(
      model.consequenceSummary?.effects.first { $0.id.hasPrefix("link-") }?.id
    )

    #expect(await model.excludeEffect(id: effectID, locale: italian))

    #expect(model.snapshot.routines.first { $0.id == sourceID }?.progress == 2)
    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 3)
    #expect(model.snapshot.followUps.isEmpty)
    let stored = try await persistence.load(asOf: fixture.asOf, calendar: fixture.calendar)
    #expect(stored.ledger.revisions.count == 1)
  }

  @Test("Escludere solo il follow-up conserva il progresso del ciclo")
  func excludingOnlyFollowUpPreservesCycleProgress() async throws {
    let (_, model, _) = try makeModel()
    await model.load(locale: italian)
    #expect(await model.recordRoutine(id: sourceID, locale: italian))
    let effectID = try #require(
      model.consequenceSummary?.effects.first { $0.id.hasPrefix("follow-up-") }?.id
    )

    #expect(await model.excludeEffect(id: effectID, locale: italian))

    #expect(model.snapshot.routines.first { $0.id == sourceID }?.progress == 2)
    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 4)
    #expect(model.snapshot.followUps.isEmpty)
  }

  @Test("Un follow-up corretto e ricreato può essere consegnato di nuovo")
  func correctedFollowUpRegainsDeliveryEligibility() async throws {
    let (_, model, _) = try makeModel()
    await model.load(locale: italian)
    #expect(await model.recordRoutine(id: sourceID, locale: italian))
    #expect(await model.simulateArrival(at: "home", locale: italian).count == 1)
    let effectID = try #require(
      model.consequenceSummary?.effects.first { $0.id.hasPrefix("follow-up-") }?.id
    )

    #expect(await model.excludeEffect(id: effectID, locale: italian))
    #expect(model.snapshot.followUps.isEmpty)
    #expect(model.snapshot.notificationCount == 0)
    model.clearConsequenceSummary()

    #expect(await model.recordRoutine(id: sourceID, locale: italian))
    #expect(model.snapshot.followUps.count == 1)
    #expect(await model.simulateArrival(at: "home", locale: italian).count == 1)
    #expect(model.snapshot.notificationCount == 1)
  }

  @Test("Annullare registra un tombstone e ripristina atomicamente la fixture")
  func undoCreatesTombstoneAndRestoresState() async throws {
    let (persistence, model, fixture) = try makeModel()
    await model.load(locale: italian)
    #expect(await model.recordRoutine(id: sourceID, locale: italian))

    #expect(await model.undoLastRecording(locale: italian))

    #expect(model.snapshot.routines.first { $0.id == sourceID }?.progress == 1)
    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 3)
    #expect(model.snapshot.followUps.isEmpty)
    #expect(model.consequenceSummary == nil)
    let stored = try await persistence.load(asOf: fixture.asOf, calendar: fixture.calendar)
    #expect(stored.ledger.tombstones.count == 1)
  }

  @Test("Annullare dopo Escludi non applica due volte la correzione")
  func undoAfterExclusionRestoresTheCanonicalFixture() async throws {
    let (_, model, _) = try makeModel()
    await model.load(locale: italian)
    #expect(await model.recordRoutine(id: sourceID, locale: italian))
    let effectID = try #require(
      model.consequenceSummary?.effects.first { $0.id.hasPrefix("link-") }?.id
    )
    #expect(await model.excludeEffect(id: effectID, locale: italian))

    #expect(await model.undoLastRecording(locale: italian))

    #expect(model.snapshot.routines.first { $0.id == sourceID }?.progress == 1)
    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 3)
    #expect(model.snapshot.followUps.isEmpty)
  }

  @Test("Le azioni offline restano locali e vengono marcate pendenti")
  func offlineActionsRemainAvailableAndPending() async throws {
    let (_, model, _) = try makeModel(isOffline: true)
    await model.load(locale: italian)

    #expect(await model.recordRoutine(id: sourceID, locale: italian))

    #expect(model.snapshot.routines.first { $0.id == sourceID }?.progress == 2)
    #expect(model.snapshot.isOffline)
    #expect(model.snapshot.hasPendingChanges)

    await model.simulateArrival(at: "home", locale: italian)
    let followUpID = try #require(model.snapshot.followUps.first?.id)
    #expect(await model.completeFollowUp(id: followUpID, locale: italian))
    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 0)
    #expect(model.snapshot.hasPendingChanges)
  }

  @Test("Due tocchi concorrenti producono un solo evento")
  func concurrentRecordingsAreCoalescedAtTheFeatureBoundary() async throws {
    let (_, model, _) = try makeModel()
    await model.load(locale: italian)

    async let first = model.recordRoutine(id: sourceID, locale: italian)
    async let second = model.recordRoutine(id: sourceID, locale: italian)
    let results = await [first, second]

    #expect(results.filter { $0 }.count == 1)
    #expect(model.snapshot.routines.first { $0.id == sourceID }?.progress == 2)
    #expect(model.snapshot.routines.first { $0.id == towelID }?.progress == 4)
  }

  @Test("La creazione salva configurazione, aspetto, collegamento e fallback locale")
  func creationPersistsCompleteConfiguration() async throws {
    let persistence = try SwiftDataRoutallyStore(configuration: .inMemory())
    let fixture = DemoFixtures.connectedGymCycleSeed()
    let model = RoutallyFeatureModel(
      persistence: persistence,
      calendar: fixture.calendar,
      clock: .fixed(fixture.asOf)
    )
    await model.load(locale: italian)
    let draft = RoutineCreationDraft(
      name: " Corsa ",
      symbol: "figure.run",
      area: "wellbeing",
      weeklyTarget: 5,
      linksTowel: true,
      towelThreshold: 6,
      followUpTitle: " Prepara le scarpe ",
      usefulMoment: .home,
      fallbackMinutes: 20 * 60,
      startsNextCycle: true
    )

    let createdID = try #require(await model.createRoutine(from: draft, locale: italian))
    let stored = try await persistence.load(asOf: fixture.asOf, calendar: fixture.calendar)
    let source = try #require(
      stored.catalog.routines.first { $0.id.rawValue.uuidString == createdID }
    )
    let link = try #require(stored.catalog.links.first)
    let cycle = try #require(stored.catalog.cycles.first)

    #expect(source.name == "Corsa")
    #expect(source.appearance.symbolName == "figure.run")
    #expect(source.appearance.areaIdentifier == "wellbeing")
    #expect(link.sourceRoutineID == source.id)
    #expect(cycle.routineID == link.targetRoutineID)
    #expect(cycle.threshold == .progress(6))
    #expect(
      cycle.followUp.usefulMoment
        == .geographic(locationID: "home", fallbackTime: LocalTime(hour: 20, minute: 0))
    )
  }

  @Test("Un errore di lettura è recuperabile con un nuovo caricamento")
  func recoverableLoadFailureCanBeRetried() async throws {
    let base = try SwiftDataRoutallyStore(configuration: .inMemory())
    let persistence = PlannedFailureStore(base: base, loadFailures: 1)
    let fixture = DemoFixtures.connectedGymCycleSeed()
    let model = RoutallyFeatureModel(
      persistence: persistence,
      calendar: fixture.calendar,
      clock: .fixed(fixture.asOf)
    )

    await model.load(locale: italian)
    #expect(model.snapshot.hasRecoverableEventError)

    await model.retryRecoverableEvent(locale: italian)
    #expect(!model.snapshot.hasRecoverableEventError)
    #expect(model.snapshot.routines.isEmpty)
  }

  @Test("Il retry dopo un errore di salvataggio applica lo stesso draft")
  func recoverableCommitFailurePreservesTheDraftForRetry() async throws {
    let base = try SwiftDataRoutallyStore(configuration: .inMemory())
    let persistence = PlannedFailureStore(base: base, commitFailures: 1)
    let fixture = DemoFixtures.connectedGymCycleSeed()
    let model = RoutallyFeatureModel(
      persistence: persistence,
      calendar: fixture.calendar,
      clock: .fixed(fixture.asOf)
    )
    await model.load(locale: italian)
    let draft = creationDraft(name: "Corsa", followUpTitle: "Prepara le scarpe")

    #expect(await model.createRoutine(from: draft, locale: italian) == nil)
    #expect(model.snapshot.hasRecoverableEventError)

    let createdID = try #require(await model.createRoutine(from: draft, locale: italian))
    #expect(!model.snapshot.hasRecoverableEventError)
    #expect(model.snapshot.routines.first { $0.id == createdID }?.name == "Corsa")
    #expect(model.snapshot.followUps.isEmpty)
  }

  @Test("Creazione e conseguenze rispettano la locale richiesta")
  func creationAndConsequencesUseRequestedLocale() async throws {
    let persistence = try SwiftDataRoutallyStore(configuration: .inMemory())
    let fixture = DemoFixtures.connectedGymCycleSeed()
    let model = RoutallyFeatureModel(
      persistence: persistence,
      calendar: fixture.calendar,
      clock: .fixed(fixture.asOf)
    )
    let english = Locale(identifier: "en")
    await model.load(locale: english)
    var draft = creationDraft(name: "Gym", followUpTitle: "Prepare the equipment")
    draft.towelThreshold = 1

    let createdID = try #require(await model.createRoutine(from: draft, locale: english))
    #expect(await model.recordRoutine(id: createdID, locale: english))

    #expect(model.snapshot.routines.contains { $0.name == "Gym towel" })
    #expect(model.consequenceSummary?.title == "Workout logged")
    #expect(model.snapshot.followUps.first?.title == "Prepare the equipment")
  }

  private var italian: Locale {
    Locale(identifier: "it")
  }

  private func makeModel(
    isOffline: Bool = false
  ) throws -> (SwiftDataRoutallyStore, RoutallyFeatureModel, DemoDomainSeed) {
    let fixture = DemoFixtures.connectedGymCycleSeed()
    let persistence = try SwiftDataRoutallyStore(configuration: .inMemory())
    let model = RoutallyFeatureModel(
      persistence: persistence,
      seed: RoutallyFeatureSeed(
        catalog: fixture.catalog,
        ledger: fixture.ledger,
        asOf: fixture.asOf
      ),
      calendar: fixture.calendar,
      clock: .fixed(fixture.asOf),
      isOffline: isOffline
    )
    return (persistence, model, fixture)
  }

  private func creationDraft(
    name: String,
    followUpTitle: String
  ) -> RoutineCreationDraft {
    RoutineCreationDraft(
      name: name,
      symbol: "figure.run",
      area: "wellbeing",
      weeklyTarget: 3,
      linksTowel: true,
      towelThreshold: 4,
      followUpTitle: followUpTitle,
      usefulMoment: .home,
      fallbackMinutes: 20 * 60,
      startsNextCycle: true
    )
  }
}

private enum PlannedFailure: Error {
  case requested
}

private actor PlannedFailureStore: RoutallyData.RoutallyStore {
  private let base: any RoutallyData.RoutallyStore
  private var remainingLoadFailures: Int
  private var remainingCommitFailures: Int

  init(
    base: any RoutallyData.RoutallyStore,
    loadFailures: Int = 0,
    commitFailures: Int = 0
  ) {
    self.base = base
    remainingLoadFailures = loadFailures
    remainingCommitFailures = commitFailures
  }

  func load(
    asOf: Date,
    calendar: DomainCalendar
  ) async throws -> RoutallyStoreSnapshot {
    if remainingLoadFailures > 0 {
      remainingLoadFailures -= 1
      throw PlannedFailure.requested
    }
    return try await base.load(asOf: asOf, calendar: calendar)
  }

  func commit(
    _ change: RoutallyStoreChange,
    asOf: Date,
    calendar: DomainCalendar
  ) async throws -> RoutallyStoreSnapshot {
    if remainingCommitFailures > 0 {
      remainingCommitFailures -= 1
      throw PlannedFailure.requested
    }
    return try await base.commit(change, asOf: asOf, calendar: calendar)
  }
}
