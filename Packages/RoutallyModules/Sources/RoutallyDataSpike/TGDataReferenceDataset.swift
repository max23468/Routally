import Foundation

public struct TGDataRoutineSeed: Sendable {
  public let id: UUID
  public let name: String
  public let isArchived: Bool
  public let updatedAt: Date
}

public struct TGDataLinkSeed: Sendable {
  public let id: UUID
  public let sourceRoutineID: UUID
  public let targetRoutineID: UUID
  public let increment: Double
}

public struct TGDataFollowUpSeed: Sendable {
  public let id: UUID
  public let routineID: UUID
  public let state: String
  public let createdAt: Date
}

public struct TGDataDatasetCounts: Equatable, Sendable {
  public let routines: Int
  public let archivedRoutines: Int
  public let events: Int
  public let links: Int
  public let followUps: Int
  public let revisions: Int
  public let tombstones: Int

  public init(
    routines: Int,
    archivedRoutines: Int,
    events: Int,
    links: Int,
    followUps: Int,
    revisions: Int,
    tombstones: Int
  ) {
    self.routines = routines
    self.archivedRoutines = archivedRoutines
    self.events = events
    self.links = links
    self.followUps = followUps
    self.revisions = revisions
    self.tombstones = tombstones
  }
}

public struct TGDataReferenceDataset: Sendable {
  public let routines: [TGDataRoutineSeed]
  public let events: [TGDataEvent]
  public let links: [TGDataLinkSeed]
  public let followUps: [TGDataFollowUpSeed]
  public let revisions: [TGDataRevision]
  public let tombstones: [TGDataTombstone]

  public static func make() -> Self {
    let referenceDate = Date(timeIntervalSince1970: 1_700_000_000)
    let routines = (0..<250).map { index in
      TGDataRoutineSeed(
        id: deterministicUUID(namespace: 1, index: index),
        name: "Routine \(index)",
        isArchived: index >= 50,
        updatedAt: referenceDate.addingTimeInterval(Double(index))
      )
    }
    let events = (0..<10_000).map { index in
      TGDataEvent(
        id: deterministicUUID(namespace: 2, index: index),
        routineID: routines[index % 50].id,
        occurredAt: referenceDate.addingTimeInterval(Double(index * 3_600)),
        logicalClock: Int64(index + 1),
        payload: "{\"value\":\(index % 12 + 1)}",
        origin: ["app", "widget", "intent"][index % 3],
        originalTimeZoneIdentifier: ["Europe/Rome", "America/New_York", "Asia/Tokyo"][
          index % 3
        ]
      )
    }
    let links = (0..<100).map { index in
      TGDataLinkSeed(
        id: deterministicUUID(namespace: 3, index: index),
        sourceRoutineID: routines[index % 50].id,
        targetRoutineID: routines[(index + 1) % 50].id,
        increment: Double(index % 5 + 1)
      )
    }
    let followUps = (0..<500).map { index in
      TGDataFollowUpSeed(
        id: deterministicUUID(namespace: 4, index: index),
        routineID: routines[index % 50].id,
        state: ["waiting", "ready", "completed"][index % 3],
        createdAt: referenceDate.addingTimeInterval(Double(index * 7_200))
      )
    }
    let revisions = (0..<500).map { index in
      TGDataRevision(
        id: deterministicUUID(namespace: 5, index: index),
        eventID: events[index * 10].id,
        authoredAt: events[index * 10].occurredAt.addingTimeInterval(60),
        logicalClock: Int64(20_000 + index),
        payload: "{\"value\":\(index % 8 + 1),\"revised\":true}"
      )
    }
    let tombstones = (0..<100).map { index in
      TGDataTombstone(
        id: deterministicUUID(namespace: 6, index: index),
        recordID: events[index * 50].id,
        deletedAt: events[index * 50].occurredAt.addingTimeInterval(120),
        logicalClock: Int64(30_000 + index)
      )
    }

    return Self(
      routines: routines,
      events: events,
      links: links,
      followUps: followUps,
      revisions: revisions,
      tombstones: tombstones
    )
  }

  private static func deterministicUUID(namespace: UInt16, index: Int) -> UUID {
    let value = String(format: "%04X%08X", namespace, index)
    return UUID(uuidString: "00000000-0000-4000-8000-\(value)")!
  }
}
