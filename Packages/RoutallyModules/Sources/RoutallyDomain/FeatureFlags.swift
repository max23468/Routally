import Foundation

public enum FeatureFlag: String, CaseIterable, Sendable {
  case demoScenarios
  case developerDiagnostics
  case experimentalSearchPresentation
}

public struct FeatureFlags: Equatable, Sendable {
  private let enabled: Set<FeatureFlag>

  public init(enabled: Set<FeatureFlag> = []) {
    self.enabled = enabled
  }

  public func contains(_ flag: FeatureFlag) -> Bool {
    enabled.contains(flag)
  }

  public static let publicRelease = FeatureFlags()
  public static let development = FeatureFlags(
    enabled: [.demoScenarios, .developerDiagnostics]
  )
}
