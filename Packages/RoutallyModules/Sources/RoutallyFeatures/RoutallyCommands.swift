import SwiftUI

@MainActor
public struct RoutallyCommands: Commands {
  private let router: AppRouter

  public init(router: AppRouter) {
    self.router = router
  }

  public var body: some Commands {
    CommandMenu("Routally") {
      Button(L10n.text("Nuova routine")) {
        router.showCreation()
      }
      .keyboardShortcut("n", modifiers: .command)

      Divider()

      Button(L10n.text("Oggi")) {
        router.select(.today)
      }
      .keyboardShortcut("1", modifiers: .command)

      Button(L10n.text("Routine")) {
        router.select(.routines)
      }
      .keyboardShortcut("2", modifiers: .command)

      Button(L10n.text("Esplora")) {
        router.select(.explore)
      }
      .keyboardShortcut("3", modifiers: .command)

      Button(L10n.text("Analisi")) {
        router.select(.insights)
      }
      .keyboardShortcut("4", modifiers: .command)

      Button(L10n.text("Cerca")) {
        router.select(.search)
      }
      .keyboardShortcut("f", modifiers: .command)

      Divider()

      Button(L10n.text("Profilo")) {
        router.showProfile()
      }
      .keyboardShortcut(",", modifiers: .command)
    }
  }
}
