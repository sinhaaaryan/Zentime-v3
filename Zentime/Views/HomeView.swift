import SwiftUI

struct HomeView: View {
    var viewModel: TimerViewModel
    @Binding var navigationPath: NavigationPath
    @State private var appeared = false
    @State private var selectedMode: AppMode = .focus
    @State private var buttonScale: CGFloat = 1.0
    @State private var glowPulse = false
    @Environment(ThemeManager.self) private var themeManager

    // Mock streak data — replace with real persistence later
    private let streakDays = 3
    private let completedDays = [false, false, true, true, true, false, false]

    var body: some View {
        ZStack {
            // Galactic background
            Color.black.ignoresSafeArea()
            GalacticBackgroundLayer()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 50)

                        // Streak Card
                        StreakCard(
                            streakDays: streakDays,
                            weeklyGoal: 7,
                            completedDays: completedDays
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(
                            .spring(response: ZentimeTheme.springResponse, dampingFraction: ZentimeTheme.springDamping)
                            .delay(0.1),
                            value: appeared
                        )

                        // Start Focus Button
                        Button {
                            HapticManager.impact(.medium)
                            viewModel.selectMode(selectedMode)
                            navigationPath.append(selectedMode)
                        } label: {
                            Text("Start Focus")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 22)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: .white.opacity(glowPulse ? 0.25 : 0.1), radius: glowPulse ? 20 : 10)
                                )
                        }
                        .scaleEffect(buttonScale)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(
                            .spring(response: ZentimeTheme.springResponse, dampingFraction: ZentimeTheme.springDamping)
                            .delay(0.25),
                            value: appeared
                        )
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                        buttonScale = 0.96
                                    }
                                }
                                .onEnded { _ in
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                        buttonScale = 1.0
                                    }
                                }
                        )

                        // Mode Selector
                        VStack(spacing: 16) {
                            ModeSelector(selectedMode: $selectedMode)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 15)
                                .animation(
                                    .spring(response: ZentimeTheme.springResponse, dampingFraction: ZentimeTheme.springDamping)
                                    .delay(0.35),
                                    value: appeared
                                )

                            // Next Session
                            Text("Next Session \(nextSessionTime)")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.white.opacity(0.5))
                                .opacity(appeared ? 1 : 0)
                                .animation(
                                    .spring(response: ZentimeTheme.springResponse, dampingFraction: ZentimeTheme.springDamping)
                                    .delay(0.45),
                                    value: appeared
                                )
                        }

                        Spacer().frame(height: 40)
                    }
                    .padding(.horizontal, ZentimeTheme.spacing)
                }
                .scrollIndicators(.hidden)

                // Now Playing Bar (when session is active)
                if viewModel.isSessionActive {
                    VStack(spacing: 0) {
                        Divider()
                            .background(Color.white.opacity(0.1))

                        NowPlayingBar(viewModel: viewModel)
                            .padding(.horizontal, ZentimeTheme.spacing)
                            .padding(.vertical, 12)
                    }
                    .background(Color.black.opacity(0.8))
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isSessionActive)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            appeared = true
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
        }
    }

    // Compute a "next session" time based on current time rounded up to next hour
    private var nextSessionTime: String {
        let calendar = Calendar.current
        let now = Date()
        let nextHour = calendar.nextDate(after: now, matching: DateComponents(minute: 0), matchingPolicy: .nextTime) ?? now
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: nextHour)
    }
}

#Preview("Idle") {
    @Previewable @State var path = NavigationPath()
    HomeView(viewModel: TimerViewModel(), navigationPath: $path)
        .environment(ThemeManager.shared)
        .preferredColorScheme(.dark)
}

#Preview("Session Active") {
    @Previewable @State var path = NavigationPath()
    @Previewable @State var vm = TimerViewModel()
    HomeView(viewModel: vm, navigationPath: $path)
        .environment(ThemeManager.shared)
        .preferredColorScheme(.dark)
        .onAppear { vm.selectMode(.focus); vm.start() }
}
