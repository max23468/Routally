import Foundation

public protocol RoutallyDomainIdentifier: Codable, Comparable, Hashable, Sendable {
  var rawValue: UUID { get }

  init(rawValue: UUID)
}

extension RoutallyDomainIdentifier {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue.uuidString < rhs.rawValue.uuidString
  }
}

public struct RoutineID: RoutallyDomainIdentifier {
  public let rawValue: UUID

  public init(rawValue: UUID = UUID()) {
    self.rawValue = rawValue
  }
}

public struct RoutineEventID: RoutallyDomainIdentifier {
  public let rawValue: UUID

  public init(rawValue: UUID = UUID()) {
    self.rawValue = rawValue
  }
}

public struct EventRevisionID: RoutallyDomainIdentifier {
  public let rawValue: UUID

  public init(rawValue: UUID = UUID()) {
    self.rawValue = rawValue
  }
}

public struct RoutineLinkID: RoutallyDomainIdentifier {
  public let rawValue: UUID

  public init(rawValue: UUID = UUID()) {
    self.rawValue = rawValue
  }
}

public struct UsageCycleID: RoutallyDomainIdentifier {
  public let rawValue: UUID

  public init(rawValue: UUID = UUID()) {
    self.rawValue = rawValue
  }
}

public struct TombstoneID: RoutallyDomainIdentifier {
  public let rawValue: UUID

  public init(rawValue: UUID = UUID()) {
    self.rawValue = rawValue
  }
}

public struct FollowUpID: Codable, Comparable, Hashable, Sendable {
  public let cycleID: UsageCycleID
  public let sequence: Int

  public init(cycleID: UsageCycleID, sequence: Int) {
    self.cycleID = cycleID
    self.sequence = sequence
  }

  public static func < (lhs: Self, rhs: Self) -> Bool {
    if lhs.cycleID != rhs.cycleID {
      return lhs.cycleID < rhs.cycleID
    }
    return lhs.sequence < rhs.sequence
  }
}
