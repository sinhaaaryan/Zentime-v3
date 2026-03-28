import SwiftUI

struct ContentView: View {
    @State private var viewModel = TimerViewModel()
    @State private var navigationPath = NavigationPath()
    private let themeManager = ThemeManager.shared

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(viewModel: viewModel, navigationPath: $navigationPath)
                .navigationDestination(for: AppMode.self) { mode in
                    SetupView(mode: mode, viewModel: viewModel)
                        .environment(themeManager)
                }
        }
        .environment(themeManager)
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $viewModel.showActiveTimer, onDismiss: {
            // When dismissed via X, pop to home
            if viewModel.isSessionActive {
                navigationPath = NavigationPath()
            }
        }) {
            ActiveTimerView(viewModel: viewModel)
                .environment(themeManager)  // fullScreenCover breaks env propagation — must re-inject
        }
    }
}

#Preview {
    ContentView()
}
