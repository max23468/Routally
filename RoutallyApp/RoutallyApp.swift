import Foundation
import RoutallyData
import RoutallyDomain
import RoutallyFeatures
import SwiftUI

#if ROUTALLY_DEVELOPMENT
  import RoutallyFixtures
#endif

@main
@MainActor
struct RoutallyApp: App {
  @State private var store: RoutallyFeatureModel
  @State private var router = AppRouter()
  private let developerDiagnosticsEnabled: Bool

  init() {
    #if ROUTALLY_DEVELOPMENT
      developerDiagnosticsEnabled = true
      let arguments = ProcessInfo.processInfo.arguments
      if DesignReviewScenario.requested(arguments: arguments) != nil {
        _store = State(initialValue: RoutallyFeatureModel(previewSnapshot: .empty))
      } else if let demo = DemoFixtures.verticalSliceSeed(arguments: arguments) {
        do {
          let persistence = try SwiftDataRoutallyStore(configuration: .inMemory())
          _store = State(
            initialValue: RoutallyFeatureModel(
              persistence: persistence,
              seed: RoutallyFeatureSeed(
                catalog: demo.catalog,
                ledger: demo.ledger,
                asOf: demo.asOf
              ),
              calendar: demo.calendar,
              clock: .fixed(demo.asOf)
            )
          )
        } catch {
          _store = State(
            initialValue: RoutallyFeatureModel(previewSnapshot: Self.failureSnapshot)
          )
        }
      } else if arguments.contains("demo") {
        _store = State(
          initialValue: RoutallyFeatureModel(
            previewSnapshot: DemoFixtures.snapshot(arguments: arguments)
          )
        )
      } else {
        _store = State(initialValue: Self.makePersistentFeatureModel())
      }
    #else
      developerDiagnosticsEnabled = false
      _store = State(initialValue: Self.makePersistentFeatureModel())
    #endif
  }

  var body: some Scene {
    WindowGroup {
      #if ROUTALLY_DEVELOPMENT
        if let scenario = DesignReviewScenario.requested(
          arguments: ProcessInfo.processInfo.arguments
        ) {
          TramaDesignReview(scenario: scenario)
        } else {
          appContent
        }
      #else
        appContent
      #endif
    }
    .commands {
      RoutallyCommands(router: router)
    }
  }

  private var appContent: some View {
    RoutallyRootView(
      store: store,
      developerDiagnosticsEnabled: developerDiagnosticsEnabled,
      router: router
    )
  }

  private static var failureSnapshot: RoutallySnapshot {
    RoutallySnapshot(hasRecoverableEventError: true)
  }

  private static func makePersistentFeatureModel() -> RoutallyFeatureModel {
    RoutallyFeatureModel(persistenceFactory: makePersistentStore)
  }

  private static func makePersistentStore() throws -> any RoutallyStore {
    let directory = URL.applicationSupportDirectory.appending(
      path: "Routally",
      directoryHint: .isDirectory
    )
    try FileManager.default.createDirectory(
      at: directory,
      withIntermediateDirectories: true
    )
    return try SwiftDataRoutallyStore(
      configuration: .local(
        url: directory.appending(path: RoutallySchemaV1.localStoreFilename)
      )
    )
  }
}
