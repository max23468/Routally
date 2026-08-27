import RoutallyDesign
import RoutallyDomain
import SwiftUI

public struct RoutallyRootView: View {
  @Environment(\.locale) private var locale

  private let store: RoutallyFeatureModel
  private let featureFlags: FeatureFlags
  private let router: AppRouter

  public init(
    store: RoutallyFeatureModel,
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
    .overlay {
      if store.isLoading && store.snapshot.routines.isEmpty {
        ProgressView()
          .controlSize(.large)
          .accessibilityLabel(.caricamento)
      }
    }
    .task {
      await store.load(locale: locale)
    }
    .onChange(of: locale.identifier) { _, _ in
      Task {
        await store.load(locale: locale)
      }
    }
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
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.empty),
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPhone · Adesso, Più tardi, settimana") {
    RoutallyRootView(
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.scheduledDay),
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPhone · Soglia in attesa · Dark") {
    RoutallyRootView(
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.thresholdWaiting),
      featureFlags: .development,
      router: AppRouter()
    )
    .preferredColorScheme(.dark)
  }

  #Preview("iPhone · Follow-up pronto") {
    RoutallyRootView(
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.followUpReady),
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPhone · Offline pending · English") {
    RoutallyRootView(
      store: RoutallyFeatureModel(
        previewSnapshot: PreviewFixtures.offlinePending(locale: Locale(identifier: "en"))
      ),
      featureFlags: .development,
      router: AppRouter()
    )
    .environment(\.locale, Locale(identifier: "en"))
  }

  #Preview("iPhone · Errore recuperabile") {
    RoutallyRootView(
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.recoverableError),
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPhone landscape · Giornata popolata", traits: .fixedLayout(width: 874, height: 402)) {
    RoutallyRootView(
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.scheduledDay),
      featureFlags: .development,
      router: AppRouter()
    )
  }

  #Preview("iPad · Routine · AX5", traits: .fixedLayout(width: 1_024, height: 768)) {
    RoutallyRootView(
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.thresholdWaiting),
      featureFlags: .development,
      router: routinePreviewRouter()
    )
    .environment(\.dynamicTypeSize, .accessibility5)
  }

  #Preview("iPad · Routine · Dark", traits: .fixedLayout(width: 768, height: 1_024)) {
    RoutallyRootView(
      store: RoutallyFeatureModel(previewSnapshot: PreviewFixtures.thresholdWaiting),
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
