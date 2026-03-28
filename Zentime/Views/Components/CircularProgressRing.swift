import SwiftUI

struct CircularProgressRing: View {
    let progress: Double
    let progressStyle: AnyShapeStyle
    let trackColor: Color
    let glowColor: Color
    let lineWidth: CGFloat
    let size: CGFloat

    init(
        progress: Double,
        progressStyle: AnyShapeStyle = AnyShapeStyle(Color.white),
        trackColor: Color = ZentimeTheme.ringTrack,
        glowColor: Color = ZentimeTheme.glowColor,
        lineWidth: CGFloat = ZentimeTheme.ringLineWidth,
        size: CGFloat = ZentimeTheme.ringSize
    ) {
        self.progress = progress
        self.progressStyle = progressStyle
        self.trackColor = trackColor
        self.glowColor = glowColor
        self.lineWidth = lineWidth
        self.size = size
    }

    var body: some View {
        ZStack {
            // Track
            Circle()
                .stroke(trackColor, lineWidth: lineWidth)

            // Glow layer (behind progress)
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    progressStyle,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: glowColor, radius: ZentimeTheme.glowRadius)
                .animation(.linear(duration: 0.1), value: progress)

            // Progress
            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    progressStyle,
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
