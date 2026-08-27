import Foundation
import SwiftData

public enum RoutallySchemaV1: VersionedSchema {
  public static let versionIdentifier = Schema.Version(1, 0, 0)

  public static var models: [any PersistentModel.Type] {
    [
      RoutineRecord.self,
      LinkRecord.self,
      CycleRecord.self,
      EventRecord.self,
      EventRevisionRecord.self,
      TombstoneRecord.self,
    ]
  }

  @Model
  final class RoutineRecord {
    var id: UUID = UUID()
    var createdAt: Date = Date.distantPast
    var payload: Data = Data()

    init(id: UUID, createdAt: Date, payload: Data) {
      self.id = id
      self.createdAt = createdAt
      self.payload = payload
    }
  }

  @Model
  final class LinkRecord {
    var id: UUID = UUID()
    var sourceRoutineID: UUID = UUID()
    var targetRoutineID: UUID = UUID()
    var activeFrom: Date = Date.distantPast
    var payload: Data = Data()

    init(
      id: UUID,
      sourceRoutineID: UUID,
      targetRoutineID: UUID,
      activeFrom: Date,
      payload: Data
    ) {
      self.id = id
      self.sourceRoutineID = sourceRoutineID
      self.targetRoutineID = targetRoutineID
      self.activeFrom = activeFrom
      self.payload = payload
    }
  }

  @Model
  final class CycleRecord {
    var id: UUID = UUID()
    var routineID: UUID = UUID()
    var anchorDate: Date = Date.distantPast
    var payload: Data = Data()

    init(id: UUID, routineID: UUID, anchorDate: Date, payload: Data) {
      self.id = id
      self.routineID = routineID
      self.anchorDate = anchorDate
      self.payload = payload
    }
  }

  @Model
  final class EventRecord {
    var id: UUID = UUID()
    var routineID: UUID = UUID()
    var occurredAt: Date = Date.distantPast
    var recordedAt: Date = Date.distantPast
    var logicalClock: Int64 = 0
    var payload: Data = Data()

    init(
      id: UUID,
      routineID: UUID,
      occurredAt: Date,
      recordedAt: Date,
      logicalClock: Int64,
      payload: Data
    ) {
      self.id = id
      self.routineID = routineID
      self.occurredAt = occurredAt
      self.recordedAt = recordedAt
      self.logicalClock = logicalClock
      self.payload = payload
    }
  }

  @Model
  final class EventRevisionRecord {
    var id: UUID = UUID()
    var eventID: UUID = UUID()
    var authoredAt: Date = Date.distantPast
    var logicalClock: Int64 = 0
    var payload: Data = Data()

    init(
      id: UUID,
      eventID: UUID,
      authoredAt: Date,
      logicalClock: Int64,
      payload: Data
    ) {
      self.id = id
      self.eventID = eventID
      self.authoredAt = authoredAt
      self.logicalClock = logicalClock
      self.payload = payload
    }
  }

  @Model
  final class TombstoneRecord {
    var id: UUID = UUID()
    var eventID: UUID = UUID()
    var deletedAt: Date = Date.distantPast
    var logicalClock: Int64 = 0
    var payload: Data = Data()

    init(
      id: UUID,
      eventID: UUID,
      deletedAt: Date,
      logicalClock: Int64,
      payload: Data
    ) {
      self.id = id
      self.eventID = eventID
      self.deletedAt = deletedAt
      self.logicalClock = logicalClock
      self.payload = payload
    }
  }
}

public enum RoutallyMigrationPlan: SchemaMigrationPlan {
  public static var schemas: [any VersionedSchema.Type] {
    [RoutallySchemaV1.self]
  }

  public static var stages: [MigrationStage] {
    []
  }
}
