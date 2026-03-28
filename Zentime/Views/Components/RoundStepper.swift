import SwiftUI

struct RoundStepper: View {
    @Binding var rounds: Int
    let range: ClosedRange<Int>

    init(rounds: Binding<Int>, range: ClosedRange<Int> = 1...10) {
        self._rounds = rounds
        self.range = range
    }

    var body: some View {
        HStack(spacing: 20) {
            Button {
                if rounds > range.lowerBound {
                    rounds -= 1
                    HapticManager.impact(.light)
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ZentimeTheme.primaryText)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(ZentimeTheme.glassBackground)
                            .overlay(
                                Circle()
                                    .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
                            )
                    )
            }
            .disabled(rounds <= range.lowerBound)

            Text("Rounds: \(rounds)")
                .font(ZentimeTheme.bodyFont)
                .foregroundStyle(ZentimeTheme.primaryText)
                .frame(width: 100)

            Button {
                if rounds < range.upperBound {
                    rounds += 1
                    HapticManager.impact(.light)
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(ZentimeTheme.primaryText)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(ZentimeTheme.glassBackground)
                            .overlay(
                                Circle()
                                    .stroke(ZentimeTheme.glassBorder, lineWidth: 0.5)
                            )
                    )
            }
            .disabled(rounds >= range.upperBound)
        }
    }
}

#Preview {
    @Previewable @State var rounds = 4
    RoundStepper(rounds: $rounds)
        .padding()
        .background(ZentimeTheme.background)
        .preferredColorScheme(.dark)
}
