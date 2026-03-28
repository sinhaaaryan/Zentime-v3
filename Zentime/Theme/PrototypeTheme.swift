import SwiftUI

enum PrototypeTheme: String, CaseIterable, Identifiable {
    case classic, nebula, aurora, forge, sakura, matrix

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .classic: "Classic"
        case .nebula:  "Nebula"
        case .aurora:  "Aurora"
        case .forge:   "Forge"
        case .sakura:  "Sakura"
        case .matrix:  "Matrix"
        }
    }

    // MARK: - Background

    var backgroundColor: Color {
        switch self {
        case .classic: Color.black
        case .nebula:  Color(red: 0.04, green: 0.02, blue: 0.10)
        case .aurora:  Color(red: 0.02, green: 0.06, blue: 0.04)
        case .forge:   Color(red: 0.07, green: 0.04, blue: 0.02)
        case .sakura:  Color(red: 0.06, green: 0.05, blue: 0.05)
        case .matrix:  Color.black
        }
    }

    var hasAnimatedBackground: Bool {
        self != .classic
    }

    // MARK: - Cards

    var cardGlassFill: Color {
        switch self {
        case .classic: Color.white.opacity(0.06)
        case .nebula:  Color(red: 0.4, green: 0.2, blue: 0.8).opacity(0.08)
        case .aurora:  Color(red: 0.1, green: 0.8, blue: 0.5).opacity(0.07)
        case .forge:   Color(red: 0.9, green: 0.4, blue: 0.1).opacity(0.07)
        case .sakura:  Color(red: 0.9, green: 0.5, blue: 0.6).opacity(0.05)
        case .matrix:  Color(red: 0.0, green: 1.0, blue: 0.25).opacity(0.06)
        }
    }

    var cardBorderColor: Color {
        switch self {
        case .classic: Color.white.opacity(0.10)
        case .nebula:  Color(red: 0.6, green: 0.3, blue: 1.0).opacity(0.30)
        case .aurora:  Color(red: 0.2, green: 0.9, blue: 0.6).opacity(0.25)
        case .forge:   Color(red: 1.0, green: 0.5, blue: 0.1).opacity(0.25)
        case .sakura:  Color(red: 0.9, green: 0.6, blue: 0.7).opacity(0.20)
        case .matrix:  Color(red: 0.0, green: 1.0, blue: 0.25).opacity(0.30)
        }
    }

    var borderLineWidth: CGFloat {
        self == .sakura ? 0.3 : 0.5
    }

    var hasIridescentBorder: Bool {
        self == .nebula
    }

    // MARK: - Ring

    var ringGradient: LinearGradient {
        switch self {
        case .classic:
            LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom)
        case .nebula:
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.15, blue: 0.95),
                    Color(red: 0.65, green: 0.20, blue: 0.90),
                    Color(red: 0.95, green: 0.30, blue: 0.70)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .aurora:
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.85, blue: 0.80),
                    Color(red: 0.10, green: 0.90, blue: 0.45),
                    Color(red: 0.40, green: 1.00, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .forge:
            LinearGradient(
                colors: [
                    Color(red: 0.50, green: 0.15, blue: 0.00),
                    Color(red: 1.00, green: 0.45, blue: 0.05),
                    Color(red: 1.00, green: 0.85, blue: 0.55)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sakura:
            LinearGradient(
                colors: [
                    Color(red: 0.75, green: 0.40, blue: 0.55),
                    Color(red: 0.92, green: 0.60, blue: 0.72),
                    Color(red: 1.00, green: 0.85, blue: 0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .matrix:
            LinearGradient(
                colors: [Color(red: 0.0, green: 1.0, blue: 0.25)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    var ringGlowColor: Color {
        switch self {
        case .classic: Color.white.opacity(0.30)
        case .nebula:  Color.purple.opacity(0.55)
        case .aurora:  Color.cyan.opacity(0.45)
        case .forge:   Color.orange.opacity(0.55)
        case .sakura:  Color.pink.opacity(0.40)
        case .matrix:  Color(red: 0.0, green: 1.0, blue: 0.25).opacity(0.65)
        }
    }

    // MARK: - Text & Accent

    var primaryText: Color {
        switch self {
        case .classic, .aurora, .sakura, .forge: .white
        case .nebula:  Color(red: 0.92, green: 0.88, blue: 1.0)
        case .matrix:  Color(red: 0.0, green: 1.0, blue: 0.25)
        }
    }

    var secondaryText: Color {
        switch self {
        case .classic, .aurora, .sakura, .forge: .gray
        case .nebula:  Color(red: 0.60, green: 0.50, blue: 0.80)
        case .matrix:  Color(red: 0.0, green: 0.60, blue: 0.15)
        }
    }

    var accentColor: Color {
        switch self {
        case .classic: .white
        case .nebula:  Color(red: 0.55, green: 0.20, blue: 0.90)
        case .aurora:  Color(red: 0.10, green: 0.80, blue: 0.50)
        case .forge:   Color(red: 0.95, green: 0.50, blue: 0.10)
        case .sakura:  Color(red: 0.85, green: 0.45, blue: 0.60)
        case .matrix:  Color(red: 0.0, green: 1.0, blue: 0.25)
        }
    }

    var accentForeground: Color {
        switch self {
        case .classic, .matrix: .black
        case .nebula, .aurora, .forge, .sakura: .white
        }
    }

    // MARK: - Typography

    var timerFont: Font {
        switch self {
        case .sakura: .system(size: 48, weight: .thin, design: .monospaced)
        case .matrix: .system(size: 48, weight: .regular, design: .monospaced)
        default:      .system(size: 48, weight: .light, design: .monospaced)
        }
    }

    // MARK: - Swatch Preview Gradient

    var swatchGradient: LinearGradient {
        ringGradient
    }
}
