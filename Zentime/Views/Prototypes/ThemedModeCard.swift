import SwiftUI

struct ThemedModeCard: View {
    let mode: AppMode
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        let theme = themeManager.currentPrototype

        HStack(spacing: 16) {
            Image(systemName: mode.iconName)
                .font(.system(size: 24))
                .foregroundStyle(theme.primaryText)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(theme.cardGlassFill.opacity(2))
                        .overlay(
                            Circle()
                                .stroke(theme.cardBorderColor, lineWidth: theme.borderLineWidth)
                        )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                    .font(ZentimeTheme.headlineFont)
                    .foregroundStyle(theme.primaryText)

                Text(mode.subtitle)
                    .font(ZentimeTheme.captionFont)
                    .foregroundStyle(theme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(theme.secondaryText.opacity(0.6))
        }
        .padding(ZentimeTheme.spacing)
        .background(
            RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                .fill(theme.cardGlassFill)
                .overlay(
                    RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                        .stroke(theme.cardBorderColor, lineWidth: theme.borderLineWidth)
                )
        )
        .overlay {
            if theme.hasIridescentBorder {
                RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                    .stroke(
                        AngularGradient(
                            colors: [.purple, .pink, .blue, .indigo, .purple],
                            center: .center
                        ),
                        lineWidth: 0.5
                    )
                    .opacity(0.45)
            }
        }
    }
}
