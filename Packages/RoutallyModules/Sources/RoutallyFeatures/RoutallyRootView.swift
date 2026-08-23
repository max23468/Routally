import RoutallyDesign
import RoutallyDomain
import SwiftUI

public struct RoutallyRootView: View {
  private let store: RoutallyStore
  private let featureFlags: FeatureFlags
  private let router: AppRouter

  public init(
    store: RoutallyStore,
    featureFlags: FeatureFlags,
    router: AppRouter
  ) {
    self.store = store
    self.featureFlags = featureFlags
    self.router = router
  }

  public var body: some View {
    @Bindable var router = router

    TabView(selection: $router.selectedTab) {
      Tab(.oggi, systemImage: "sun.max", value: .today) {
        TodayView(store: store, router: router, featureFlags: featureFlags)
      }

      Tab(.routine, systemImage: "repeat", value: .routines) {
        RoutinesView(store: store, router: router)
      }

      Tab(.esplora, systemImage: "safari", value: .explore) {
        ExploreView(router: router)
      }

      Tab(.analisi, systemImage: "chart.xyaxis.line", value: .insights) {
        InsightsView(router: router)
      }

      Tab(.cerca, systemImage: "magnifyingglass", value: .search, role: .search) {
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
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPhone · Adesso, Più tardi, settimana") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.scheduledDay),
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPhone · Soglia in attesa · Dark") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.thresholdWaiting),
      featureFlags: .development,
      router: AppRouter()
    )
    .preferredColorScheme(.dark)
  }

  #Preview("iPhone · Follow-up pronto") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.followUpReady),
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPhone · Offline pending · English") {
    RoutallyRootView(
      store: RoutallyStore(
        snapshot: PreviewFixtures.offlinePending(locale: Locale(identifier: "en"))
      ),
      featureFlags: .development,
      router: AppRouter()
    )
    .environment(\.locale, Locale(identifier: "en"))
  }

  #Preview("iPhone · Errore recuperabile") {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.recoverableError),
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPhone landscape · Giornata popolata", traits: .fixedLayout(width: 874, height: 402)) {
    RoutallyRootView(
      store: RoutallyStore(snapshot: PreviewFixtures.scheduledDay),
      featureFlags: .development,
      router: AppRouter()
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
