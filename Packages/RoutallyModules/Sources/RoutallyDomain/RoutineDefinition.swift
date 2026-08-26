import Foundation

public struct MeasurementUnit: Codable, Equatable, Hashable, Sendable {
  public let identifier: String
  public let symbol: String

  public init(identifier: String, symbol: String) {
    self.identifier = identifier
    self.symbol = symbol
  }
}

public enum MeasurementRule: Codable, Equatable, Hashable, Sendable {
  case count
  case duration(defaultSeconds: Int, quickValues: [Int])
  case quantity(unit: MeasurementUnit, defaultValue: Double, quickValues: [Double])
}

public struct MeasurementValue: Codable, Equatable, Hashable, Sendable {
  public let amount: Double
  public let unitIdentifier: String?

  public init(amount: Double, unitIdentifier: String? = nil) {
    self.amount = amount
    self.unitIdentifier = unitIdentifier
  }

  public static let count = MeasurementValue(amount: 1)
}

public enum GoalAggregation: String, Codable, Equatable, Hashable, Sendable {
  case occurrences
  case measurement
}

public struct PeriodicGoalRule: Codable, Equatable, Hashable, Sendable {
  public let target: Double
  public let period: PeriodUnit
  public let aggregation: GoalAggregation

  public init(
    target: Double,
    period: PeriodUnit,
    aggregation: GoalAggregation = .occurrences
  ) {
    self.target = target
    self.period = period
    self.aggregation = aggregation
  }
}

public enum FrequencyRule: Codable, Equatable, Hashable, Sendable {
  case afterLast(CalendarIntervalRule)
  case scheduled(ScheduledRule)
  case withinPeriod(PeriodicGoalRule)
}

public enum AttentionRule: Codable, Equatable, Hashable, Sendable {
  case beforeDue(CalendarIntervalRule)
  case whenDue
  case onlyWhenRequiresAttention(after: CalendarIntervalRule)
  case custom(
    showBefore: CalendarIntervalRule?,
    requiresAttentionAfter: CalendarIntervalRule?
  )
}

public enum RoutineLifecycle: Codable, Equatable, Hashable, Sendable {
  case active
  case paused(since: Date)
  case archived(since: Date)
  case recentlyDeleted(deletedAt: Date)

  public func acceptsManualEvent(at date: Date) -> Bool {
    switch self {
    case .active, .paused:
      return true
    case .archived(let since):
      return date < since
    case .recentlyDeleted(let deletedAt):
      return date < deletedAt
    }
  }

  public func acceptsAutomaticUpdate(at date: Date) -> Bool {
    switch self {
    case .active:
      return true
    case .paused(let since):
      return date < since
    case .archived(let since):
      return date < since
    case .recentlyDeleted(let deletedAt):
      return date < deletedAt
    }
  }

  public func acceptsFollowUpAction(at date: Date) -> Bool {
    switch self {
    case .active:
      return true
    case .paused(let since), .archived(let since), .recentlyDeleted(let since):
      return date < since
    }
  }
}

public struct RoutineDefinition: Codable, Equatable, Hashable, Sendable {
  public let id: RoutineID
  public var name: String
  public var measurement: MeasurementRule
  public var frequency: FrequencyRule
  public var attention: AttentionRule
  public var lifecycle: RoutineLifecycle
  public let createdAt: Date

  public init(
    id: RoutineID = RoutineID(),
    name: String,
    measurement: MeasurementRule,
    frequency: FrequencyRule,
    attention: AttentionRule = .whenDue,
    lifecycle: RoutineLifecycle = .active,
    createdAt: Date
  ) {
    self.id = id
    self.name = name
    self.measurement = measurement
    self.frequency = frequency
    self.attention = attention
    self.lifecycle = lifecycle
    self.createdAt = createdAt
  }
}

public enum LinkContribution: Codable, Equatable, Hashable, Sendable {
  case fixed(Double)
  case sourceValue(multiplier: Double)

  public func amount(for sourceAmount: Double) -> Double {
    switch self {
    case .fixed(let amount):
      return amount
    case .sourceValue(let multiplier):
      return sourceAmount * multiplier
    }
  }

  fileprivate var isValid: Bool {
    switch self {
    case .fixed(let amount):
      return amount.isFinite && amount > 0
    case .sourceValue(let multiplier):
      return multiplier.isFinite && multiplier > 0
    }
  }
}

public struct RoutineLink: Codable, Equatable, Hashable, Sendable {
  public let id: RoutineLinkID
  public let sourceRoutineID: RoutineID
  public let targetRoutineID: RoutineID
  public let contribution: LinkContribution
  public let activeFrom: Date
  public let inactiveFrom: Date?

  public init(
    id: RoutineLinkID = RoutineLinkID(),
    sourceRoutineID: RoutineID,
    targetRoutineID: RoutineID,
    contribution: LinkContribution,
    activeFrom: Date,
    inactiveFrom: Date? = nil
  ) {
    self.id = id
    self.sourceRoutineID = sourceRoutineID
    self.targetRoutineID = targetRoutineID
    self.contribution = contribution
    self.activeFrom = activeFrom
    self.inactiveFrom = inactiveFrom
  }

  public init(
    id: RoutineLinkID = RoutineLinkID(),
    sourceRoutineID: RoutineID,
    targetRoutineID: RoutineID,
    increment: Double,
    activeFrom: Date,
    inactiveFrom: Date? = nil
  ) {
    self.init(
      id: id,
      sourceRoutineID: sourceRoutineID,
      targetRoutineID: targetRoutineID,
      contribution: .fixed(increment),
      activeFrom: activeFrom,
      inactiveFrom: inactiveFrom
    )
  }

  public func isActive(at date: Date) -> Bool {
    activeFrom <= date && inactiveFrom.map { date < $0 } != false
  }
}

public enum ThresholdRule: Codable, Equatable, Hashable, Sendable {
  case progress(Double)
  case elapsed(CalendarIntervalRule)
  case firstReached(progress: Double, elapsed: CalendarIntervalRule)
}

public enum UsefulMomentPolicy: Codable, Equatable, Hashable, Sendable {
  case immediate
  case temporal(notBefore: LocalTime)
  case geographic(locationID: String, fallbackAfter: TimeInterval)
}

public struct FollowUpPolicy: Codable, Equatable, Hashable, Sendable {
  public let title: String
  public let usefulMoment: UsefulMomentPolicy
  public let startsNextCycle: Bool

  public init(title: String, usefulMoment: UsefulMomentPolicy, startsNextCycle: Bool = true) {
    self.title = title
    self.usefulMoment = usefulMoment
    self.startsNextCycle = startsNextCycle
  }
}

public struct UsageCycleDefinition: Codable, Equatable, Hashable, Sendable {
  public let id: UsageCycleID
  public let routineID: RoutineID
  public let threshold: ThresholdRule
  public let followUp: FollowUpPolicy
  public let anchorDate: Date

  public init(
    id: UsageCycleID = UsageCycleID(),
    routineID: RoutineID,
    threshold: ThresholdRule,
    followUp: FollowUpPolicy,
    anchorDate: Date
  ) {
    self.id = id
    self.routineID = routineID
    self.threshold = threshold
    self.followUp = followUp
    self.anchorDate = anchorDate
  }
}

public struct DomainCatalog: Codable, Equatable, Sendable {
  public var routines: [RoutineDefinition]
  public var links: [RoutineLink]
  public var cycles: [UsageCycleDefinition]

  public init(
    routines: [RoutineDefinition],
    links: [RoutineLink] = [],
    cycles: [UsageCycleDefinition] = []
  ) {
    self.routines = routines
    self.links = links
    self.cycles = cycles
  }
}

public enum DomainValidationError: Error, Equatable, Sendable {
  case duplicateRoutineID(RoutineID)
  case duplicateLinkID(RoutineLinkID)
  case duplicateCycleID(UsageCycleID)
  case missingRoutine(RoutineID)
  case invalidRoutineName(RoutineID)
  case invalidMeasurement(RoutineID)
  case invalidFrequency(RoutineID)
  case invalidAttention(RoutineID)
  case invalidLinkIncrement(RoutineLinkID)
  case invalidLinkWindow(RoutineLinkID)
  case circularLink(RoutineID)
  case multiLevelLink(RoutineID)
  case invalidThreshold(UsageCycleID)
  case invalidFollowUp(UsageCycleID)
}

extension DomainCatalog {
  public func validate() throws {
    let routineIDs = routines.map(\.id)
    if let duplicate = firstDuplicate(in: routineIDs) {
      throw DomainValidationError.duplicateRoutineID(duplicate)
    }
    if let duplicate = firstDuplicate(in: links.map(\.id)) {
      throw DomainValidationError.duplicateLinkID(duplicate)
    }
    if let duplicate = firstDuplicate(in: cycles.map(\.id)) {
      throw DomainValidationError.duplicateCycleID(duplicate)
    }

    let knownRoutines = Set(routineIDs)
    for routine in routines {
      guard !routine.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
        throw DomainValidationError.invalidRoutineName(routine.id)
      }
      guard routine.isMeasurementValid else {
        throw DomainValidationError.invalidMeasurement(routine.id)
      }
      guard routine.isFrequencyValid else {
        throw DomainValidationError.invalidFrequency(routine.id)
      }
      guard routine.attention.isValid else {
        throw DomainValidationError.invalidAttention(routine.id)
      }
    }

    for link in links {
      guard knownRoutines.contains(link.sourceRoutineID) else {
        throw DomainValidationError.missingRoutine(link.sourceRoutineID)
      }
      guard knownRoutines.contains(link.targetRoutineID) else {
        throw DomainValidationError.missingRoutine(link.targetRoutineID)
      }
      guard link.contribution.isValid else {
        throw DomainValidationError.invalidLinkIncrement(link.id)
      }
      guard link.inactiveFrom.map({ link.activeFrom < $0 }) != false else {
        throw DomainValidationError.invalidLinkWindow(link.id)
      }
      guard link.sourceRoutineID != link.targetRoutineID else {
        throw DomainValidationError.circularLink(link.sourceRoutineID)
      }
    }

    let sources = Set(links.map(\.sourceRoutineID))
    for target in links.map(\.targetRoutineID) where sources.contains(target) {
      throw DomainValidationError.multiLevelLink(target)
    }

    for cycle in cycles {
      guard knownRoutines.contains(cycle.routineID) else {
        throw DomainValidationError.missingRoutine(cycle.routineID)
      }
      guard cycle.isThresholdValid else {
        throw DomainValidationError.invalidThreshold(cycle.id)
      }
      guard cycle.isFollowUpValid else {
        throw DomainValidationError.invalidFollowUp(cycle.id)
      }
    }
  }

  public func affectedRoutineIDs(startingAt changedRoutineIDs: Set<RoutineID>) -> Set<RoutineID> {
    let knownRoutineIDs = Set(routines.map(\.id))
    let knownChangedRoutineIDs = changedRoutineIDs.intersection(knownRoutineIDs)
    var affected = knownChangedRoutineIDs
    for link in links where knownChangedRoutineIDs.contains(link.sourceRoutineID) {
      affected.insert(link.targetRoutineID)
    }
    return affected
  }

  private func firstDuplicate<Value: Hashable>(in values: [Value]) -> Value? {
    var seen: Set<Value> = []
    for value in values where !seen.insert(value).inserted {
      return value
    }
    return nil
  }
}

extension RoutineDefinition {
  fileprivate var isMeasurementValid: Bool {
    switch measurement {
    case .count:
      return true
    case .duration(let defaultSeconds, let quickValues):
      return defaultSeconds > 0 && quickValues.allSatisfy { $0 > 0 }
    case .quantity(let unit, let defaultValue, let quickValues):
      return !unit.identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && !unit.symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && defaultValue.isFinite && defaultValue > 0
        && quickValues.allSatisfy { $0.isFinite && $0 > 0 }
    }
  }

  fileprivate var isFrequencyValid: Bool {
    switch frequency {
    case .afterLast(let interval):
      return interval.isValid
    case .scheduled(let schedule):
      switch schedule {
      case .weekdays(let weekdays, let everyWeeks, let time, _):
        return !weekdays.isEmpty && everyWeeks > 0 && time.isValid
      case .dayOfMonth(let day, let time):
        return (1...31).contains(day) && time.isValid
      case .interval(let interval, let time, _):
        return interval.isValid && time.isValid
      }
    case .withinPeriod(let goal):
      return goal.target.isFinite && goal.target > 0
    }
  }
}

extension UsageCycleDefinition {
  fileprivate var isThresholdValid: Bool {
    switch threshold {
    case .progress(let value):
      return value.isFinite && value > 0
    case .elapsed(let interval):
      return interval.isValid
    case .firstReached(let progress, let elapsed):
      return progress.isFinite && progress > 0 && elapsed.isValid
    }
  }

  fileprivate var isFollowUpValid: Bool {
    guard !followUp.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return false
    }
    switch followUp.usefulMoment {
    case .immediate:
      return true
    case .temporal(let time):
      return time.isValid
    case .geographic(let locationID, let fallbackAfter):
      return !locationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && fallbackAfter.isFinite && fallbackAfter >= 0
    }
  }
}

extension AttentionRule {
  fileprivate var isValid: Bool {
    switch self {
    case .whenDue:
      return true
    case .beforeDue(let interval), .onlyWhenRequiresAttention(let interval):
      return interval.isValid
    case .custom(let showBefore, let requiresAttentionAfter):
      return showBefore?.isValid != false && requiresAttentionAfter?.isValid != false
    }
  }
}

extension LocalTime {
  fileprivate var isValid: Bool {
    (0...23).contains(hour) && (0...59).contains(minute)
  }
}
