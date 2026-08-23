import SwiftUI

@MainActor
public struct RoutallyCommands: Commands {
  private let router: AppRouter

  public init(router: AppRouter) {
    self.router = router
  }

  public var body: some Commands {
    CommandMenu("Routally") {
      Button(.nuovaRoutine) {
        router.showCreation()
      }
      .keyboardShortcut("n", modifiers: .command)

      Divider()

      Button(.oggi) {
        router.select(.today)
      }
      .keyboardShortcut("1", modifiers: .command)

      Button(.routine) {
        router.select(.routines)
      }
      .keyboardShortcut("2", modifiers: .command)

      Button(.esplora) {
        router.select(.explore)
      }
      .keyboardShortcut("3", modifiers: .command)

      Button(.analisi) {
        router.select(.insights)
      }
      .keyboardShortcut("4", modifiers: .command)

      Button(.cerca) {
        router.select(.search)
      }
      .keyboardShortcut("f", modifiers: .command)

      Divider()

      Button(.profilo) {
        router.showProfile()
      }
      .keyboardShortcut(",", modifiers: .command)
    }
  }
}
