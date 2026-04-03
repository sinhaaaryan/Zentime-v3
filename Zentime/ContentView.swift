import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var viewModel = TimerViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var selectedTab = 0
    private let themeManager = ThemeManager.shared
    private let notificationService = NotificationService.shared

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationStack(path: $navigationPath) {
                HomeView(viewModel: viewModel, navigationPath: $navigationPath)
                    .navigationDestination(for: AppMode.self) { mode in
                        SetupView(mode: mode, viewModel: viewModel)
                            .environment(themeManager)
                    }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            // Plan Tab
            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "moon.stars.fill")
                }
                .tag(1)
        }
        .environment(themeManager)
        .environment(notificationService)
        .preferredColorScheme(.dark)
        .tint(.white)
        .fullScreenCover(isPresented: $viewModel.showActiveTimer, onDismiss: {
            if viewModel.isSessionActive {
                navigationPath = NavigationPath()
            }
        }) {
            ActiveTimerView(viewModel: viewModel)
                .environment(themeManager)
        }
        .onAppear {
            styleTabBar()
            // Wire completion callback to write CompletedSession
            viewModel.onSessionComplete = { [self] modeRaw, durationMinutes in
                let session = CompletedSession(mode: modeRaw, durationMinutes: durationMinutes)
                modelContext.insert(session)
            }
            // Request notification permission on first launch
            Task { await notificationService.requestPermission() }
        }
    }

    private func styleTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.4)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ScheduledSession.self, CompletedSession.self], inMemory: true)
}
