import SwiftUI

public enum RoutallyColor {
  public static let brandAccent = Color("brandAccent", bundle: .module)
  public static let accentOcean = Color("accentOcean", bundle: .module)
  public static let accentTeal = Color("accentTeal", bundle: .module)
  public static let accentAmber = Color("accentAmber", bundle: .module)
  public static let accentCoral = Color("accentCoral", bundle: .module)
  public static let accentViolet = Color("accentViolet", bundle: .module)

  public static let contentPrimary = Color.primary
  public static let contentSecondary = Color.secondary
  public static let surfacePrimary = Color(uiColor: .systemBackground)
  public static let surfaceGrouped = Color(uiColor: .systemGroupedBackground)
  public static let surfaceRaised = Color(uiColor: .secondarySystemBackground)
  public static let separator = Color(uiColor: .separator)
  public static let statusComplete = Color(uiColor: .systemGreen)
  public static let statusUpcoming = Color.secondary
  public static let statusDue = brandAccent
  public static let statusAttention = Color(uiColor: .systemOrange)
  public static let statusDestructive = Color(uiColor: .systemRed)
}

public enum RoutallySpacing {
  public static let space4: CGFloat = 4
  public static let space8: CGFloat = 8
  public static let space12: CGFloat = 12
  public static let space16: CGFloat = 16
  public static let space24: CGFloat = 24
  public static let space32: CGFloat = 32
}

public enum RoutallyRadius {
  public static let radius16: CGFloat = 16
}

public enum RoutallyFont {
  public static let screenTitle = Font.largeTitle
  public static let sectionTitle = Font.headline
  public static let itemTitle = Font.body
  public static let itemContext = Font.subheadline
  public static let supporting = Font.footnote
  public static let cycleValue = Font.system(.title2, design: .rounded).monospacedDigit()
}
