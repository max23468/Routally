import Foundation

public enum RoutineEventOrigin: String, Codable, Equatable, Hashable, Sendable {
  case app
  case widget
  case intent
  case notification
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
  public var note: String?
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
    note: String? = nil,
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
    self.note = note
    self.logicalClock = logicalClock
    self.recordedAt = recordedAt
  }
}

public enum EventNotePatch: Codable, Equatable, Hashable, Sendable {
  case set(String)
  case clear
}

public struct RoutineEventPatch: Codable, Equatable, Hashable, Sendable {
  public var kind: RoutineEventKind?
  public var occurredAt: Date?
  public var originalLocalDay: LocalDay?
  public var exclusions: EventEffectExclusions?
  public var note: EventNotePatch?

  public init(
    kind: RoutineEventKind? = nil,
    occurredAt: Date? = nil,
    originalLocalDay: LocalDay? = nil,
    exclusions: EventEffectExclusions? = nil,
    note: EventNotePatch? = nil
  ) {
    self.kind = kind
    self.occurredAt = occurredAt
    self.originalLocalDay = originalLocalDay
    self.exclusions = exclusions
    self.note = note
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

  public func resolvedEvents(asOf: Date? = nil) -> [RoutineEvent] {
    var canonicalEvents: [RoutineEventID: RoutineEvent] = [:]
    canonicalEvents.reserveCapacity(events.count)
    for event in events where asOf.map({ event.recordedAt <= $0 }) ?? true {
      if let current = canonicalEvents[event.id], !current.precedesForConflictResolution(event) {
        continue
      }
      canonicalEvents[event.id] = event
    }

    var canonicalRevisions: [EventRevisionID: EventRevision] = [:]
    canonicalRevisions.reserveCapacity(revisions.count)
    for revision in revisions where asOf.map({ revision.authoredAt <= $0 }) ?? true {
      if let current = canonicalRevisions[revision.id],
        !current.precedesForConflictResolution(revision)
      {
        continue
      }
      canonicalRevisions[revision.id] = revision
    }
    var revisionsByEvent: [RoutineEventID: [EventRevision]] = [:]
    for revision in canonicalRevisions.values {
      revisionsByEvent[revision.eventID, default: []].append(revision)
    }

    var tombstonesByID: [TombstoneID: EventTombstone] = [:]
    tombstonesByID.reserveCapacity(tombstones.count)
    for tombstone in tombstones where asOf.map({ tombstone.deletedAt <= $0 }) ?? true {
      if let current = tombstonesByID[tombstone.id],
        !current.precedesForConflictResolution(tombstone)
      {
        continue
      }
      tombstonesByID[tombstone.id] = tombstone
    }
    var canonicalTombstones: [RoutineEventID: EventTombstone] = [:]
    for tombstone in tombstonesByID.values {
      if let current = canonicalTombstones[tombstone.eventID],
        !current.precedesForConflictResolution(tombstone)
      {
        continue
      }
      canonicalTombstones[tombstone.eventID] = tombstone
    }

    var resolvedEvents: [RoutineEvent] = []
    resolvedEvents.reserveCapacity(canonicalEvents.count)
    for event in canonicalEvents.values {
      let applicableRevisions = revisionsByEvent[event.id, default: []]
        .sorted(by: EventRevision.canonicalOrder)
      let winningClock = max(
        event.logicalClock,
        applicableRevisions.last?.logicalClock ?? .min
      )
      if let tombstone = canonicalTombstones[event.id], tombstone.logicalClock >= winningClock {
        continue
      }

      var resolved = event
      for revision in applicableRevisions where revision.logicalClock >= resolved.logicalClock {
        resolved = resolved.applying(revision.patch, logicalClock: revision.logicalClock)
      }
      resolvedEvents.append(resolved)
    }
    return resolvedEvents.sorted(by: RoutineEvent.canonicalOrder)
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
    if let originalLocalDay = patch.originalLocalDay {
      updated.originalLocalDay = originalLocalDay
    } else if patch.occurredAt != nil {
      updated.originalLocalDay = LocalDay(
        date: updated.occurredAt,
        timeZoneIdentifier: originalLocalDay.timeZoneIdentifier
      )
    }
    updated.exclusions = patch.exclusions ?? exclusions
    switch patch.note {
    case .set(let note):
      updated.note = note
    case .clear:
      updated.note = nil
    case nil:
      break
    }
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
      note.map { "set|\($0.utf8.count)|\($0)" } ?? "none",
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
    if id != other.id {
      return id < other.id
    }
    return eventID < other.eventID
  }
}

extension RoutineEventKind {
  fileprivate var deterministicConflictKey: String {
    switch self {
    case .recorded(let value):
      let unit = value.unitIdentifier.map { "set|\($0.utf8.count)|\($0)" } ?? "none"
      return "recorded|\(value.amount)|\(unit)"
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
    let excludedLinks =
      exclusions.map {
        "set|" + $0.linkIDs.sorted().map { $0.rawValue.uuidString }.joined()
      } ?? "none"
    let excludedCycles =
      exclusions.map {
        "set|" + $0.followUpCycleIDs.sorted().map { $0.rawValue.uuidString }.joined()
      } ?? "none"
    return [
      kind.map { "set|\($0.deterministicConflictKey)" } ?? "none",
      occurredAt.map { "set|\($0.timeIntervalSinceReferenceDate)" } ?? "none",
      originalLocalDay.map {
        "set|\($0.year)-\($0.month)-\($0.day)-\($0.timeZoneIdentifier)"
      } ?? "none",
      excludedLinks,
      excludedCycles,
      note.map { "set|\($0.deterministicConflictKey)" } ?? "none",
    ].joined(separator: "|")
  }
}

extension EventNotePatch {
  fileprivate var deterministicConflictKey: String {
    switch self {
    case .set(let note):
      return "set|\(note)"
    case .clear:
      return "clear"
    }
  }
}
