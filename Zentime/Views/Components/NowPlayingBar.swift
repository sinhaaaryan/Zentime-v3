import SwiftUI

struct NowPlayingBar: View {
    var viewModel: TimerViewModel
    @State private var isAnimating = false
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        let theme = themeManager.currentPrototype

        Button {
            HapticManager.impact(.light)
            viewModel.showActiveTimer = true
        } label: {
            HStack(spacing: 14) {
                // Mode icon with pulsing ring
                ZStack {
                    Circle()
                        .fill(theme.cardGlassFill.opacity(2))
                        .frame(width: 40, height: 40)

                    Image(systemName: viewModel.mode.iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(theme.primaryText)

                    // Subtle animated ring around icon
                    Circle()
                        .stroke(theme.accentColor.opacity(0.5), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                        .scaleEffect(isAnimating ? 1.15 : 1.0)
                        .opacity(isAnimating ? 0 : 0.6)
                }

                // Text info
                VStack(alignment: .leading, spacing: 2) {
                    Text("Playing \(viewModel.mode.title)")
                        .font(ZentimeTheme.bodyFont)
                        .foregroundStyle(theme.primaryText)
                        .lineLimit(1)

                    Text(viewModel.formattedTime)
                        .font(ZentimeTheme.smallCaptionFont)
                        .foregroundStyle(theme.secondaryText)
                        .monospacedDigit()
                }

                Spacer()

                // Play/Pause button
                Button {
                    HapticManager.impact(.light)
                    viewModel.togglePause()
                } label: {
                    Image(systemName: pauseIcon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(theme.primaryText)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(theme.cardGlassFill.opacity(2))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.cardGlassFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(theme.cardBorderColor, lineWidth: 0.5)
                    )
                    .shadow(color: theme.accentColor.opacity(0.08), radius: 20, y: -5)
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.easeOut(duration: 1.8).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }

    private var pauseIcon: String {
        if case .paused = viewModel.phase {
            return "play.fill"
        }
        return "pause.fill"
    }
}

#Preview {
    @Previewable @State var vm = TimerViewModel()
    NowPlayingBar(viewModel: vm)
        .padding()
        .background(ZentimeTheme.background)
        .environment(ThemeManager.shared)
        .preferredColorScheme(.dark)
        .onAppear { vm.selectMode(.focus); vm.start() }
}
