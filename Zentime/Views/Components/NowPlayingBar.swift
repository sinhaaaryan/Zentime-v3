import SwiftUI

struct NowPlayingBar: View {
    var viewModel: TimerViewModel
    @State private var isAnimating = false

    var body: some View {
        Button {
            HapticManager.impact(.light)
            viewModel.showActiveTimer = true
        } label: {
            HStack(spacing: 14) {
                // Mode icon with pulsing ring
                ZStack {
                    Circle()
                        .fill(ZentimeTheme.cardBackgroundLighter)
                        .frame(width: 40, height: 40)

                    Image(systemName: viewModel.mode.iconName)
                        .font(.system(size: 18))
                        .foregroundStyle(ZentimeTheme.primaryText)

                    // Subtle animated ring around icon
                    Circle()
                        .stroke(ZentimeTheme.primaryText.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 40, height: 40)
                        .scaleEffect(isAnimating ? 1.15 : 1.0)
                        .opacity(isAnimating ? 0 : 0.6)
                }

                // Text info
                VStack(alignment: .leading, spacing: 2) {
                    Text("Playing \(viewModel.mode.title)")
                        .font(ZentimeTheme.bodyFont)
                        .foregroundStyle(ZentimeTheme.primaryText)
                        .lineLimit(1)

                    Text(viewModel.formattedTime)
                        .font(ZentimeTheme.smallCaptionFont)
                        .foregroundStyle(ZentimeTheme.secondaryText)
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
                        .foregroundStyle(ZentimeTheme.primaryText)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(ZentimeTheme.cardBackgroundLighter)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(ZentimeTheme.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
                    )
                    .shadow(color: Color.white.opacity(0.05), radius: 20, y: -5)
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
    let vm = TimerViewModel()
    vm.selectMode(.focus)
    vm.start()
    return NowPlayingBar(viewModel: vm)
        .padding()
        .background(ZentimeTheme.background)
        .preferredColorScheme(.dark)
}
