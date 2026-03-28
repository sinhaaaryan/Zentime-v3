import SwiftUI

struct ContentView: View {
    @State private var viewModel = TimerViewModel()
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(viewModel: viewModel, navigationPath: $navigationPath)
                .navigationDestination(for: AppMode.self) { mode in
                    SetupView(mode: mode, viewModel: viewModel)
                }
        }
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $viewModel.showActiveTimer, onDismiss: {
            // When dismissed via X, pop to home
            if viewModel.isSessionActive {
                navigationPath = NavigationPath()
            }
        }) {
            ActiveTimerView(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
