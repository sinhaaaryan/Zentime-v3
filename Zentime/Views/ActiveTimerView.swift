import SwiftUI

struct ActiveTimerView: View {
    @Bindable var viewModel: TimerViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var appeared = false
    @State private var isPulsing = false

    var body: some View {
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
                        .foregroundStyle(ZentimeTheme.secondaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(ZentimeTheme.glassBackground)
                                .overlay(
                                    Circle()
                                        .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
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
                .foregroundStyle(ZentimeTheme.secondaryText)
                .padding(.bottom, 8)
                .opacity(appeared ? 1 : 0)

            // Rounds display
            if viewModel.mode.hasRounds {
                Text(viewModel.roundsDisplay)
                    .font(ZentimeTheme.captionFont)
                    .foregroundStyle(ZentimeTheme.secondaryText)
                    .padding(.bottom, 16)
                    .opacity(appeared ? 1 : 0)
            }

            // Circular progress ring with timer
            ZStack {
                CircularProgressRing(progress: viewModel.progress)

                VStack(spacing: 4) {
                    Text(viewModel.formattedTime)
                        .font(ZentimeTheme.timerFont)
                        .foregroundStyle(ZentimeTheme.primaryText)
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
                        .foregroundStyle(ZentimeTheme.background)
                        .frame(width: 160, height: 56)
                        .background(ZentimeTheme.accent)
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
                            .foregroundStyle(ZentimeTheme.primaryText)
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(ZentimeTheme.glassBackground)
                                    .overlay(
                                        Circle()
                                            .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
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
                            .foregroundStyle(ZentimeTheme.background)
                            .frame(width: 72, height: 72)
                            .background(ZentimeTheme.accent)
                            .clipShape(Circle())
                    }

                    // Stop — actually stops timer and audio
                    Button {
                        HapticManager.notification(.warning)
                        viewModel.stop()
                    } label: {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(ZentimeTheme.primaryText)
                            .frame(width: 52, height: 52)
                            .background(
                                Circle()
                                    .fill(ZentimeTheme.glassBackground)
                                    .overlay(
                                        Circle()
                                            .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
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
        .background(ZentimeTheme.background)
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
    let vm = TimerViewModel()
    vm.selectMode(.focus)
    vm.start()
    return ActiveTimerView(viewModel: vm)
        .preferredColorScheme(.dark)
}

#Preview("Paused") {
    let vm = TimerViewModel()
    vm.selectMode(.focus)
    vm.start()
    vm.togglePause()
    return ActiveTimerView(viewModel: vm)
        .preferredColorScheme(.dark)
}
