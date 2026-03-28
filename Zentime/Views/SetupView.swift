import SwiftUI

struct SetupView: View {
    let mode: AppMode
    @Bindable var viewModel: TimerViewModel
    @State private var showTimePicker = false
    @State private var appeared = false
    @State private var taskText = ""

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 20)

            // Icon + Title
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(ZentimeTheme.primaryText)

                Text(mode.title)
                    .font(ZentimeTheme.titleFont)
                    .foregroundStyle(ZentimeTheme.primaryText)

                Spacer()
            }
            .padding(.horizontal, ZentimeTheme.spacing)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer().frame(height: 24)

            // "What's getting done?" prompt for focus/deepWork
            if mode == .focus || mode == .deepWork {
                TextField("What's getting done?", text: $taskText)
                    .font(ZentimeTheme.bodyFont)
                    .foregroundStyle(ZentimeTheme.primaryText)
                    .tint(ZentimeTheme.primaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                            .fill(ZentimeTheme.glassBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                                    .stroke(ZentimeTheme.glassBorder, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, ZentimeTheme.spacing)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)

                Spacer().frame(height: 12)
            }

            // Timer summary card
            Button {
                showTimePicker = true
                HapticManager.selection()
            } label: {
                HStack(alignment: .center, spacing: 0) {
                    // Focus time
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(viewModel.config.focusMinutes)")
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(ZentimeTheme.primaryText)
                            Text("min")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(ZentimeTheme.primaryText)
                        }
                        Text(mode.hasBreaks ? "Focus" : "Duration")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(ZentimeTheme.secondaryText)
                    }

                    if mode.hasBreaks {
                        Spacer().frame(width: 20)

                        // Break time
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(viewModel.config.breakMinutes)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundStyle(ZentimeTheme.primaryText)
                                Text("min")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(ZentimeTheme.primaryText)
                            }
                            Text("Short Break")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(ZentimeTheme.secondaryText)
                        }
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ZentimeTheme.secondaryText)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                        .fill(ZentimeTheme.glassBackground)
                        .overlay(
                            RoundedRectangle(cornerRadius: ZentimeTheme.cardCornerRadius)
                                .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, ZentimeTheme.spacing)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            Spacer()

            // Rounds stepper (focus & deep work)
            if mode.hasRounds {
                RoundStepper(rounds: $viewModel.config.rounds)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)

                Spacer().frame(height: 16)
            }

            // Start button
            Button {
                HapticManager.impact(.medium)
                viewModel.start()
            } label: {
                Text("Start")
                    .font(ZentimeTheme.headlineFont)
                    .foregroundStyle(ZentimeTheme.background)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(ZentimeTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: ZentimeTheme.buttonCornerRadius))
            }
            .padding(.horizontal, ZentimeTheme.spacing)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)

            // Summary caption
            if mode.hasRounds {
                Text("\(viewModel.config.rounds) × Focus Time + \(viewModel.config.rounds) × Short Break")
                    .font(ZentimeTheme.smallCaptionFont)
                    .foregroundStyle(ZentimeTheme.secondaryText)
                    .padding(.top, 8)
                    .opacity(appeared ? 1 : 0)
            }

            Spacer().frame(height: 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ZentimeTheme.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showTimePicker) {
            TimePickerSheet(config: $viewModel.config, mode: mode)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            viewModel.selectMode(mode)
            withAnimation(.spring(response: ZentimeTheme.springResponse, dampingFraction: ZentimeTheme.springDamping)) {
                appeared = true
            }
        }
    }
}

#Preview("Focus") {
    SetupView(mode: .focus, viewModel: TimerViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Deep Work") {
    SetupView(mode: .deepWork, viewModel: TimerViewModel())
        .preferredColorScheme(.dark)
}
