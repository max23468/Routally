import RoutallyDesign
import RoutallyDomain
import SwiftUI

public struct RoutallyRootView: View {
  @State private var router: AppRouter

  private let store: RoutallyStore
  private let featureFlags: FeatureFlags

  public init(
    store: RoutallyStore,
    featureFlags: FeatureFlags,
    router: AppRouter = AppRouter()
  ) {
    self.store = store
    self.featureFlags = featureFlags
    _router = State(initialValue: router)
  }

  public var body: some View {
    @Bindable var router = router

    TabView(selection: $router.selectedTab) {
      Tab(L10n.text("Oggi"), systemImage: "sun.max", value: .today) {
        TodayView(store: store, router: router, featureFlags: featureFlags)
      }

      Tab(L10n.text("Routine"), systemImage: "repeat", value: .routines) {
        RoutinesView(store: store, router: router)
      }

      Tab(L10n.text("Esplora"), systemImage: "safari", value: .explore) {
        ExploreView(router: router)
      }

      Tab(L10n.text("Analisi"), systemImage: "chart.xyaxis.line", value: .insights) {
        InsightsView(router: router)
      }

      Tab(value: .search, role: .search) {
        SearchView(store: store)
      }
    }
    .tint(RoutallyColor.brandAccent)
    .tabBarMinimizeBehavior(.onScrollDown)
    .sheet(item: $router.sheet) { destination in
      switch destination {
      case .creation:
        CreationSheet(store: store, router: router)
      case .profile:
        ProfileSheet(store: store)
      case .consequences:
        ConsequenceSummarySheet(store: store, router: router)
      }
    }
  }
}

#if DEBUG
  #Preview("iPhone · Oggi vuoto · Light") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: .empty),
      featureFlags: .development
    )
  }

  #Preview("iPhone · Oggi · Dark") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: .previewThresholdReached),
      featureFlags: .development
    )
    .preferredColorScheme(.dark)
  }

  #Preview("iPad · Routine · AX5", traits: .fixedLayout(width: 1_024, height: 768)) {
    RoutallyRootView(
      store: RoutallyStore(snapshot: .previewThresholdReached),
      featureFlags: .development,
      router: routinePreviewRouter()
    )
    .environment(\.dynamicTypeSize, .accessibility5)
  }

  @MainActor
  private func routinePreviewRouter() -> AppRouter {
    let router = AppRouter()
    router.selectedTab = .routines
    router.selectedRoutineID = "gym"
    return router
  }

  extension RoutallySnapshot {
    fileprivate static var previewThresholdReached: RoutallySnapshot {
      RoutallySnapshot(
        scenario: .thresholdReached,
        routines: [
          RoutineSummary(
            id: "gym",
            name: "Palestra",
            symbol: "figure.strengthtraining.traditional",
            context: "Obiettivo: 3 volte a settimana",
            progress: 1,
            target: 3
          ),
          RoutineSummary(
            id: "gym-towel",
            name: "Asciugamano palestra",
            symbol: "washer",
            context: "Si aggiorna quando registri Palestra",
            progress: 3,
            target: 4
          ),
        ]
      )
    }
  }
#endif
