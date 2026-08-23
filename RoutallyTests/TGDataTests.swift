import Foundation
import RoutallyDataSpike
import Testing

@Suite("M01 TG-DATA")
@MainActor
struct TGDataTests {
  @Test("Lo store registra offline e recupera dopo la riapertura")
  func localStorePersistsAndRecovers() throws {
    let temporaryStore = try TemporaryStore()
    let event = makeEvent(index: 1)

    do {
      let store = try TGDataEventStore(
        configuration: TGDataEventStore.localConfiguration(url: temporaryStore.url)
      )
      try store.merge(TGDataSyncBatch(events: [event]))
      #expect(try store.resolvedEvents().map(\.id) == [event.id])
    }

    let recoveredStore = try TGDataEventStore(
      configuration: TGDataEventStore.localConfiguration(url: temporaryStore.url)
    )
    #expect(try recoveredStore.resolvedEvents().map(\.id) == [event.id])
  }

  @Test("Revisioni, tombstone e retry convergono indipendentemente dall'ordine")
  func syncOrderConverges() throws {
    let retainedEvent = makeEvent(index: 1)
    let deletedEvent = makeEvent(index: 2)
    let firstRevision = TGDataRevision(
      id: uuid("00000000-0000-4000-8100-000000000001"),
      eventID: retainedEvent.id,
      authoredAt: retainedEvent.occurredAt.addingTimeInterval(10),
      logicalClock: 5,
      payload: "revisione iniziale"
    )
    let winningRevision = TGDataRevision(
      id: uuid("00000000-0000-4000-8100-000000000002"),
      eventID: retainedEvent.id,
      authoredAt: retainedEvent.occurredAt.addingTimeInterval(20),
      logicalClock: 5,
      payload: "revisione finale"
    )
    let tombstone = TGDataTombstone(
      id: uuid("00000000-0000-4000-8200-000000000001"),
      recordID: deletedEvent.id,
      deletedAt: deletedEvent.occurredAt.addingTimeInterval(30),
      logicalClock: 10
    )
    let forwardBatch = TGDataSyncBatch(
      events: [retainedEvent, deletedEvent, retainedEvent],
      revisions: [firstRevision, winningRevision, firstRevision],
      tombstones: [tombstone, tombstone]
    )
    let reverseBatch = TGDataSyncBatch(
      events: Array(forwardBatch.events.reversed()),
      revisions: Array(forwardBatch.revisions.reversed()),
      tombstones: Array(forwardBatch.tombstones.reversed())
    )

    let forwardStore = try TGDataEventStore()
    let reverseStore = try TGDataEventStore()
    try forwardStore.merge(forwardBatch)
    try reverseStore.merge(reverseBatch)

    let forwardResult = try forwardStore.resolvedEvents()
    let reverseResult = try reverseStore.resolvedEvents()
    #expect(forwardResult == reverseResult)
    #expect(forwardResult.count == 1)
    #expect(forwardResult.first?.id == retainedEvent.id)
    #expect(forwardResult.first?.payload == "revisione finale")
  }

  @Test("App e widget leggono lo stesso snapshot da uno store condiviso")
  func appAndWidgetShareSnapshot() throws {
    let temporaryStore = try TemporaryStore()
    let snapshotID = uuid("00000000-0000-4000-8300-000000000001")

    do {
      let appStore = try TGDataEventStore(
        configuration: TGDataEventStore.localConfiguration(url: temporaryStore.url)
      )
      try appStore.writeWidgetSnapshot(
        id: snapshotID,
        payload: "oggi:3",
        generatedAt: Date(timeIntervalSince1970: 1_700_000_000)
      )
    }

    let widgetStore = try TGDataEventStore(
      configuration: TGDataEventStore.localConfiguration(url: temporaryStore.url)
    )
    #expect(try widgetStore.latestWidgetSnapshot() == "oggi:3")
  }

  @Test("Duplicati già persistiti vengono risolti una sola volta")
  func persistedDuplicatesResolveOnce() throws {
    let forwardStore = try TemporaryStore()
    let reverseStore = try TemporaryStore()
    let original = makeEvent(index: 3)
    let importedRevision = TGDataEvent(
      id: original.id,
      routineID: original.routineID,
      occurredAt: original.occurredAt,
      logicalClock: original.logicalClock + 1,
      payload: "evento importato",
      origin: "widget",
      originalTimeZoneIdentifier: original.originalTimeZoneIdentifier
    )

    try TGDataMigrationProbe.seedImportedV2Store(
      at: forwardStore.url,
      events: [original, importedRevision]
    )
    try TGDataMigrationProbe.seedImportedV2Store(
      at: reverseStore.url,
      events: [importedRevision, original]
    )

    let forwardResult = try TGDataEventStore(
      configuration: TGDataEventStore.localConfiguration(url: forwardStore.url)
    ).resolvedEvents()
    let reverseResult = try TGDataEventStore(
      configuration: TGDataEventStore.localConfiguration(url: reverseStore.url)
    ).resolvedEvents()

    #expect(forwardResult == reverseResult)
    #expect(forwardResult.count == 1)
    #expect(forwardResult.first?.id == original.id)
    #expect(forwardResult.first?.payload == "evento importato")
    #expect(
      try TGDataEventStore(
        configuration: TGDataEventStore.localConfiguration(url: forwardStore.url)
      ).probeSnapshot(eventID: original.id).eventVariants == 2
    )
  }

  @Test("Duplicati ricevuti in merge separati convergono al record canonico")
  func duplicatesAcrossSeparateMergesConverge() throws {
    let original = makeEvent(index: 4)
    let updated = TGDataEvent(
      id: original.id,
      routineID: original.routineID,
      occurredAt: original.occurredAt,
      logicalClock: original.logicalClock + 1,
      payload: "evento aggiornato",
      origin: "widget",
      originalTimeZoneIdentifier: original.originalTimeZoneIdentifier
    )
    let forwardStore = try TGDataEventStore()
    let reverseStore = try TGDataEventStore()

    try forwardStore.merge(TGDataSyncBatch(events: [original]))
    try forwardStore.merge(TGDataSyncBatch(events: [updated]))
    try reverseStore.merge(TGDataSyncBatch(events: [updated]))
    try reverseStore.merge(TGDataSyncBatch(events: [original]))

    let forwardResult = try forwardStore.resolvedEvents()
    let reverseResult = try reverseStore.resolvedEvents()
    #expect(forwardResult == reverseResult)
    #expect(forwardResult.count == 1)
    #expect(forwardResult.first?.payload == "evento aggiornato")
    #expect(try forwardStore.probeSnapshot(eventID: original.id).eventVariants == 2)
  }

  @Test("Una revisione obsoleta non sostituisce un evento più recente")
  func staleRevisionDoesNotOverrideNewerEvent() throws {
    let event = makeEvent(index: 10)
    let staleRevision = TGDataRevision(
      id: uuid("00000000-0000-4000-8100-000000000010"),
      eventID: event.id,
      authoredAt: event.occurredAt.addingTimeInterval(10),
      logicalClock: event.logicalClock - 1,
      payload: "revisione obsoleta"
    )
    let store = try TGDataEventStore()

    try store.merge(
      TGDataSyncBatch(events: [event], revisions: [staleRevision])
    )

    let resolved = try #require(store.resolvedEvents().first)
    #expect(resolved.logicalClock == event.logicalClock)
    #expect(resolved.payload == event.payload)
  }

  @Test("La migrazione lightweight conserva gli eventi V1")
  func lightweightMigrationPreservesV1Events() throws {
    let temporaryStore = try TemporaryStore()
    let event = makeEvent(index: 7)

    try TGDataMigrationProbe.seedV1Store(at: temporaryStore.url, event: event)
    let migratedStore = try TGDataEventStore(
      configuration: TGDataEventStore.localConfiguration(url: temporaryStore.url)
    )

    let migrated = try #require(migratedStore.resolvedEvents().first)
    #expect(migrated.id == event.id)
    #expect(migrated.payload == event.payload)
  }

  @Test("Il passaggio al container definitivo non cambia schema o store contract")
  func environmentTransitionOnlyChangesIdentifiers() throws {
    let provisional = TGDataEnvironment(
      phase: .provisional,
      appGroupIdentifier: "group.com.temisfera.routally.dev.provisional",
      cloudKitContainerIdentifier: "iCloud.com.temisfera.routally.dev.provisional"
    )
    let definitive = TGDataEnvironment(
      phase: .definitive,
      appGroupIdentifier: "group.com.temisfera.routally",
      cloudKitContainerIdentifier: "iCloud.com.temisfera.routally"
    )

    #expect(provisional.phase == .provisional)
    #expect(definitive.phase == .definitive)
    #expect(
      provisional.configuration.groupAppContainerIdentifier
        == provisional.appGroupIdentifier
    )
    #expect(
      definitive.configuration.cloudKitContainerIdentifier
        == definitive.cloudKitContainerIdentifier
    )
    #expect(provisional.configuration.schema?.version == definitive.configuration.schema?.version)
    try provisional.configuration.validate()
    try definitive.configuration.validate()
  }

  @Test("Il dataset realistico viene persistito con tutti i volumi canonici")
  func referenceDatasetPersistsCanonicalVolumes() throws {
    let store = try TGDataEventStore()

    try store.populateReferenceDataset(.make())

    #expect(
      try store.counts()
        == TGDataDatasetCounts(
          routines: 250,
          archivedRoutines: 200,
          events: 10_000,
          links: 100,
          followUps: 500,
          revisions: 500,
          tombstones: 100
        )
    )
    #expect(try store.resolvedEvents().count == 9_900)
  }

  private func makeEvent(index: Int) -> TGDataEvent {
    TGDataEvent(
      id: uuid(String(format: "00000000-0000-4000-8000-%012X", index)),
      routineID: uuid("00000000-0000-4000-8001-000000000001"),
      occurredAt: Date(timeIntervalSince1970: 1_700_000_000 + Double(index)),
      logicalClock: Int64(index),
      payload: "evento \(index)",
      origin: "app",
      originalTimeZoneIdentifier: "Europe/Rome"
    )
  }

  private func uuid(_ value: String) -> UUID {
    UUID(uuidString: value)!
  }
}

private final class TemporaryStore {
  let directory: URL
  let url: URL

  init() throws {
    directory = FileManager.default.temporaryDirectory
      .appending(path: "Routally-TG-DATA-\(UUID().uuidString)", directoryHint: .isDirectory)
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )
    url = directory.appending(path: "TGData.store")
  }

  deinit {
    try? FileManager.default.removeItem(at: directory)
  }
}
