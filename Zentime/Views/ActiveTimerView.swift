import SwiftUI

struct ActiveTimerView: View {
    @Bindable var viewModel: TimerViewModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ThemeManager.self) private var themeManager
    @State private var appeared = false
    @State private var isPulsing = false

    var body: some View {
        let theme = themeManager.currentPrototype

        VStack(spacing: 0) {
            // Close button — dismisses without stopping audio
            HStack {
                Spacer()
                Button {
                    HapticManager.impact(.light)
                    viewModel.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(theme.secondaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(theme.cardGlassFill)
                                .overlay(
                                    Circle()
                                        .stroke(theme.cardBorderColor, lineWidth: 0.5)
                                )
                        )
                }
            }
            .padding(.horizontal, ZentimeTheme.spacing)
            .padding(.top, 16)

            Spacer()

            // Phase label
            Text(viewModel.phase.label)
                .font(ZentimeTheme.headlineFont)
                .foregroundStyle(theme.secondaryText)
                .padding(.bottom, 8)
                .opacity(appeared ? 1 : 0)

            // Rounds display
            if viewModel.mode.hasRounds {
                Text(viewModel.roundsDisplay)
                    .font(ZentimeTheme.captionFont)
                    .foregroundStyle(theme.secondaryText)
                    .padding(.bottom, 16)
                    .opacity(appeared ? 1 : 0)
            }

            // Circular progress ring with timer
            ZStack {
                // Nebula: extra orb glow behind ring
                if theme == .nebula {
                    Ellipse()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.50, green: 0.10, blue: 0.90).opacity(0.40),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 160
                            )
                        )
                        .frame(width: 320, height: 320)
                        .blur(radius: 45)
                        .scaleEffect(isPulsing ? 1.08 : 0.95)
                }

                CircularProgressRing(
                    progress: viewModel.progress,
                    progressStyle: AnyShapeStyle(theme.ringGradient),
                    glowColor: theme.ringGlowColor
                )
                .id(theme.rawValue)  // force re-render on theme change

                // Sakura: blossom watermark
                if theme == .sakura {
                    Text("✿")
                        .font(.system(size: 180))
                        .foregroundStyle(Color(red: 0.90, green: 0.55, blue: 0.70))
                        .opacity(0.04)
                        .allowsHitTesting(false)
                }

                VStack(spacing: 4) {
                    Text(viewModel.formattedTime)
                        .font(theme.timerFont)
                        .foregroundStyle(theme.primaryText)
                        .contentTransition(.numericText())
                }
            }
            .scaleEffect(isPulsing ? 1.02 : 1.0)
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1.0 : 0.9)

            Spacer()

            // Controls
            if viewModel.phase == .finished {
                Button {
                    HapticManager.impact(.medium)
                    viewModel.stop()
                } label: {
                    Text("Done")
                        .font(ZentimeTheme.headlineFont)
                        .foregroundStyle(theme.accentForeground)
                        .frame(width: 160, height: 56)
                        .background(theme.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: ZentimeTheme.buttonCornerRadius))
                }
                .padding(.bottom, 60)
                .opacity(appeared ? 1 : 0)
            } else {
                HStack(spacing: 40) {
                    // Reset
                    Button {
                        HapticManager.impact(.medium)
                        viewModel.stop()
                        viewModel.start()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .foregroundStyle(theme.primaryText)
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(theme.cardGlassFill)
                                    .overlay(
                                        Circle()
                                            .stroke(theme.cardBorderColor, lineWidth: 0.5)
                                    )
                            )
                    }

                    // Pause / Resume
                    Button {
                        HapticManager.impact(.medium)
                        viewModel.togglePause()
                    } label: {
                        Image(systemName: pauseIcon)
                            .font(.system(size: 24))
                            .foregroundStyle(theme.accentForeground)
                            .frame(width: 72, height: 72)
                            .background(theme.accentColor)
                            .clipShape(Circle())
                    }

                    // Stop — actually stops timer and audio
                    Button {
                        HapticManager.notification(.warning)
                        viewModel.stop()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(theme.primaryText)
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(theme.cardGlassFill)
                                    .overlay(
                                        Circle()
                                            .stroke(theme.cardBorderColor, lineWidth: 0.5)
                                    )
                            )
                    }
                }
                .padding(.bottom, 60)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            ZStack {
                if theme == .classic {
                    Color.black.ignoresSafeArea()
                    AuroraBackgroundView(isActive: true)
                        .ignoresSafeArea()
                } else {
                    ThemedBackground(theme: theme)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: ZentimeTheme.springResponse, dampingFraction: ZentimeTheme.springDamping)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
        .onDisappear {
            appeared = false
            isPulsing = false
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background {
                viewModel.handleBackgrounding()
            } else if newPhase == .active && oldPhase == .background {
                viewModel.handleForegrounding()
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

#Preview("Running") {
    @Previewable @State var vm = TimerViewModel()
    ActiveTimerView(viewModel: vm)
        .environment(ThemeManager.shared)
        .preferredColorScheme(.dark)
        .onAppear { vm.selectMode(.focus); vm.start() }
}

#Preview("Paused") {
    @Previewable @State var vm = TimerViewModel()
    ActiveTimerView(viewModel: vm)
        .environment(ThemeManager.shared)
        .preferredColorScheme(.dark)
        .onAppear { vm.selectMode(.focus); vm.start(); vm.togglePause() }
}
