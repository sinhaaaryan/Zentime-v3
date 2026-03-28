import SwiftUI

enum ZentimeTheme {
    // MARK: - Colors
    static let background = Color.black
    static let cardBackground = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let cardBackgroundLighter = Color(red: 0.15, green: 0.15, blue: 0.15)
    static let primaryText = Color.white
    static let secondaryText = Color.gray
    static let accent = Color.white
    static let ringTrack = Color.white.opacity(0.15)
    static let ringProgress = Color.white

    // MARK: - Glass & Glow
    static let glassBackground = Color.white.opacity(0.06)
    static let glassBorder = Color.white.opacity(0.1)
    static let glowColor = Color.white.opacity(0.3)
    static let glowRadius: CGFloat = 12

    // MARK: - Fonts
    static let timerFont = Font.system(size: 48, weight: .light, design: .monospaced)
    static let titleFont = Font.system(size: 28, weight: .semibold)
    static let headlineFont = Font.system(size: 20, weight: .medium)
    static let bodyFont = Font.system(size: 16, weight: .regular)
    static let captionFont = Font.system(size: 14, weight: .regular)
    static let smallCaptionFont = Font.system(size: 12, weight: .regular)

    // MARK: - Layout
    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 12
    static let spacing: CGFloat = 16
    static let ringLineWidth: CGFloat = 8
    static let ringSize: CGFloat = 280

    // MARK: - Animation
    static let springResponse: Double = 0.5
    static let springDamping: Double = 0.75
    static let staggerDelay: Double = 0.08
}
