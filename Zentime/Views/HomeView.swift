import SwiftUI
import SwiftData

struct HomeView: View {
    var viewModel: TimerViewModel
    @Binding var navigationPath: NavigationPath
    @State private var selectedMode: AppMode = .focus
    @State private var buttonScale: CGFloat = 1.0
    @Environment(ThemeManager.self) private var themeManager
    @Query(sort: \CompletedSession.completedAt, order: .reverse) private var completedSessions: [CompletedSession]

    // Current week (Mon–Sun) completion flags derived from real session data
    private var weeklyCompletedDays: [Bool] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Find the Monday of the current week
        let weekday = calendar.component(.weekday, from: today) // 1=Sun, 2=Mon…
        let daysFromMonday = (weekday + 5) % 7
        guard let monday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) else {
            return Array(repeating: false, count: 7)
        }
        let sessionDates = Set(completedSessions.map { calendar.startOfDay(for: $0.completedAt) })
        return (0..<7).map { offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: monday) else { return false }
            return sessionDates.contains(day)
        }
    }

    // Consecutive-day streak ending today (or yesterday if no session today yet)
    private var streakDays: Int {
        let calendar = Calendar.current
        let sessionDates = Set(completedSessions.map { calendar.startOfDay(for: $0.completedAt) })
        var streak = 0
        var day = calendar.startOfDay(for: Date())
        while sessionDates.contains(day) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    var body: some View {
        ZStack {
            // Aurora background
            AuroraBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 50)

                        // Streak Card
                        StreakCard(
                            streakDays: streakDays,
                            weeklyGoal: 7,
                            completedDays: weeklyCompletedDays
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
                                        .shadow(color: .white.opacity(0.15), radius: 12)
                                )
                        }
                        .scaleEffect(buttonScale)
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

                            // Next Session
                            Text("Next Session \(nextSessionTime)")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(.white.opacity(0.5))
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
        .modelContainer(for: [CompletedSession.self, ScheduledSession.self], inMemory: true)
}

#Preview("Session Active") {
    @Previewable @State var path = NavigationPath()
    @Previewable @State var vm = TimerViewModel()
    HomeView(viewModel: vm, navigationPath: $path)
        .environment(ThemeManager.shared)
        .preferredColorScheme(.dark)
        .modelContainer(for: [CompletedSession.self, ScheduledSession.self], inMemory: true)
        .onAppear { vm.selectMode(.focus); vm.start() }
}
