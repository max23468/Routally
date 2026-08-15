import Observation

public enum AppTab: Hashable, Sendable {
  case today
  case routines
  case explore
  case insights
  case search
}

public enum RoutineRoute: Hashable, Sendable {
  case detail(id: String)
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
  public internal(set) var selectedTab: AppTab = .today
  public private(set) var selectedRoutineID: String?
  public private(set) var routinesPath: [RoutineRoute] = []
  var sheet: SheetDestination?

  public init() {}

  public func select(_ tab: AppTab) {
    selectedTab = tab
  }

  public func showRoutine(id: String) {
    selectRoutine(id: id)
    selectedTab = .routines
  }

  public func selectRoutine(id: String?) {
    selectedRoutineID = id
    routinesPath = id.map { [.detail(id: $0)] } ?? []
  }

  public func updateRoutinesPath(_ path: [RoutineRoute]) {
    routinesPath = path
    selectedRoutineID = path.last.flatMap { route in
      switch route {
      case .detail(let id): id
      }
    }
  }

  public func showCreation() {
    sheet = .creation
  }

  public func showProfile() {
    sheet = .profile
  }
}
