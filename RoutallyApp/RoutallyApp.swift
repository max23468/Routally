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
  #if ROUTALLY_DEVELOPMENT
    @State private var tgDataCloudProbe: TGDataCloudProbeModel?
  #endif
  private let featureFlags: FeatureFlags

  init() {
    #if ROUTALLY_DEVELOPMENT
      let initialSnapshot = DemoFixtures.snapshot(
        arguments: ProcessInfo.processInfo.arguments
      )
      featureFlags = .development
      _tgDataCloudProbe = State(
        initialValue: TGDataCloudProbeConfiguration.current.map(TGDataCloudProbeModel.init)
      )
    #else
      let initialSnapshot = RoutallySnapshot.empty
      featureFlags = .publicRelease
    #endif

    _store = State(initialValue: RoutallyStore(snapshot: initialSnapshot))
  }

  var body: some Scene {
    WindowGroup {
      #if ROUTALLY_DEVELOPMENT
        if let tgDataCloudProbe {
          TGDataCloudProbeView(model: tgDataCloudProbe)
        } else {
          RoutallyRootView(store: store, featureFlags: featureFlags, router: router)
        }
      #else
        RoutallyRootView(store: store, featureFlags: featureFlags, router: router)
      #endif
    }
    .commands {
      RoutallyCommands(router: router)
    }
  }
}
