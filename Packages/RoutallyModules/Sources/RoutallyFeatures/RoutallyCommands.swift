import SwiftUI

@MainActor
public struct RoutallyCommands: Commands {
  private let router: AppRouter

  public init(router: AppRouter) {
    self.router = router
  }

  public var body: some Commands {
    CommandMenu("Routally") {
      Button(L10n.text(.nuovaRoutine)) {
        router.showCreation()
      }
      .keyboardShortcut("n", modifiers: .command)

      Divider()

      Button(L10n.text(.oggi)) {
        router.select(.today)
      }
      .keyboardShortcut("1", modifiers: .command)

      Button(L10n.text(.routine)) {
        router.select(.routines)
      }
      .keyboardShortcut("2", modifiers: .command)

      Button(L10n.text(.esplora)) {
        router.select(.explore)
      }
      .keyboardShortcut("3", modifiers: .command)

      Button(L10n.text(.analisi)) {
        router.select(.insights)
      }
      .keyboardShortcut("4", modifiers: .command)

      Button(L10n.text(.cerca)) {
        router.select(.search)
      }
      .keyboardShortcut("f", modifiers: .command)

      Divider()

      Button(L10n.text(.profilo)) {
        router.showProfile()
      }
      .keyboardShortcut(",", modifiers: .command)
    }
  }
}
