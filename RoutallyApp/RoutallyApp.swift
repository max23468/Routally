import RoutallyDomain
import RoutallyFeatures
import SwiftUI

#if ROUTALLY_DEVELOPMENT
  import RoutallyFixtures
#endif

@main
@MainActor
struct RoutallyApp: App {
  @State private var store: RoutallyStore
  @State private var router = AppRouter()
  private let featureFlags: FeatureFlags

  init() {
    #if ROUTALLY_DEVELOPMENT
      let initialSnapshot = DemoFixtures.snapshot(
        arguments: ProcessInfo.processInfo.arguments
      )
      featureFlags = .development
    #else
      let initialSnapshot = RoutallySnapshot.empty
      featureFlags = .publicRelease
    #endif

    _store = State(initialValue: RoutallyStore(snapshot: initialSnapshot))
  }

  var body: some Scene {
    WindowGroup {
      RoutallyRootView(store: store, featureFlags: featureFlags, router: router)
    }
    .commands {
      RoutallyCommands(router: router)
    }
  }
}
