import Foundation

public enum RoutineState: String, Sendable {
  case active
  case thresholdReached
  case followUpReady
  case complete
}

public enum TodayPlacement: String, Sendable {
  case now
  case later
  case thisWeek
}

public struct RoutineSummary: Identifiable, Equatable, Hashable, Sendable {
  public let id: String
  public var name: String
  public var symbol: String
  public var context: String
  public var progress: Int
  public var target: Int
  public var state: RoutineState
  public var todayPlacement: TodayPlacement

  public init(
    id: String,
    name: String,
    symbol: String,
    context: String,
    progress: Int,
    target: Int,
    state: RoutineState = .active,
    todayPlacement: TodayPlacement = .thisWeek
  ) {
    self.id = id
    self.name = name
    self.symbol = symbol
    self.context = context
    self.progress = progress
    self.target = target
    self.state = state
    self.todayPlacement = todayPlacement
  }
}

public enum FollowUpState: String, Sendable {
  case waitingForUsefulMoment
  case ready
  case completed
}

public struct FollowUpSummary: Identifiable, Equatable, Hashable, Sendable {
  public let id: String
  public var title: String
  public var origin: String
  public var state: FollowUpState

  public init(id: String, title: String, origin: String, state: FollowUpState) {
    self.id = id
    self.title = title
    self.origin = origin
    self.state = state
  }
}

public struct RoutallySnapshot: Equatable, Sendable {
  public var routines: [RoutineSummary]
  public var followUps: [FollowUpSummary]
  public var isOffline: Bool
  public var hasPendingChanges: Bool
  public var notificationCount: Int
  public var notifiedFollowUpIDs: Set<String>
  public var hasCloudConflict: Bool
  public var hasRecoverableEventError: Bool

  public init(
    routines: [RoutineSummary] = [],
    followUps: [FollowUpSummary] = [],
    isOffline: Bool = false,
    hasPendingChanges: Bool = false,
    notificationCount: Int = 0,
    notifiedFollowUpIDs: Set<String> = [],
    hasCloudConflict: Bool = false,
    hasRecoverableEventError: Bool = false
  ) {
    self.routines = routines
    self.followUps = followUps
    self.isOffline = isOffline
    self.hasPendingChanges = hasPendingChanges
    self.notificationCount = notificationCount
    self.notifiedFollowUpIDs = notifiedFollowUpIDs
    self.hasCloudConflict = hasCloudConflict
    self.hasRecoverableEventError = hasRecoverableEventError
  }

  public static let empty = RoutallySnapshot()
}
