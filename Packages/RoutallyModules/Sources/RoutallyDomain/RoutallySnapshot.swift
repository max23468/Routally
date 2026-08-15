import Foundation

public enum DemoScenario: String, CaseIterable, Sendable {
  case emptyProfile
  case newUser
  case typicalUser
  case highlyOrganizedUser
  case thresholdReached
  case offlineWithPendingChanges
  case cloudConflict
  case freeLimitReached
  case plusUser
  case largeHistory
}

public enum RoutineState: String, Sendable {
  case active
  case thresholdReached
  case followUpReady
  case complete
}

public struct RoutineSummary: Identifiable, Equatable, Hashable, Sendable {
  public let id: String
  public var name: String
  public var symbol: String
  public var context: String
  public var progress: Int
  public var target: Int
  public var state: RoutineState

  public init(
    id: String,
    name: String,
    symbol: String,
    context: String,
    progress: Int,
    target: Int,
    state: RoutineState = .active
  ) {
    self.id = id
    self.name = name
    self.symbol = symbol
    self.context = context
    self.progress = progress
    self.target = target
    self.state = state
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
  public var scenario: DemoScenario?
  public var routines: [RoutineSummary]
  public var followUps: [FollowUpSummary]
  public var isOffline: Bool
  public var hasPendingChanges: Bool
  public var notificationCount: Int
  public var isPlus: Bool
  public var hasCloudConflict: Bool

  public init(
    scenario: DemoScenario? = nil,
    routines: [RoutineSummary] = [],
    followUps: [FollowUpSummary] = [],
    isOffline: Bool = false,
    hasPendingChanges: Bool = false,
    notificationCount: Int = 0,
    isPlus: Bool = false,
    hasCloudConflict: Bool = false
  ) {
    self.scenario = scenario
    self.routines = routines
    self.followUps = followUps
    self.isOffline = isOffline
    self.hasPendingChanges = hasPendingChanges
    self.notificationCount = notificationCount
    self.isPlus = isPlus
    self.hasCloudConflict = hasCloudConflict
  }

  public static let empty = RoutallySnapshot()
}
