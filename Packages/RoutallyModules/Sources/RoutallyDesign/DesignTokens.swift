import SwiftUI

public enum RoutallyColor {
  public static let brandAccent = Color("brandAccent", bundle: .module)

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

public enum RoutallyFont {
  public static let itemTitle = Font.body
  public static let itemContext = Font.subheadline
  public static let supporting = Font.footnote
  public static let cycleValue = Font.system(.title2, design: .rounded).monospacedDigit()
}
