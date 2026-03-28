import SwiftUI

struct ModeCard: View {
    let mode: AppMode

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: mode.iconName)
                .font(.system(size: 24))
                .foregroundStyle(ZentimeTheme.primaryText)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(ZentimeTheme.cardBackgroundLighter)
                        .overlay(
                            Circle()
                                .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
                        )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title)
                    .font(ZentimeTheme.headlineFont)
                    .foregroundStyle(ZentimeTheme.primaryText)

                Text(mode.subtitle)
                    .font(ZentimeTheme.captionFont)
                    .foregroundStyle(ZentimeTheme.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(ZentimeTheme.secondaryText.opacity(0.6))
        }
        .padding(ZentimeTheme.spacing)
        .background(
            RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                .fill(ZentimeTheme.glassBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                        .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    ModeCard(mode: .focus)
        .padding()
        .background(ZentimeTheme.background)
        .preferredColorScheme(.dark)
}
