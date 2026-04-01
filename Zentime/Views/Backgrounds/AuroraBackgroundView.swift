import SwiftUI

// MARK: - Star model

private struct Star {
    let x: CGFloat        // 0–1 normalized
    let y: CGFloat        // 0–1 normalized
    let radius: CGFloat   // pt
    let baseOpacity: Double
    let phase: Double
    let twinkleFreq: Double
}

// MARK: - AuroraBackgroundView

struct AuroraBackgroundView: View {
    /// Pass true on the active-timer screen for slightly more intense aurora.
    var isActive: Bool = false

    @State private var stars: [Star] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                ZStack {
                    // Layer 1: Metal aurora shader
                    // Color.black provides opaque pixels for the shader to operate on
                    Color.black
                        .colorEffect(
                            ShaderLibrary.auroraEffect(
                                .float2(geo.size),
                                .float(Float(t) * (isActive ? 1.25 : 1.0))
                            )
                        )

                    // Layer 2: Star field
                    Canvas { context, size in
                        drawStars(context: &context, size: size, time: t)
                    }
                }
                .drawingGroup()
                .onAppear {
                    generateStars(in: geo.size)
                }
            }
        }
    }

    // MARK: - Star generation

    private func generateStars(in size: CGSize) {
        let count = isActive ? 100 : 150
        stars = (0..<count).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                radius: CGFloat.random(in: 0.3...1.6),
                baseOpacity: Double.random(in: 0.20...0.75),
                phase: Double.random(in: 0...(2 * .pi)),
                twinkleFreq: Double.random(in: 0.3...1.0)
            )
        }
    }

    // MARK: - Star drawing

    private func drawStars(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        for star in stars {
            let twinkle = (sin(time * star.twinkleFreq + star.phase) + 1.0) / 2.0
            let opacity = star.baseOpacity * (0.15 + 0.85 * twinkle)
            context.opacity = opacity

            let sx = star.x * size.width
            let sy = star.y * size.height
            let r  = star.radius
            context.fill(
                Path(ellipseIn: CGRect(x: sx - r, y: sy - r, width: r * 2, height: r * 2)),
                with: .color(.white)
            )

            // Diffraction cross for larger bright stars
            if r > 1.1 && opacity > 0.5 {
                context.opacity = opacity * 0.25
                var h = Path()
                h.move(to: CGPoint(x: sx - r * 3.5, y: sy))
                h.addLine(to: CGPoint(x: sx + r * 3.5, y: sy))
                var v = Path()
                v.move(to: CGPoint(x: sx, y: sy - r * 3.5))
                v.addLine(to: CGPoint(x: sx, y: sy + r * 3.5))
                context.stroke(h, with: .color(Color(red: 0.8, green: 0.85, blue: 1.0)), lineWidth: 0.4)
                context.stroke(v, with: .color(Color(red: 0.8, green: 0.85, blue: 1.0)), lineWidth: 0.4)
            }
        }
    }
}

#Preview {
    AuroraBackgroundView()
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
}
