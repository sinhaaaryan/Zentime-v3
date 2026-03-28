import SwiftUI

struct HomeView: View {
    var viewModel: TimerViewModel
    @Binding var navigationPath: NavigationPath
    @State private var appeared = false
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        let theme = themeManager.currentPrototype

        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 60)

                    // Header row: title + theme switcher
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Zentime")
                                .font(ZentimeTheme.titleFont)
                                .foregroundStyle(theme.primaryText)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 15)

                            Text("Your mind, your time.")
                                .font(ZentimeTheme.captionFont)
                                .foregroundStyle(theme.secondaryText)
                                .opacity(appeared ? 1 : 0)
                                .offset(y: appeared ? 0 : 10)
                        }

                        Spacer()

                        ThemeSwitcherButton()
                            .opacity(appeared ? 1 : 0)
                            .animation(
                                .spring(response: ZentimeTheme.springResponse, dampingFraction: ZentimeTheme.springDamping)
                                .delay(0.15),
                                value: appeared
                            )
                    }
                    .padding(.horizontal, ZentimeTheme.spacing)
                    .padding(.bottom, 40)

                    VStack(spacing: 12) {
                        ForEach(Array(AppMode.allCases.enumerated()), id: \.element.id) { index, mode in
                            NavigationLink(value: mode) {
                                ThemedModeCard(mode: mode)
                            }
                            .buttonStyle(.plain)
                            .simultaneousGesture(TapGesture().onEnded {
                                HapticManager.impact(.light)
                            })
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(
                                .spring(response: ZentimeTheme.springResponse, dampingFraction: ZentimeTheme.springDamping)
                                .delay(Double(index) * ZentimeTheme.staggerDelay),
                                value: appeared
                            )
                        }
                    }
                    .padding(.horizontal, ZentimeTheme.spacing)

                    Spacer().frame(height: 40)
                }
            }
            .scrollIndicators(.hidden)

            if viewModel.isSessionActive {
                VStack(spacing: 0) {
                    Divider()
                        .background(theme.cardBorderColor)

                    NowPlayingBar(viewModel: viewModel)
                        .padding(.horizontal, ZentimeTheme.spacing)
                        .padding(.vertical, 12)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isSessionActive)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ThemedBackground(theme: theme))
        .onAppear {
            appeared = true
        }
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
    let vm = TimerViewModel()
    vm.selectMode(.focus)
    vm.start()
    return HomeView(viewModel: vm, navigationPath: $path)
        .environment(ThemeManager.shared)
        .preferredColorScheme(.dark)
}
