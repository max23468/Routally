import Foundation

public enum RoutineEventOrigin: String, Codable, Equatable, Hashable, Sendable {
  case app
  case widget
  case intent
  case notification
  case synchronization
}

public enum RoutineEventKind: Codable, Equatable, Hashable, Sendable {
  case recorded(MeasurementValue)
  case followUpCompleted(FollowUpID)
  case followUpPostponed(FollowUpID, until: Date)
  case scheduledOccurrenceSkipped(Date)
}

public struct EventEffectExclusions: Codable, Equatable, Hashable, Sendable {
  public var linkIDs: Set<RoutineLinkID>
  public var followUpCycleIDs: Set<UsageCycleID>

  public init(
    linkIDs: Set<RoutineLinkID> = [],
    followUpCycleIDs: Set<UsageCycleID> = []
  ) {
    self.linkIDs = linkIDs
    self.followUpCycleIDs = followUpCycleIDs
  }

  public static let none = EventEffectExclusions()
}

public struct RoutineEvent: Codable, Equatable, Hashable, Sendable {
  public let id: RoutineEventID
  public let routineID: RoutineID
  public var kind: RoutineEventKind
  public var occurredAt: Date
  public var originalLocalDay: LocalDay
  public var origin: RoutineEventOrigin
  public var exclusions: EventEffectExclusions
  public var logicalClock: Int64
  public var recordedAt: Date

  public init(
    id: RoutineEventID = RoutineEventID(),
    routineID: RoutineID,
    kind: RoutineEventKind,
    occurredAt: Date,
    originalLocalDay: LocalDay,
    origin: RoutineEventOrigin = .app,
    exclusions: EventEffectExclusions = .none,
    logicalClock: Int64,
    recordedAt: Date
  ) {
    self.id = id
    self.routineID = routineID
    self.kind = kind
    self.occurredAt = occurredAt
    self.originalLocalDay = originalLocalDay
    self.origin = origin
    self.exclusions = exclusions
    self.logicalClock = logicalClock
    self.recordedAt = recordedAt
  }
}

public struct RoutineEventPatch: Codable, Equatable, Hashable, Sendable {
  public var kind: RoutineEventKind?
  public var occurredAt: Date?
  public var originalLocalDay: LocalDay?
  public var exclusions: EventEffectExclusions?

  public init(
    kind: RoutineEventKind? = nil,
    occurredAt: Date? = nil,
    originalLocalDay: LocalDay? = nil,
    exclusions: EventEffectExclusions? = nil
  ) {
    self.kind = kind
    self.occurredAt = occurredAt
    self.originalLocalDay = originalLocalDay
    self.exclusions = exclusions
  }
}

public struct EventRevision: Codable, Equatable, Hashable, Sendable {
  public let id: EventRevisionID
  public let eventID: RoutineEventID
  public let patch: RoutineEventPatch
  public let logicalClock: Int64
  public let authoredAt: Date

  public init(
    id: EventRevisionID = EventRevisionID(),
    eventID: RoutineEventID,
    patch: RoutineEventPatch,
    logicalClock: Int64,
    authoredAt: Date
  ) {
    self.id = id
    self.eventID = eventID
    self.patch = patch
    self.logicalClock = logicalClock
    self.authoredAt = authoredAt
  }
}

public struct EventTombstone: Codable, Equatable, Hashable, Sendable {
  public let id: TombstoneID
  public let eventID: RoutineEventID
  public let logicalClock: Int64
  public let deletedAt: Date

  public init(
    id: TombstoneID = TombstoneID(),
    eventID: RoutineEventID,
    logicalClock: Int64,
    deletedAt: Date
  ) {
    self.id = id
    self.eventID = eventID
    self.logicalClock = logicalClock
    self.deletedAt = deletedAt
  }
}

public struct DomainLedger: Codable, Equatable, Sendable {
  public var events: [RoutineEvent]
  public var revisions: [EventRevision]
  public var tombstones: [EventTombstone]

  public init(
    events: [RoutineEvent] = [],
    revisions: [EventRevision] = [],
    tombstones: [EventTombstone] = []
  ) {
    self.events = events
    self.revisions = revisions
    self.tombstones = tombstones
  }

  public func resolvedEvents() -> [RoutineEvent] {
    let canonicalEvents = Dictionary(grouping: events, by: \.id).compactMapValues { candidates in
      candidates.max(by: { $0.precedesForConflictResolution($1) })
    }
    let canonicalRevisions = Dictionary(grouping: revisions, by: \.id).compactMapValues {
      candidates in
      candidates.max(by: { $0.precedesForConflictResolution($1) })
    }
    let revisionsByEvent = Dictionary(grouping: canonicalRevisions.values, by: \.eventID)
    let canonicalTombstones = Dictionary(grouping: tombstones, by: \.eventID).compactMapValues {
      candidates in
      candidates.max(by: { $0.precedesForConflictResolution($1) })
    }

    return canonicalEvents.values.compactMap { event in
      let applicableRevisions = revisionsByEvent[event.id, default: []]
        .sorted(by: EventRevision.canonicalOrder)
      let winningClock = max(
        event.logicalClock,
        applicableRevisions.last?.logicalClock ?? .min
      )
      if let tombstone = canonicalTombstones[event.id], tombstone.logicalClock >= winningClock {
        return nil
      }

      var resolved = event
      for revision in applicableRevisions where revision.logicalClock >= resolved.logicalClock {
        resolved = resolved.applying(revision.patch, logicalClock: revision.logicalClock)
      }
      return resolved
    }
    .sorted(by: RoutineEvent.canonicalOrder)
  }
}

extension RoutineEvent {
  fileprivate static func canonicalOrder(_ lhs: Self, _ rhs: Self) -> Bool {
    if lhs.occurredAt != rhs.occurredAt {
      return lhs.occurredAt < rhs.occurredAt
    }
    if lhs.logicalClock != rhs.logicalClock {
      return lhs.logicalClock < rhs.logicalClock
    }
    return lhs.id < rhs.id
  }

  fileprivate func applying(_ patch: RoutineEventPatch, logicalClock: Int64) -> Self {
    var updated = self
    updated.kind = patch.kind ?? kind
    updated.occurredAt = patch.occurredAt ?? occurredAt
    updated.originalLocalDay = patch.originalLocalDay ?? originalLocalDay
    updated.exclusions = patch.exclusions ?? exclusions
    updated.logicalClock = logicalClock
    return updated
  }

  fileprivate func precedesForConflictResolution(_ other: Self) -> Bool {
    if logicalClock != other.logicalClock {
      return logicalClock < other.logicalClock
    }
    if recordedAt != other.recordedAt {
      return recordedAt < other.recordedAt
    }
    if origin != other.origin {
      return origin.rawValue < other.origin.rawValue
    }
    return deterministicConflictKey < other.deterministicConflictKey
  }

  private var deterministicConflictKey: String {
    let excludedLinks = exclusions.linkIDs.sorted().map { $0.rawValue.uuidString }.joined()
    let excludedCycles = exclusions.followUpCycleIDs.sorted().map { $0.rawValue.uuidString }
      .joined()
    return [
      routineID.rawValue.uuidString,
      String(occurredAt.timeIntervalSinceReferenceDate),
      originalLocalDay.timeZoneIdentifier,
      String(originalLocalDay.year),
      String(originalLocalDay.month),
      String(originalLocalDay.day),
      kind.deterministicConflictKey,
      excludedLinks,
      excludedCycles,
    ].joined(separator: "|")
  }
}

extension EventRevision {
  fileprivate static func canonicalOrder(_ lhs: Self, _ rhs: Self) -> Bool {
    if lhs.logicalClock != rhs.logicalClock {
      return lhs.logicalClock < rhs.logicalClock
    }
    if lhs.authoredAt != rhs.authoredAt {
      return lhs.authoredAt < rhs.authoredAt
    }
    return lhs.id < rhs.id
  }

  fileprivate func precedesForConflictResolution(_ other: Self) -> Bool {
    if logicalClock != other.logicalClock {
      return logicalClock < other.logicalClock
    }
    if authoredAt != other.authoredAt {
      return authoredAt < other.authoredAt
    }
    if id != other.id {
      return id < other.id
    }
    if eventID != other.eventID {
      return eventID < other.eventID
    }
    return patch.deterministicConflictKey < other.patch.deterministicConflictKey
  }
}

extension EventTombstone {
  fileprivate func precedesForConflictResolution(_ other: Self) -> Bool {
    if logicalClock != other.logicalClock {
      return logicalClock < other.logicalClock
    }
    if deletedAt != other.deletedAt {
      return deletedAt < other.deletedAt
    }
    return id < other.id
  }
}

extension RoutineEventKind {
  fileprivate var deterministicConflictKey: String {
    switch self {
    case .recorded(let value):
      return "recorded|\(value.amount)|\(value.unitIdentifier ?? "")"
    case .followUpCompleted(let followUpID):
      return "completed|\(followUpID.cycleID.rawValue.uuidString)|\(followUpID.sequence)"
    case .followUpPostponed(let followUpID, let until):
      return [
        "postponed",
        followUpID.cycleID.rawValue.uuidString,
        String(followUpID.sequence),
        String(until.timeIntervalSinceReferenceDate),
      ].joined(separator: "|")
    case .scheduledOccurrenceSkipped(let occurrence):
      return "skipped|\(occurrence.timeIntervalSinceReferenceDate)"
    }
  }
}

extension RoutineEventPatch {
  fileprivate var deterministicConflictKey: String {
    let excludedLinks = exclusions?.linkIDs.sorted().map { $0.rawValue.uuidString }.joined() ?? ""
    let excludedCycles =
      exclusions?.followUpCycleIDs.sorted()
      .map { $0.rawValue.uuidString }.joined() ?? ""
    return [
      kind?.deterministicConflictKey ?? "",
      occurredAt.map { String($0.timeIntervalSinceReferenceDate) } ?? "",
      originalLocalDay.map {
        "\($0.year)-\($0.month)-\($0.day)-\($0.timeZoneIdentifier)"
      } ?? "",
      excludedLinks,
      excludedCycles,
    ].joined(separator: "|")
  }
}
