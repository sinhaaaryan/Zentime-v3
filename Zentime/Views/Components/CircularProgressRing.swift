import SwiftUI

struct CircularProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat

    init(progress: Double, lineWidth: CGFloat = ZentimeTheme.ringLineWidth, size: CGFloat = ZentimeTheme.ringSize) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(ZentimeTheme.ringTrack, lineWidth: lineWidth)

            // Glow layer (behind progress)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    ZentimeTheme.ringProgress,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: ZentimeTheme.glowColor, radius: ZentimeTheme.glowRadius)
                .animation(.linear(duration: 0.1), value: progress)

            // Progress
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    ZentimeTheme.ringProgress,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.1), value: progress)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    CircularProgressRing(progress: 0.65)
        .padding()
        .background(ZentimeTheme.background)
        .preferredColorScheme(.dark)
}
