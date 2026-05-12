import SwiftUI

enum AppFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }

    static func title(_ size: CGFloat = 22) -> Font {
        Font.system(size: size, weight: .bold, design: .rounded)
    }

    static func body(_ size: CGFloat = 17, weight: Font.Weight = .medium) -> Font {
        Font.system(size: size, weight: weight, design: .rounded)
    }

    static func caption(_ size: CGFloat = 13) -> Font {
        Font.system(size: size, weight: .semibold, design: .rounded)
    }

    static func numeric(_ size: CGFloat) -> Font {
        Font.system(size: size, weight: .heavy, design: .rounded).monospacedDigit()
    }
}
