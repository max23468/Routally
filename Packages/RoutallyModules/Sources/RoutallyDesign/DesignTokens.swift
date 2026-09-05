import SwiftUI

public enum RoutallyColor {
  public static let brandAccent = Color("brandAccent", bundle: .module)

  public static let causalSurface = Color(
    uiColor: UIColor { traits in
      traits.userInterfaceStyle == .dark
        ? UIColor(red: 0.10, green: 0.10, blue: 0.15, alpha: 1)
        : UIColor(red: 0.965, green: 0.963, blue: 0.985, alpha: 1)
    })

  public static let contentSecondary = Color.secondary
  public static let separator = Color(uiColor: .separator)
  public static let statusComplete = Color(uiColor: .systemGreen)
  public static let statusDue = brandAccent
  public static let statusAttention = Color(uiColor: .systemOrange)
}

public enum RoutallySpacing {
  public static let space4: CGFloat = 4
  public static let space8: CGFloat = 8
  public static let space12: CGFloat = 12
  public static let space16: CGFloat = 16
}

public enum RoutallyMotion {
  public static func animation(reduceMotion: Bool) -> Animation {
    reduceMotion ? .easeOut(duration: 0.12) : .smooth(duration: 0.24)
  }

  public static func reveal(
    from edge: Edge,
    reduceMotion: Bool
  ) -> AnyTransition {
    reduceMotion ? .opacity : .opacity.combined(with: .move(edge: edge))
  }

  public static func emphasis(reduceMotion: Bool) -> AnyTransition {
    reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.96))
  }
}

public enum RoutallyFont {
  public static let itemTitle = Font.body
  public static let itemContext = Font.subheadline
  public static let supporting = Font.footnote
  public static let cycleValue = Font.system(.title2, design: .rounded).monospacedDigit()
}
