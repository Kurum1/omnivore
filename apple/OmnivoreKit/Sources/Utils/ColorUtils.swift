import SwiftUI

public extension Color {
  /// Inititializes a `Color` from a hex value
  /// - Parameter hex: Color hex value. ex: `#FFFFFF`
  ///
  init?(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

    var rgb: UInt64 = 0

    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 1.0

    let length = hexSanitized.count

    guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

    if length == 6 {
      red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
      green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
      blue = CGFloat(rgb & 0x0000FF) / 255.0
    } else if length == 8 {
      red = CGFloat((rgb & 0xFF00_0000) >> 24) / 255.0
      green = CGFloat((rgb & 0x00FF_0000) >> 16) / 255.0
      blue = CGFloat((rgb & 0x0000_FF00) >> 8) / 255.0
      alpha = CGFloat(rgb & 0x0000_00FF) / 255.0

    } else {
      return nil
    }

    self.init(red: red, green: green, blue: blue, opacity: alpha)
  }

  var hex: String? {
    if let hexValue = toHex() {
      return "#\(hexValue)"
    } else {
      return nil
    }
  }

  private func toHex() -> String? {
    #if os(iOS)
      guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
        return nil
      }
    #endif

    #if os(macOS)
      guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
        return nil
      }
    #endif
    let red = Float(components[0])
    let green = Float(components[1])
    let blue = Float(components[2])

    return String(
      format: "%02lX%02lX%02lX",
      lroundf(red * 255),
      lroundf(green * 255),
      lroundf(blue * 255)
    )
  }

  // TODO: remove this?
  var isDark: Bool {
    guard let lum = luminance else { return false }
    return lum < 0.50
  }

  var luminance: Float? {
    #if os(iOS)
      guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
        return nil
      }
    #endif

    #if os(macOS)
      guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
        return nil
      }
    #endif

    return 0.2126 * Float(components[0]) + 0.7152 * Float(components[1]) + 0.0722 * Float(components[2])
  }

  static var isDarkMode: Bool {
    #if os(iOS)
      UITraitCollection.current.userInterfaceStyle == .dark
    #else
      NSApp.effectiveAppearance.name == NSAppearance.Name.darkAqua
    #endif
  }

  static func lighten(color: Color, by percentage: CGFloat) -> Color {
    if let lightenedUIColor = UIColor(color).adjust(by: abs(percentage)) {
      return Color(lightenedUIColor)
    } else {
      return color
    }
  }
}

extension UIColor {
  func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
    adjust(by: abs(percentage))
  }

  func darker(by percentage: CGFloat = 30.0) -> UIColor? {
    adjust(by: -1 * abs(percentage))
  }

  func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
    var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
    if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
      return UIColor(red: min(red + percentage / 100, 1.0),
                     green: min(green + percentage / 100, 1.0),
                     blue: min(blue + percentage / 100, 1.0),
                     alpha: alpha)
    } else {
      return nil
    }
  }
}
