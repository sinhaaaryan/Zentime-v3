import SwiftUI

struct StreakCard: View {
    let streakDays: Int
    let weeklyGoal: Int
    let completedDays: [Bool] // M T W T F S S

    private let dayLabels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(spacing: 20) {
            // Circular streak counter
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 6)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0, to: CGFloat(min(Double(streakDays) / Double(max(weeklyGoal, 1)), 1.0)))
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 90, height: 90)
                    .shadow(color: .white.opacity(0.3), radius: 8)

                VStack(spacing: 2) {
                    Text("\(streakDays)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Days")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(.top, 8)

            // Weekly day indicators
            HStack(spacing: 12) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(completedDays[index] ? Color.white : Color.white.opacity(0.1))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.3), lineWidth: completedDays[index] ? 0 : 1)
                                )

                            if completedDays[index] {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                        }

                        Text(dayLabels[index])
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }

            // Motivational text
            Text("You've reached your goal with \(streakDays) days of Calm this week.\nKeep going!")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    StreakCard(
        streakDays: 3,
        weeklyGoal: 7,
        completedDays: [false, false, true, true, true, false, false]
    )
    .padding()
    .background(Color.black)
    .preferredColorScheme(.dark)
}
