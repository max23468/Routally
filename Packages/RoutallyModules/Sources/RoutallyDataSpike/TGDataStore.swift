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
    var eventIDs = Set(
      try context.fetch(FetchDescriptor<TGDataSchemaV2.EventRecord>()).map(\.id)
    )
    var revisionIDs = Set(
      try context.fetch(FetchDescriptor<TGDataSchemaV2.EventRevisionRecord>()).map(\.id)
    )
    var tombstoneIDs = Set(
      try context.fetch(FetchDescriptor<TGDataSchemaV2.TombstoneRecord>()).map(\.id)
    )

    for event in batch.events where eventIDs.insert(event.id).inserted {
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

    for revision in batch.revisions where revisionIDs.insert(revision.id).inserted {
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

    for tombstone in batch.tombstones where tombstoneIDs.insert(tombstone.id).inserted {
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

    return events.compactMap { event in
      let latestRevision = revisionsByEvent[event.id]?.max(by: revisionPrecedes)
      let effectiveClock = max(event.logicalClock, latestRevision?.logicalClock ?? .min)
      let latestTombstone = tombstonesByEvent[event.id]?.max(by: tombstonePrecedes)
      guard latestTombstone?.logicalClock ?? .min < effectiveClock else { return nil }

      return TGDataResolvedEvent(
        id: event.id,
        routineID: event.routineID,
        occurredAt: event.occurredAt,
        logicalClock: effectiveClock,
        payload: latestRevision?.payload ?? event.payload
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

  private func tombstonePrecedes(
    _ lhs: TGDataSchemaV2.TombstoneRecord,
    _ rhs: TGDataSchemaV2.TombstoneRecord
  ) -> Bool {
    (lhs.logicalClock, lhs.deletedAt, lhs.id.uuidString)
      < (rhs.logicalClock, rhs.deletedAt, rhs.id.uuidString)
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
}
