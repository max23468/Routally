import Foundation
import SwiftData

public struct TGDataEvent: Equatable, Hashable, Sendable {
  public let id: UUID
  public let routineID: UUID
  public let occurredAt: Date
  public let logicalClock: Int64
  public let payload: String
  public let origin: String
  public let originalTimeZoneIdentifier: String

  public init(
    id: UUID,
    routineID: UUID,
    occurredAt: Date,
    logicalClock: Int64,
    payload: String,
    origin: String = "app",
    originalTimeZoneIdentifier: String = "UTC"
  ) {
    self.id = id
    self.routineID = routineID
    self.occurredAt = occurredAt
    self.logicalClock = logicalClock
    self.payload = payload
    self.origin = origin
    self.originalTimeZoneIdentifier = originalTimeZoneIdentifier
  }
}

public struct TGDataRevision: Equatable, Hashable, Sendable {
  public let id: UUID
  public let eventID: UUID
  public let authoredAt: Date
  public let logicalClock: Int64
  public let payload: String

  public init(
    id: UUID,
    eventID: UUID,
    authoredAt: Date,
    logicalClock: Int64,
    payload: String
  ) {
    self.id = id
    self.eventID = eventID
    self.authoredAt = authoredAt
    self.logicalClock = logicalClock
    self.payload = payload
  }
}

public struct TGDataTombstone: Equatable, Hashable, Sendable {
  public let id: UUID
  public let recordID: UUID
  public let recordKind: String
  public let deletedAt: Date
  public let logicalClock: Int64

  public init(
    id: UUID,
    recordID: UUID,
    recordKind: String = "event",
    deletedAt: Date,
    logicalClock: Int64
  ) {
    self.id = id
    self.recordID = recordID
    self.recordKind = recordKind
    self.deletedAt = deletedAt
    self.logicalClock = logicalClock
  }
}

public struct TGDataResolvedEvent: Equatable, Sendable {
  public let id: UUID
  public let routineID: UUID
  public let occurredAt: Date
  public let logicalClock: Int64
  public let payload: String
}

public struct TGDataSyncBatch: Sendable {
  public let events: [TGDataEvent]
  public let revisions: [TGDataRevision]
  public let tombstones: [TGDataTombstone]

  public init(
    events: [TGDataEvent] = [],
    revisions: [TGDataRevision] = [],
    tombstones: [TGDataTombstone] = []
  ) {
    self.events = events
    self.revisions = revisions
    self.tombstones = tombstones
  }
}

public enum TGDataContainerPhase: String, Sendable {
  case provisional
  case definitive
}

public struct TGDataEnvironment: Equatable, Sendable {
  public let phase: TGDataContainerPhase
  public let appGroupIdentifier: String
  public let cloudKitContainerIdentifier: String

  public init(
    phase: TGDataContainerPhase,
    appGroupIdentifier: String,
    cloudKitContainerIdentifier: String
  ) {
    self.phase = phase
    self.appGroupIdentifier = appGroupIdentifier
    self.cloudKitContainerIdentifier = cloudKitContainerIdentifier
  }

  public var configuration: ModelConfiguration {
    ModelConfiguration(
      "Routally",
      schema: Schema(versionedSchema: TGDataSchemaV2.self),
      groupContainer: .identifier(appGroupIdentifier),
      cloudKitDatabase: .private(cloudKitContainerIdentifier)
    )
  }
}

@MainActor
public final class TGDataEventStore {
  private let container: ModelContainer
  private let context: ModelContext

  public init(configuration: ModelConfiguration) throws {
    container = try ModelContainer(
      for: Schema(versionedSchema: TGDataSchemaV2.self),
      migrationPlan: TGDataMigrationPlan.self,
      configurations: [configuration]
    )
    context = ModelContext(container)
    context.autosaveEnabled = false
  }

  public convenience init(inMemory: Bool = true) throws {
    let schema = Schema(versionedSchema: TGDataSchemaV2.self)
    let configuration = ModelConfiguration(
      "TGData",
      schema: schema,
      isStoredInMemoryOnly: inMemory,
      cloudKitDatabase: .none
    )
    try self.init(configuration: configuration)
  }

  public static func localConfiguration(url: URL) -> ModelConfiguration {
    ModelConfiguration(
      "TGData",
      schema: Schema(versionedSchema: TGDataSchemaV2.self),
      url: url,
      cloudKitDatabase: .none
    )
  }

  public func merge(_ batch: TGDataSyncBatch) throws {
    var eventFingerprints = Set(
      try context.fetch(FetchDescriptor<TGDataSchemaV2.EventRecord>()).map(EventFingerprint.init)
    )
    var revisionFingerprints = Set(
      try context.fetch(FetchDescriptor<TGDataSchemaV2.EventRevisionRecord>()).map(
        RevisionFingerprint.init
      )
    )
    var tombstoneFingerprints = Set(
      try context.fetch(FetchDescriptor<TGDataSchemaV2.TombstoneRecord>()).map(
        TombstoneFingerprint.init
      )
    )

    for event in batch.events where eventFingerprints.insert(EventFingerprint(event)).inserted {
      context.insert(
        TGDataSchemaV2.EventRecord(
          id: event.id,
          routineID: event.routineID,
          occurredAt: event.occurredAt,
          logicalClock: event.logicalClock,
          payload: event.payload,
          origin: event.origin,
          originalTimeZoneIdentifier: event.originalTimeZoneIdentifier
        )
      )
    }

    for revision in batch.revisions
    where revisionFingerprints.insert(RevisionFingerprint(revision)).inserted {
      context.insert(
        TGDataSchemaV2.EventRevisionRecord(
          id: revision.id,
          eventID: revision.eventID,
          authoredAt: revision.authoredAt,
          logicalClock: revision.logicalClock,
          payload: revision.payload
        )
      )
    }

    for tombstone in batch.tombstones
    where tombstoneFingerprints.insert(TombstoneFingerprint(tombstone)).inserted {
      context.insert(
        TGDataSchemaV2.TombstoneRecord(
          id: tombstone.id,
          recordID: tombstone.recordID,
          recordKind: tombstone.recordKind,
          deletedAt: tombstone.deletedAt,
          logicalClock: tombstone.logicalClock
        )
      )
    }

    try context.save()
  }

  public func resolvedEvents() throws -> [TGDataResolvedEvent] {
    let events = try context.fetch(FetchDescriptor<TGDataSchemaV2.EventRecord>())
    let revisions = try context.fetch(FetchDescriptor<TGDataSchemaV2.EventRevisionRecord>())
    let tombstones = try context.fetch(FetchDescriptor<TGDataSchemaV2.TombstoneRecord>())

    let revisionsByEvent = Dictionary(grouping: revisions, by: \.eventID)
    let tombstonesByEvent = Dictionary(
      grouping: tombstones.filter { $0.recordKind == "event" },
      by: \.recordID
    )

    let canonicalEvents = Dictionary(grouping: events, by: \.id).compactMap { _, duplicates in
      duplicates.max(by: eventPrecedes)
    }

    return canonicalEvents.compactMap { event in
      let latestRevision = revisionsByEvent[event.id]?.max(by: revisionPrecedes)
      let appliedRevision = latestRevision.flatMap { revision in
        revision.logicalClock > event.logicalClock ? revision : nil
      }
      let effectiveClock = appliedRevision?.logicalClock ?? event.logicalClock
      let latestTombstone = tombstonesByEvent[event.id]?.max(by: tombstonePrecedes)
      guard latestTombstone?.logicalClock ?? .min < effectiveClock else { return nil }

      return TGDataResolvedEvent(
        id: event.id,
        routineID: event.routineID,
        occurredAt: event.occurredAt,
        logicalClock: effectiveClock,
        payload: appliedRevision?.payload ?? event.payload
      )
    }
    .sorted {
      ($0.occurredAt, $0.id.uuidString) < ($1.occurredAt, $1.id.uuidString)
    }
  }

  public func writeWidgetSnapshot(id: UUID, payload: String, generatedAt: Date) throws {
    context.insert(
      TGDataSchemaV2.WidgetSnapshotRecord(
        id: id,
        generatedAt: generatedAt,
        payload: payload
      )
    )
    try context.save()
  }

  public func latestWidgetSnapshot() throws -> String? {
    try context.fetch(FetchDescriptor<TGDataSchemaV2.WidgetSnapshotRecord>())
      .max {
        ($0.generatedAt, $0.id.uuidString) < ($1.generatedAt, $1.id.uuidString)
      }?
      .payload
  }

  public func populateReferenceDataset(_ dataset: TGDataReferenceDataset) throws {
    for routine in dataset.routines {
      context.insert(
        TGDataSchemaV2.RoutineRecord(
          id: routine.id,
          name: routine.name,
          isArchived: routine.isArchived,
          updatedAt: routine.updatedAt
        )
      )
    }
    for link in dataset.links {
      context.insert(
        TGDataSchemaV2.LinkRecord(
          id: link.id,
          sourceRoutineID: link.sourceRoutineID,
          targetRoutineID: link.targetRoutineID,
          increment: link.increment
        )
      )
    }
    for followUp in dataset.followUps {
      context.insert(
        TGDataSchemaV2.FollowUpRecord(
          id: followUp.id,
          routineID: followUp.routineID,
          state: followUp.state,
          createdAt: followUp.createdAt
        )
      )
    }
    try merge(
      TGDataSyncBatch(
        events: dataset.events,
        revisions: dataset.revisions,
        tombstones: dataset.tombstones
      )
    )
  }

  public func counts() throws -> TGDataDatasetCounts {
    TGDataDatasetCounts(
      routines: try context.fetchCount(FetchDescriptor<TGDataSchemaV2.RoutineRecord>()),
      archivedRoutines: try context.fetch(
        FetchDescriptor<TGDataSchemaV2.RoutineRecord>()
      ).count(where: \.isArchived),
      events: try context.fetchCount(FetchDescriptor<TGDataSchemaV2.EventRecord>()),
      links: try context.fetchCount(FetchDescriptor<TGDataSchemaV2.LinkRecord>()),
      followUps: try context.fetchCount(FetchDescriptor<TGDataSchemaV2.FollowUpRecord>()),
      revisions: try context.fetchCount(
        FetchDescriptor<TGDataSchemaV2.EventRevisionRecord>()
      ),
      tombstones: try context.fetchCount(FetchDescriptor<TGDataSchemaV2.TombstoneRecord>())
    )
  }

  private func revisionPrecedes(
    _ lhs: TGDataSchemaV2.EventRevisionRecord,
    _ rhs: TGDataSchemaV2.EventRevisionRecord
  ) -> Bool {
    (lhs.logicalClock, lhs.authoredAt, lhs.id.uuidString)
      < (rhs.logicalClock, rhs.authoredAt, rhs.id.uuidString)
  }

  private func eventPrecedes(
    _ lhs: TGDataSchemaV2.EventRecord,
    _ rhs: TGDataSchemaV2.EventRecord
  ) -> Bool {
    (
      lhs.logicalClock,
      lhs.occurredAt,
      lhs.routineID.uuidString,
      lhs.payload,
      lhs.origin,
      lhs.originalTimeZoneIdentifier
    ) < (
      rhs.logicalClock,
      rhs.occurredAt,
      rhs.routineID.uuidString,
      rhs.payload,
      rhs.origin,
      rhs.originalTimeZoneIdentifier
    )
  }

  private func tombstonePrecedes(
    _ lhs: TGDataSchemaV2.TombstoneRecord,
    _ rhs: TGDataSchemaV2.TombstoneRecord
  ) -> Bool {
    (lhs.logicalClock, lhs.deletedAt, lhs.id.uuidString)
      < (rhs.logicalClock, rhs.deletedAt, rhs.id.uuidString)
  }
}

private struct EventFingerprint: Hashable {
  let id: UUID
  let routineID: UUID
  let occurredAt: Date
  let logicalClock: Int64
  let payload: String
  let origin: String
  let originalTimeZoneIdentifier: String

  init(_ event: TGDataEvent) {
    id = event.id
    routineID = event.routineID
    occurredAt = event.occurredAt
    logicalClock = event.logicalClock
    payload = event.payload
    origin = event.origin
    originalTimeZoneIdentifier = event.originalTimeZoneIdentifier
  }

  init(_ record: TGDataSchemaV2.EventRecord) {
    id = record.id
    routineID = record.routineID
    occurredAt = record.occurredAt
    logicalClock = record.logicalClock
    payload = record.payload
    origin = record.origin
    originalTimeZoneIdentifier = record.originalTimeZoneIdentifier
  }
}

private struct RevisionFingerprint: Hashable {
  let id: UUID
  let eventID: UUID
  let authoredAt: Date
  let logicalClock: Int64
  let payload: String

  init(_ revision: TGDataRevision) {
    id = revision.id
    eventID = revision.eventID
    authoredAt = revision.authoredAt
    logicalClock = revision.logicalClock
    payload = revision.payload
  }

  init(_ record: TGDataSchemaV2.EventRevisionRecord) {
    id = record.id
    eventID = record.eventID
    authoredAt = record.authoredAt
    logicalClock = record.logicalClock
    payload = record.payload
  }
}

private struct TombstoneFingerprint: Hashable {
  let id: UUID
  let recordID: UUID
  let recordKind: String
  let deletedAt: Date
  let logicalClock: Int64

  init(_ tombstone: TGDataTombstone) {
    id = tombstone.id
    recordID = tombstone.recordID
    recordKind = tombstone.recordKind
    deletedAt = tombstone.deletedAt
    logicalClock = tombstone.logicalClock
  }

  init(_ record: TGDataSchemaV2.TombstoneRecord) {
    id = record.id
    recordID = record.recordID
    recordKind = record.recordKind
    deletedAt = record.deletedAt
    logicalClock = record.logicalClock
  }
}

@MainActor
public enum TGDataMigrationProbe {
  public static func seedV1Store(at url: URL, event: TGDataEvent) throws {
    let schema = Schema(versionedSchema: TGDataSchemaV1.self)
    let configuration = ModelConfiguration(
      "TGData",
      schema: schema,
      url: url,
      cloudKitDatabase: .none
    )
    let container = try ModelContainer(for: schema, configurations: [configuration])
    let context = ModelContext(container)
    context.insert(
      TGDataSchemaV1.EventRecord(
        id: event.id,
        routineID: event.routineID,
        occurredAt: event.occurredAt,
        logicalClock: event.logicalClock,
        payload: event.payload
      )
    )
    try context.save()
  }

  public static func seedImportedV2Store(at url: URL, events: [TGDataEvent]) throws {
    let schema = Schema(versionedSchema: TGDataSchemaV2.self)
    let configuration = TGDataEventStore.localConfiguration(url: url)
    let container = try ModelContainer(
      for: schema,
      migrationPlan: TGDataMigrationPlan.self,
      configurations: [configuration]
    )
    let context = ModelContext(container)
    for event in events {
      context.insert(
        TGDataSchemaV2.EventRecord(
          id: event.id,
          routineID: event.routineID,
          occurredAt: event.occurredAt,
          logicalClock: event.logicalClock,
          payload: event.payload,
          origin: event.origin,
          originalTimeZoneIdentifier: event.originalTimeZoneIdentifier
        )
      )
    }
    try context.save()
  }
}
