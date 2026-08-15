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
      Tab(L10n.text(.oggi), systemImage: "sun.max", value: .today) {
        TodayView(store: store, router: router, featureFlags: featureFlags)
      }

      Tab(L10n.text(.routine), systemImage: "repeat", value: .routines) {
        RoutinesView(store: store, router: router)
      }

      Tab(L10n.text(.esplora), systemImage: "safari", value: .explore) {
        ExploreView(router: router)
      }

      Tab(L10n.text(.analisi), systemImage: "chart.xyaxis.line", value: .insights) {
        InsightsView(router: router)
      }

      Tab(
        L10n.text(.cerca),
        systemImage: "magnifyingglass",
        value: .search,
        role: .search
      ) {
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
  #Preview("iPhone · Primo ingresso · Light") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.empty),
      featureFlags: .development
    )
  }

  #Preview("iPhone · Adesso, Più tardi, settimana") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.scheduledDay),
      featureFlags: .development
    )
  }

  #Preview("iPhone · Soglia in attesa · Dark") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.thresholdWaiting),
      featureFlags: .development
    )
    .preferredColorScheme(.dark)
  }

  #Preview("iPhone · Follow-up pronto") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.followUpReady),
      featureFlags: .development
    )
  }

  #Preview("iPhone · Offline pending · English") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.offlinePending),
      featureFlags: .development
    )
    .environment(\.locale, Locale(identifier: "en"))
  }

  #Preview("iPhone · Errore recuperabile") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.recoverableError),
      featureFlags: .development
    )
  }

  #Preview("iPhone landscape · Giornata popolata", traits: .fixedLayout(width: 874, height: 402)) {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.scheduledDay),
      featureFlags: .development
    )
  }

  #Preview("iPad · Routine · AX5", traits: .fixedLayout(width: 1_024, height: 768)) {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.thresholdWaiting),
      featureFlags: .development,
      router: routinePreviewRouter()
    )
    .environment(\.dynamicTypeSize, .accessibility5)
  }

  #Preview("iPad · Routine · Dark", traits: .fixedLayout(width: 768, height: 1_024)) {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.thresholdWaiting),
      featureFlags: .development,
      router: routinePreviewRouter()
    )
    .preferredColorScheme(.dark)
  }

  @MainActor
  private func routinePreviewRouter() -> AppRouter {
    let router = AppRouter()
    router.showRoutine(id: "gym")
    return router
  }

#endif
