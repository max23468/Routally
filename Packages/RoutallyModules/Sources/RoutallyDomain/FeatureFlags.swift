public struct FeatureFlags: Equatable, Sendable {
  public let developerDiagnosticsEnabled: Bool

  public init(developerDiagnosticsEnabled: Bool = false) {
    self.developerDiagnosticsEnabled = developerDiagnosticsEnabled
  }

  public static let publicRelease = FeatureFlags()
  public static let development = FeatureFlags(developerDiagnosticsEnabled: true)
}
