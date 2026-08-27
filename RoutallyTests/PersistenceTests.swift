import Foundation
import RoutallyDomain
import SwiftData
import Testing

@testable import RoutallyData

@Suite("Local Persistence")
struct PersistenceTests {
  private let calendar = DomainCalendar(timeZoneIdentifier: "UTC")

  @Test("Lo store registra offline e recupera dominio e stato dopo la riapertura")
  func localStorePersistsAndRecovers() async throws {
    let temporaryStore = try TemporaryStore()
    let fixture = SmallPersistenceFixture.make()
    var store: SwiftDataRoutallyStore? = try SwiftDataRoutallyStore(
      configuration: .local(url: temporaryStore.url)
    )

    _ = try await store?.commit(
      RoutallyStoreChange(catalog: fixture.catalog),
      asOf: fixture.asOf,
      calendar: calendar
    )
    let committed = try await store?.commit(
      RoutallyStoreChange(events: [fixture.event]),
      asOf: fixture.asOf,
      calendar: calendar
    )
    #expect(committed?.state.processedEventIDs == [fixture.event.id])
    #expect(committed?.affectedRoutineIDs == [fixture.sourceRoutineID, fixture.targetRoutineID])

    store = nil
    store = try SwiftDataRoutallyStore(configuration: .local(url: temporaryStore.url))
    let recovered = try await store?.load(asOf: fixture.asOf, calendar: calendar)

    #expect(recovered?.catalog == fixture.catalog)
    #expect(recovered?.ledger == DomainLedger(events: [fixture.event]))
    #expect(recovered?.state == committed?.state)
    store = nil
    try temporaryStore.remove()
    #expect(!FileManager.default.fileExists(atPath: temporaryStore.directory.path()))
  }

  @Test("Retry e duplicati esatti vengono persistiti una sola volta")
  func exactDuplicatesAreStoredOnce() async throws {
    let fixture = SmallPersistenceFixture.make()
    let store = try SwiftDataRoutallyStore(configuration: .inMemory())
    let duplicateChange = RoutallyStoreChange(
      catalog: fixture.catalog,
      events: [fixture.event, fixture.event]
    )

    _ = try await store.commit(duplicateChange, asOf: fixture.asOf, calendar: calendar)
    let retried = try await store.commit(
      RoutallyStoreChange(events: [fixture.event]),
      asOf: fixture.asOf,
      calendar: calendar
    )

    #expect(retried.ledger.events == [fixture.event])
    #expect(retried.state.processedEventIDs == [fixture.event.id])
    #expect(retried.catalog.routines.count == 2)
    #expect(retried.catalog.links.count == 1)
    #expect(retried.catalog.cycles.count == 1)
  }

  @Test("Duplicati già presenti nello store V1 vengono riconciliati al caricamento")
  @MainActor
  func persistedExactDuplicatesAreReconciled() async throws {
    let temporaryStore = try TemporaryStore()
    let fixture = SmallPersistenceFixture.make()
    try seedV1Store(
      at: temporaryStore.url,
      catalog: fixture.catalog,
      events: [
        SeededEvent(recordID: fixture.event.id.rawValue, value: fixture.event),
        SeededEvent(recordID: fixture.event.id.rawValue, value: fixture.event),
      ]
    )
    let store = try SwiftDataRoutallyStore(configuration: .local(url: temporaryStore.url))

    let loaded = try await store.load(asOf: fixture.asOf, calendar: calendar)

    #expect(loaded.ledger.events == [fixture.event])
    #expect(loaded.state.processedEventIDs == [fixture.event.id])
  }

  @Test("Un record con UUID scalare incoerente viene segnalato come corrotto")
  @MainActor
  func scalarPayloadMismatchIsRejected() async throws {
    let temporaryStore = try TemporaryStore()
    let fixture = SmallPersistenceFixture.make()
    let corruptedID = uuid("00000000-0000-4000-8600-000000000001")
    try seedV1Store(
      at: temporaryStore.url,
      catalog: fixture.catalog,
      events: [SeededEvent(recordID: corruptedID, value: fixture.event)]
    )
    let store = try SwiftDataRoutallyStore(configuration: .local(url: temporaryStore.url))

    await #expect(
      throws: RoutallyStoreError.corruptedRecord(kind: "event", id: corruptedID)
    ) {
      try await store.load(asOf: fixture.asOf, calendar: calendar)
    }
  }

  @Test("Una versione payload futura non viene decodificata implicitamente")
  @MainActor
  func unsupportedPayloadVersionIsRejected() async throws {
    let temporaryStore = try TemporaryStore()
    let fixture = SmallPersistenceFixture.make()
    try seedV1Store(
      at: temporaryStore.url,
      catalog: fixture.catalog,
      events: [
        SeededEvent(
          recordID: fixture.event.id.rawValue,
          payloadVersion: 3,
          value: fixture.event
        )
      ]
    )
    let store = try SwiftDataRoutallyStore(configuration: .local(url: temporaryStore.url))

    await #expect(
      throws: RoutallyStoreError.unsupportedPayloadVersion(
        kind: "event",
        id: fixture.event.id.rawValue,
        version: 3
      )
    ) {
      try await store.load(asOf: fixture.asOf, calendar: calendar)
    }
  }

  @Test("Il payload V1 incompatibile viene rifiutato prima della decodifica")
  @MainActor
  func incompatibleRoutinePayloadIsRejected() async throws {
    let temporaryStore = try TemporaryStore()
    let fixture = SmallPersistenceFixture.make()
    let routine = try #require(fixture.catalog.routines.first)
    try seedV1Store(
      at: temporaryStore.url,
      catalog: DomainCatalog(routines: [routine]),
      routinePayloadVersion: 1,
      events: []
    )
    let store = try SwiftDataRoutallyStore(configuration: .local(url: temporaryStore.url))

    await #expect(
      throws: RoutallyStoreError.unsupportedPayloadVersion(
        kind: "routine",
        id: routine.id.rawValue,
        version: 1
      )
    ) {
      try await store.load(asOf: fixture.asOf, calendar: calendar)
    }
  }

  @Test("Varianti, revisioni e tombstone convergono indipendentemente dall’ordine")
  func deliveryOrderConverges() async throws {
    let fixture = SmallPersistenceFixture.make()
    let imported = RoutineEvent(
      id: fixture.event.id,
      routineID: fixture.event.routineID,
      kind: .recorded(.init(amount: 2)),
      occurredAt: fixture.event.occurredAt,
      originalLocalDay: fixture.event.originalLocalDay,
      origin: .widget,
      logicalClock: fixture.event.logicalClock + 1,
      recordedAt: fixture.event.recordedAt.addingTimeInterval(10)
    )
    let revision = EventRevision(
      id: EventRevisionID(rawValue: uuid("00000000-0000-4000-8300-000000000001")),
      eventID: fixture.event.id,
      patch: RoutineEventPatch(note: .set("corretto")),
      logicalClock: imported.logicalClock + 1,
      authoredAt: imported.recordedAt.addingTimeInterval(10)
    )
    let obsoleteTombstone = EventTombstone(
      id: TombstoneID(rawValue: uuid("00000000-0000-4000-8400-000000000001")),
      eventID: fixture.event.id,
      logicalClock: fixture.event.logicalClock,
      deletedAt: revision.authoredAt.addingTimeInterval(10)
    )
    let forwardStore = try SwiftDataRoutallyStore(configuration: .inMemory())
    let reverseStore = try SwiftDataRoutallyStore(configuration: .inMemory())

    let forward = try await forwardStore.commit(
      RoutallyStoreChange(
        catalog: fixture.catalog,
        events: [fixture.event, imported, fixture.event],
        revisions: [revision, revision],
        tombstones: [obsoleteTombstone, obsoleteTombstone]
      ),
      asOf: fixture.asOf,
      calendar: calendar
    )
    let reverse = try await reverseStore.commit(
      RoutallyStoreChange(
        catalog: fixture.catalog,
        events: [fixture.event, imported, fixture.event].reversed(),
        revisions: [revision, revision].reversed(),
        tombstones: [obsoleteTombstone, obsoleteTombstone].reversed()
      ),
      asOf: fixture.asOf,
      calendar: calendar
    )

    #expect(forward.ledger == reverse.ledger)
    #expect(forward.state == reverse.state)
    let resolved = try #require(forward.ledger.resolvedEvents().first)
    #expect(resolved.kind == .recorded(.init(amount: 2)))
    #expect(resolved.note == "corretto")
    #expect(forward.ledger.events.count == 2)
    #expect(forward.ledger.revisions.count == 1)
    #expect(forward.ledger.tombstones.count == 1)
  }

  @Test("Un ricalcolo non valido non persiste alcuna parte della modifica")
  func invalidReductionRollsBackWholeChange() async throws {
    let fixture = SmallPersistenceFixture.make()
    let unknownRoutineID = RoutineID(
      rawValue: uuid("00000000-0000-4000-8500-000000000001")
    )
    let invalidEvent = RoutineEvent(
      id: RoutineEventID(rawValue: uuid("00000000-0000-4000-8500-000000000002")),
      routineID: unknownRoutineID,
      kind: .recorded(.count),
      occurredAt: fixture.event.occurredAt,
      originalLocalDay: fixture.event.originalLocalDay,
      logicalClock: 1,
      recordedAt: fixture.event.recordedAt
    )
    let store = try SwiftDataRoutallyStore(configuration: .inMemory())

    await #expect(throws: DomainReductionError.unknownRoutine(unknownRoutineID)) {
      try await store.commit(
        RoutallyStoreChange(catalog: fixture.catalog, events: [invalidEvent]),
        asOf: fixture.asOf,
        calendar: calendar
      )
    }

    let unchanged = try await store.load(asOf: fixture.asOf, calendar: calendar)
    #expect(unchanged.catalog.routines.isEmpty)
    #expect(unchanged.ledger == DomainLedger())
  }

  @Test("La sostituzione del catalogo segnala anche le routine eliminate")
  func catalogReplacementIsAtomic() async throws {
    let fixture = SmallPersistenceFixture.make()
    let store = try SwiftDataRoutallyStore(configuration: .inMemory())
    _ = try await store.commit(
      RoutallyStoreChange(catalog: fixture.catalog),
      asOf: fixture.asOf,
      calendar: calendar
    )
    let reducedCatalog = DomainCatalog(
      routines: [try #require(fixture.catalog.routines.first)]
    )

    let replaced = try await store.commit(
      RoutallyStoreChange(catalog: reducedCatalog),
      asOf: fixture.asOf,
      calendar: calendar
    )

    #expect(replaced.catalog == reducedCatalog)
    #expect(replaced.catalog.links.isEmpty)
    #expect(replaced.catalog.cycles.isEmpty)
    #expect(
      replaced.affectedRoutineIDs == [fixture.sourceRoutineID, fixture.targetRoutineID]
    )
  }

  @Test("Schema V1, payload V2 e identificativi Apple restano iniettati")
  func schemaAndEnvironmentAreStable() throws {
    let provisional = RoutallyStoreConfiguration.privateCloud(
      appGroupIdentifier: "group.com.temisfera.routally.dev.provisional",
      cloudKitContainerIdentifier: "iCloud.com.temisfera.routally.dev.provisional"
    )
    let definitive = RoutallyStoreConfiguration.privateCloud(
      appGroupIdentifier: "group.com.temisfera.routally",
      cloudKitContainerIdentifier: "iCloud.com.temisfera.routally"
    )

    #expect(RoutallySchemaV1.versionIdentifier == Schema.Version(1, 0, 0))
    #expect(RoutallySchemaV1.payloadVersion == 2)
    #expect(RoutallySchemaV1.localStoreFilename == "Routally-v2.store")
    #expect(RoutallyMigrationPlan.schemas.count == 1)
    #expect(RoutallyMigrationPlan.stages.isEmpty)
    #expect(provisional.appGroupIdentifier == "group.com.temisfera.routally.dev.provisional")
    #expect(
      definitive.cloudKitContainerIdentifier == "iCloud.com.temisfera.routally"
    )
    try provisional.validate()
    try definitive.validate()
  }

  @Test("Una cancellazione precedente al commit non lascia scritture parziali")
  func cancelledCommitDoesNotWrite() async throws {
    let fixture = ReferenceDomainFixture.make()
    let store = try SwiftDataRoutallyStore(configuration: .inMemory())
    let gate = SuspensionGate()
    let task = Task {
      await gate.wait()
      return try await store.commit(
        RoutallyStoreChange(
          catalog: fixture.catalog,
          events: fixture.ledger.events,
          revisions: fixture.ledger.revisions,
          tombstones: fixture.ledger.tombstones
        ),
        asOf: fixture.asOf,
        calendar: fixture.calendar
      )
    }
    task.cancel()
    await gate.open()

    await #expect(throws: CancellationError.self) {
      try await task.value
    }
    let unchanged = try await store.load(asOf: fixture.asOf, calendar: fixture.calendar)
    #expect(unchanged.catalog.routines.isEmpty)
    #expect(unchanged.ledger == DomainLedger())
  }

  @Test("Il dataset canonico viene persistito senza perdere la convergenza")
  func referenceDatasetPersistsCanonicalVolumes() async throws {
    let fixture = ReferenceDomainFixture.make()
    let store = try SwiftDataRoutallyStore(configuration: .inMemory())

    let snapshot = try await store.commit(
      RoutallyStoreChange(
        catalog: fixture.catalog,
        events: fixture.ledger.events,
        revisions: fixture.ledger.revisions,
        tombstones: fixture.ledger.tombstones
      ),
      asOf: fixture.asOf,
      calendar: fixture.calendar
    )

    #expect(snapshot.state.processedEventIDs.count == 9_900)
    #expect(snapshot.state.followUps.count == 500)
    #expect(snapshot.catalog.routines.count == 250)
    #expect(snapshot.catalog.links.count == 100)
    #expect(snapshot.catalog.cycles.count == 500)
    #expect(snapshot.ledger.events.count == 10_000)
    #expect(snapshot.ledger.revisions.count == 500)
    #expect(snapshot.ledger.tombstones.count == 100)
  }
}

private struct SmallPersistenceFixture: Sendable {
  let catalog: DomainCatalog
  let event: RoutineEvent
  let sourceRoutineID: RoutineID
  let targetRoutineID: RoutineID
  let asOf: Date

  static func make() -> Self {
    let calendar = DomainCalendar(timeZoneIdentifier: "UTC")
    let createdAt = calendar.foundationCalendar.date(
      from: DateComponents(year: 2026, month: 1, day: 1, hour: 12)
    )!
    let eventDate = createdAt.addingTimeInterval(86_400)
    let asOf = eventDate.addingTimeInterval(86_400)
    let sourceID = RoutineID(
      rawValue: uuid("00000000-0000-4000-8000-000000000001")
    )
    let targetID = RoutineID(
      rawValue: uuid("00000000-0000-4000-8000-000000000002")
    )
    let source = RoutineDefinition(
      id: sourceID,
      name: "Palestra",
      measurement: .count,
      frequency: .withinPeriod(
        PeriodicGoalRule(target: 3, period: .week)
      ),
      createdAt: createdAt
    )
    let target = RoutineDefinition(
      id: targetID,
      name: "Asciugamano",
      measurement: .count,
      frequency: .afterLast(.init(value: 7, unit: .day)),
      createdAt: createdAt
    )
    let link = RoutineLink(
      id: RoutineLinkID(rawValue: uuid("00000000-0000-4000-8100-000000000001")),
      sourceRoutineID: sourceID,
      targetRoutineID: targetID,
      increment: 1,
      activeFrom: createdAt
    )
    let cycle = UsageCycleDefinition(
      id: UsageCycleID(rawValue: uuid("00000000-0000-4000-8200-000000000001")),
      routineID: targetID,
      threshold: .progress(4),
      followUp: FollowUpPolicy(title: "Prepara un asciugamano", usefulMoment: .immediate),
      anchorDate: createdAt
    )
    let event = RoutineEvent(
      id: RoutineEventID(rawValue: uuid("00000000-0000-4000-8200-000000000002")),
      routineID: sourceID,
      kind: .recorded(.count),
      occurredAt: eventDate,
      originalLocalDay: LocalDay(date: eventDate, timeZoneIdentifier: "UTC"),
      logicalClock: 1,
      recordedAt: eventDate
    )
    return Self(
      catalog: DomainCatalog(
        routines: [source, target],
        links: [link],
        cycles: [cycle]
      ),
      event: event,
      sourceRoutineID: sourceID,
      targetRoutineID: targetID,
      asOf: asOf
    )
  }
}

private final class TemporaryStore {
  let directory: URL
  let url: URL

  init() throws {
    directory = FileManager.default.temporaryDirectory
      .appending(path: "Routally-Persistence-\(UUID().uuidString)", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )
    url = directory.appending(path: RoutallySchemaV1.localStoreFilename)
  }

  func remove() throws {
    guard FileManager.default.fileExists(atPath: directory.path()) else { return }
    try FileManager.default.removeItem(at: directory)
  }

  deinit {
    try? remove()
  }
}

private actor SuspensionGate {
  private var isOpen = false
  private var waiters: [CheckedContinuation<Void, Never>] = []

  func wait() async {
    guard !isOpen else { return }
    await withCheckedContinuation { continuation in
      waiters.append(continuation)
    }
  }

  func open() {
    isOpen = true
    for waiter in waiters {
      waiter.resume()
    }
    waiters.removeAll()
  }
}

private struct SeededEvent {
  let recordID: UUID
  var payloadVersion = RoutallySchemaV1.payloadVersion
  let value: RoutineEvent
}

@MainActor
private func seedV1Store(
  at url: URL,
  catalog: DomainCatalog,
  routinePayloadVersion: Int = RoutallySchemaV1.payloadVersion,
  events: [SeededEvent]
) throws {
  let schema = Schema(versionedSchema: RoutallySchemaV1.self)
  let configuration = ModelConfiguration(
    "Routally",
    schema: schema,
    url: url,
    cloudKitDatabase: .none
  )
  let container = try ModelContainer(for: schema, configurations: [configuration])
  let context = ModelContext(container)
  let encoder = JSONEncoder()
  encoder.outputFormatting = [.sortedKeys]

  for routine in catalog.routines {
    context.insert(
      RoutallySchemaV1.RoutineRecord(
        id: routine.id.rawValue,
        createdAt: routine.createdAt,
        payloadVersion: routinePayloadVersion,
        payload: try encoder.encode(routine)
      )
    )
  }
  for link in catalog.links {
    context.insert(
      RoutallySchemaV1.LinkRecord(
        id: link.id.rawValue,
        sourceRoutineID: link.sourceRoutineID.rawValue,
        targetRoutineID: link.targetRoutineID.rawValue,
        activeFrom: link.activeFrom,
        payload: try encoder.encode(link)
      )
    )
  }
  for cycle in catalog.cycles {
    context.insert(
      RoutallySchemaV1.CycleRecord(
        id: cycle.id.rawValue,
        routineID: cycle.routineID.rawValue,
        anchorDate: cycle.anchorDate,
        payload: try encoder.encode(cycle)
      )
    )
  }
  for event in events {
    context.insert(
      RoutallySchemaV1.EventRecord(
        id: event.recordID,
        routineID: event.value.routineID.rawValue,
        occurredAt: event.value.occurredAt,
        recordedAt: event.value.recordedAt,
        logicalClock: event.value.logicalClock,
        payloadVersion: event.payloadVersion,
        payload: try encoder.encode(event.value)
      )
    )
  }
  try context.save()
}

private func uuid(_ value: String) -> UUID {
  UUID(uuidString: value)!
}
