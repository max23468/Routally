import Foundation

enum L10n {
  static func text(_ resource: LocalizedStringResource) -> String {
    String(localized: resource)
  }
}
