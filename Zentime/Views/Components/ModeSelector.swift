import SwiftUI

struct ModeSelector: View {
    @Binding var selectedMode: AppMode
    @State private var isExpanded = false

    var body: some View {
        Menu {
            ForEach(AppMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedMode = mode
                    }
                    HapticManager.impact(.light)
                } label: {
                    Label(mode.title, systemImage: mode.iconName)
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: selectedMode.iconName)
                    .font(.system(size: 14, weight: .medium))

                Text(selectedMode.title)
                    .font(.system(size: 16, weight: .semibold))

                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 10, weight: .bold))
            }
            .foregroundStyle(.black)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.white)
            )
        }
    }
}

#Preview {
    @Previewable @State var mode: AppMode = .focus
    ModeSelector(selectedMode: $mode)
        .padding()
        .background(Color.black)
        .preferredColorScheme(.dark)
}
