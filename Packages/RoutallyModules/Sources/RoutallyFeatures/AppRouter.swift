import Observation

public enum AppTab: Hashable, Sendable {
  case today
  case routines
  case explore
  case insights
  case search
}

enum SheetDestination: Hashable, Identifiable {
  case creation
  case profile
  case consequences

  var id: Self { self }
}

@MainActor
@Observable
public final class AppRouter {
  var selectedTab: AppTab = .today
  var selectedRoutineID: String?
  var sheet: SheetDestination?

  public init() {}

  public func select(_ tab: AppTab) {
    selectedTab = tab
  }

  public func showCreation() {
    sheet = .creation
  }

  public func showProfile() {
    sheet = .profile
  }
}
