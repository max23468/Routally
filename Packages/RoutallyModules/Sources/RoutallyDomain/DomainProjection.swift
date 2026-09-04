import Foundation

public enum DomainAttentionState: String, Codable, Equatable, Hashable, Sendable {
  case notNeeded
  case upcoming
  case due
  case requiresAttention
}

public struct RoutineProjection: Codable, Equatable, Sendable {
  public var total: Double
  public var periodTotals: [LocalPeriodKey: Double]
  public var lastRecordedAt: Date?
  public var nextNeedAt: Date?
  public var nextScheduledAt: Date?
  public var activeScheduledOccurrenceAt: Date?
  public var unrecordedScheduledOccurrenceCount: Int
  public var skippedOccurrenceCount: Int
  public var attention: DomainAttentionState

  public init() {
    total = 0
    periodTotals = [:]
    lastRecordedAt = nil
    nextNeedAt = nil
    nextScheduledAt = nil
    activeScheduledOccurrenceAt = nil
    unrecordedScheduledOccurrenceCount = 0
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
  public var sequence: Int
  public var progress: Double
  public var startedAt: Date
  public var phase: CyclePhase
  public var currentFollowUpID: FollowUpID?
  public var followUpSuppressedUntilNextProgress: Bool

  public init(
    sequence: Int = 1,
    progress: Double = 0,
    startedAt: Date,
    phase: CyclePhase = .active,
    currentFollowUpID: FollowUpID? = nil,
    followUpSuppressedUntilNextProgress: Bool = false
  ) {
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
  public let routineID: RoutineID
  public let title: String
  public let createdAt: Date
  public var readyAt: Date?
  public var postponedUntil: Date?
  public var completedAt: Date?
  public var state: DomainFollowUpState

  public init(
    id: FollowUpID,
    routineID: RoutineID,
    title: String,
    createdAt: Date,
    readyAt: Date?,
    postponedUntil: Date? = nil,
    completedAt: Date? = nil,
    state: DomainFollowUpState
  ) {
    self.id = id
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
  case cycleThresholdReached(UsageCycleID)
  case followUpCreated(FollowUpID)
  case cycleReset(UsageCycleID)
}

public struct DomainConsequence: Codable, Equatable, Hashable, Sendable {
  public let kind: DomainConsequenceKind

  public init(kind: DomainConsequenceKind) {
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
