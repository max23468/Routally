import Foundation

public enum DomainAttentionState: String, Codable, Equatable, Hashable, Sendable {
  case notNeeded
  case upcoming
  case due
  case requiresAttention
}

public struct RoutineProjection: Codable, Equatable, Sendable {
  public let routineID: RoutineID
  public var total: Double
  public var periodTotals: [LocalPeriodKey: Double]
  public var lastRecordedAt: Date?
  public var nextNeedAt: Date?
  public var nextScheduledAt: Date?
  public var skippedOccurrenceCount: Int
  public var attention: DomainAttentionState

  public init(routineID: RoutineID) {
    self.routineID = routineID
    total = 0
    periodTotals = [:]
    lastRecordedAt = nil
    nextNeedAt = nil
    nextScheduledAt = nil
    skippedOccurrenceCount = 0
    attention = .notNeeded
  }
}

public enum CyclePhase: String, Codable, Equatable, Hashable, Sendable {
  case active
  case thresholdReached
  case followUpWaiting
  case followUpReady
  case complete
}

public struct CycleProjection: Codable, Equatable, Hashable, Sendable {
  public let cycleID: UsageCycleID
  public let routineID: RoutineID
  public var sequence: Int
  public var progress: Double
  public var startedAt: Date
  public var phase: CyclePhase
  public var currentFollowUpID: FollowUpID?
  public var followUpSuppressedUntilNextProgress: Bool

  public init(
    cycleID: UsageCycleID,
    routineID: RoutineID,
    sequence: Int = 1,
    progress: Double = 0,
    startedAt: Date,
    phase: CyclePhase = .active,
    currentFollowUpID: FollowUpID? = nil,
    followUpSuppressedUntilNextProgress: Bool = false
  ) {
    self.cycleID = cycleID
    self.routineID = routineID
    self.sequence = sequence
    self.progress = progress
    self.startedAt = startedAt
    self.phase = phase
    self.currentFollowUpID = currentFollowUpID
    self.followUpSuppressedUntilNextProgress = followUpSuppressedUntilNextProgress
  }
}

public enum DomainFollowUpState: String, Codable, Equatable, Hashable, Sendable {
  case waitingForUsefulMoment
  case ready
  case completed
}

public struct DomainFollowUp: Codable, Equatable, Hashable, Sendable {
  public let id: FollowUpID
  public let cycleID: UsageCycleID
  public let routineID: RoutineID
  public let title: String
  public let createdAt: Date
  public var readyAt: Date?
  public var postponedUntil: Date?
  public var completedAt: Date?
  public var state: DomainFollowUpState

  public init(
    id: FollowUpID,
    cycleID: UsageCycleID,
    routineID: RoutineID,
    title: String,
    createdAt: Date,
    readyAt: Date?,
    postponedUntil: Date? = nil,
    completedAt: Date? = nil,
    state: DomainFollowUpState
  ) {
    self.id = id
    self.cycleID = cycleID
    self.routineID = routineID
    self.title = title
    self.createdAt = createdAt
    self.readyAt = readyAt
    self.postponedUntil = postponedUntil
    self.completedAt = completedAt
    self.state = state
  }
}

public enum DomainConsequenceKind: Codable, Equatable, Hashable, Sendable {
  case routineProgress(routineID: RoutineID, amount: Double)
  case linkedProgress(linkID: RoutineLinkID, routineID: RoutineID, amount: Double)
  case followUpCreated(FollowUpID)
  case cycleReset(UsageCycleID)
}

public struct DomainConsequence: Codable, Equatable, Hashable, Sendable {
  public let sourceEventID: RoutineEventID
  public let kind: DomainConsequenceKind

  public init(sourceEventID: RoutineEventID, kind: DomainConsequenceKind) {
    self.sourceEventID = sourceEventID
    self.kind = kind
  }
}

public struct DomainState: Codable, Equatable, Sendable {
  public var routines: [RoutineID: RoutineProjection]
  public var cycles: [UsageCycleID: CycleProjection]
  public var followUps: [FollowUpID: DomainFollowUp]
  public var consequencesByEvent: [RoutineEventID: [DomainConsequence]]
  public var processedEventIDs: Set<RoutineEventID>

  public init(
    routines: [RoutineID: RoutineProjection] = [:],
    cycles: [UsageCycleID: CycleProjection] = [:],
    followUps: [FollowUpID: DomainFollowUp] = [:],
    consequencesByEvent: [RoutineEventID: [DomainConsequence]] = [:],
    processedEventIDs: Set<RoutineEventID> = []
  ) {
    self.routines = routines
    self.cycles = cycles
    self.followUps = followUps
    self.consequencesByEvent = consequencesByEvent
    self.processedEventIDs = processedEventIDs
  }
}

public struct DomainRecalculationResult: Equatable, Sendable {
  public let state: DomainState
  public let affectedRoutineIDs: Set<RoutineID>
  public let duration: Duration

  public init(
    state: DomainState,
    affectedRoutineIDs: Set<RoutineID>,
    duration: Duration
  ) {
    self.state = state
    self.affectedRoutineIDs = affectedRoutineIDs
    self.duration = duration
  }
}
