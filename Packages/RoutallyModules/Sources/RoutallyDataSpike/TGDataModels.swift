import Foundation
import SwiftData

public enum TGDataSchemaV1: VersionedSchema {
  public static let versionIdentifier = Schema.Version(1, 0, 0)

  public static var models: [any PersistentModel.Type] {
    [EventRecord.self]
  }

  @Model
  public final class EventRecord {
    public var id: UUID = UUID()
    public var routineID: UUID = UUID()
    public var occurredAt: Date = Date.distantPast
    public var logicalClock: Int64 = 0
    public var payload: String = ""

    public init(
      id: UUID,
      routineID: UUID,
      occurredAt: Date,
      logicalClock: Int64,
      payload: String
    ) {
      self.id = id
      self.routineID = routineID
      self.occurredAt = occurredAt
      self.logicalClock = logicalClock
      self.payload = payload
    }
  }
}

public enum TGDataSchemaV2: VersionedSchema {
  public static let versionIdentifier = Schema.Version(2, 0, 0)

  public static var models: [any PersistentModel.Type] {
    [
      EventRecord.self,
      EventRevisionRecord.self,
      TombstoneRecord.self,
      RoutineRecord.self,
      LinkRecord.self,
      FollowUpRecord.self,
      WidgetSnapshotRecord.self,
    ]
  }

  @Model
  public final class EventRecord {
    public var id: UUID = UUID()
    public var routineID: UUID = UUID()
    public var occurredAt: Date = Date.distantPast
    public var logicalClock: Int64 = 0
    public var payload: String = ""
    public var origin: String = "app"
    public var originalTimeZoneIdentifier: String = "UTC"

    public init(
      id: UUID,
      routineID: UUID,
      occurredAt: Date,
      logicalClock: Int64,
      payload: String,
      origin: String,
      originalTimeZoneIdentifier: String
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

  @Model
  public final class EventRevisionRecord {
    public var id: UUID = UUID()
    public var eventID: UUID = UUID()
    public var authoredAt: Date = Date.distantPast
    public var logicalClock: Int64 = 0
    public var payload: String = ""

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

  @Model
  public final class TombstoneRecord {
    public var id: UUID = UUID()
    public var recordID: UUID = UUID()
    public var recordKind: String = "event"
    public var deletedAt: Date = Date.distantPast
    public var logicalClock: Int64 = 0

    public init(
      id: UUID,
      recordID: UUID,
      recordKind: String,
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

  @Model
  public final class RoutineRecord {
    public var id: UUID = UUID()
    public var name: String = ""
    public var isArchived: Bool = false
    public var updatedAt: Date = Date.distantPast

    public init(id: UUID, name: String, isArchived: Bool, updatedAt: Date) {
      self.id = id
      self.name = name
      self.isArchived = isArchived
      self.updatedAt = updatedAt
    }
  }

  @Model
  public final class LinkRecord {
    public var id: UUID = UUID()
    public var sourceRoutineID: UUID = UUID()
    public var targetRoutineID: UUID = UUID()
    public var increment: Double = 1

    public init(
      id: UUID,
      sourceRoutineID: UUID,
      targetRoutineID: UUID,
      increment: Double
    ) {
      self.id = id
      self.sourceRoutineID = sourceRoutineID
      self.targetRoutineID = targetRoutineID
      self.increment = increment
    }
  }

  @Model
  public final class FollowUpRecord {
    public var id: UUID = UUID()
    public var routineID: UUID = UUID()
    public var state: String = "waiting"
    public var createdAt: Date = Date.distantPast

    public init(id: UUID, routineID: UUID, state: String, createdAt: Date) {
      self.id = id
      self.routineID = routineID
      self.state = state
      self.createdAt = createdAt
    }
  }

  @Model
  public final class WidgetSnapshotRecord {
    public var id: UUID = UUID()
    public var generatedAt: Date = Date.distantPast
    public var payload: String = ""

    public init(id: UUID, generatedAt: Date, payload: String) {
      self.id = id
      self.generatedAt = generatedAt
      self.payload = payload
    }
  }
}

public enum TGDataMigrationPlan: SchemaMigrationPlan {
  public static var schemas: [any VersionedSchema.Type] {
    [TGDataSchemaV1.self, TGDataSchemaV2.self]
  }

  public static var stages: [MigrationStage] {
    [
      .lightweight(
        fromVersion: TGDataSchemaV1.self,
        toVersion: TGDataSchemaV2.self
      )
    ]
  }
}
