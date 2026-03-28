import SwiftUI

struct TimePickerSheet: View {
    @Binding var config: TimerConfig
    let mode: AppMode
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(mode.hasBreaks ? "Focus Duration" : "Duration")
                        .font(ZentimeTheme.bodyFont)
                        .foregroundStyle(ZentimeTheme.secondaryText)

                    HStack {
                        Slider(
                            value: Binding(
                                get: { Double(config.focusMinutes) },
                                set: { config.focusMinutes = Int($0) }
                            ),
                            in: 5...120,
                            step: 5
                        )
                        .tint(ZentimeTheme.accent)

                        Text("\(config.focusMinutes) min")
                            .font(ZentimeTheme.bodyFont)
                            .foregroundStyle(ZentimeTheme.primaryText)
                            .frame(width: 70, alignment: .trailing)
                    }
                }

                if mode.hasBreaks {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Break Duration")
                            .font(ZentimeTheme.bodyFont)
                            .foregroundStyle(ZentimeTheme.secondaryText)

                        HStack {
                            Slider(
                                value: Binding(
                                    get: { Double(config.breakMinutes) },
                                    set: { config.breakMinutes = Int($0) }
                                ),
                                in: 1...30,
                                step: 1
                            )
                            .tint(ZentimeTheme.accent)

                            Text("\(config.breakMinutes) min")
                                .font(ZentimeTheme.bodyFont)
                                .foregroundStyle(ZentimeTheme.primaryText)
                                .frame(width: 70, alignment: .trailing)
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(ZentimeTheme.background)
            .navigationTitle("Set Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(ZentimeTheme.primaryText)
                }
            }
        }
    }
}

#Preview("With Breaks") {
    @Previewable @State var config = TimerConfig.defaultConfig(for: .focus)
    TimePickerSheet(config: $config, mode: .focus)
        .preferredColorScheme(.dark)
}

#Preview("No Breaks") {
    @Previewable @State var config = TimerConfig.defaultConfig(for: .sleep)
    TimePickerSheet(config: $config, mode: .sleep)
        .preferredColorScheme(.dark)
}
