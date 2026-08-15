import Foundation

enum L10n {
  static func text(_ key: String.LocalizationValue) -> String {
    String(localized: key, bundle: .module)
  }

  static func format(_ key: String.LocalizationValue, _ arguments: CVarArg...) -> String {
    String(format: text(key), locale: .current, arguments: arguments)
  }
}
