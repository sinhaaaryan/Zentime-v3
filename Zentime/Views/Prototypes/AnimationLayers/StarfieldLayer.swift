import SwiftUI

private struct Star {
    let x: CGFloat
    let y: CGFloat
    let radius: CGFloat
    let baseOpacity: Double
    let phase: Double
}

struct StarfieldLayer: View {
    @State private var stars: [Star] = []
    @State private var orb1Offset: CGSize = .zero
    @State private var orb2Offset: CGSize = .zero
    @State private var orb3Offset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Floating orbs (blurred ellipses behind stars)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.35, green: 0.10, blue: 0.80).opacity(0.45),
                                .clear
                            ],
                            center: .center, startRadius: 0, endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 200)
                    .blur(radius: 55)
                    .offset(x: geo.size.width * 0.15 + orb1Offset.width,
                            y: geo.size.height * 0.20 + orb1Offset.height)

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.60, green: 0.10, blue: 0.90).opacity(0.35),
                                .clear
                            ],
                            center: .center, startRadius: 0, endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 160)
                    .blur(radius: 65)
                    .offset(x: -geo.size.width * 0.20 + orb2Offset.width,
                            y: geo.size.height * 0.55 + orb2Offset.height)

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.20, green: 0.05, blue: 0.70).opacity(0.30),
                                .clear
                            ],
                            center: .center, startRadius: 0, endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 140)
                    .blur(radius: 50)
                    .offset(x: geo.size.width * 0.25 + orb3Offset.width,
                            y: geo.size.height * 0.75 + orb3Offset.height)

                // Star canvas
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let phase = timeline.date.timeIntervalSinceReferenceDate
                        for star in stars {
                            let twinkle = (sin(phase * 1.2 + star.phase) + 1.0) / 2.0
                            let opacity = star.baseOpacity * (0.25 + 0.75 * twinkle)
                            context.opacity = opacity
                            let rect = CGRect(
                                x: star.x * size.width - star.radius,
                                y: star.y * size.height - star.radius,
                                width: star.radius * 2,
                                height: star.radius * 2
                            )
                            context.fill(Path(ellipseIn: rect), with: .color(.white))
                        }
                    }
                }
            }
            .onAppear {
                generateStars()
                animateOrbs()
            }
        }
    }

    private func generateStars() {
        stars = (0..<80).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                radius: CGFloat.random(in: 0.5...2.0),
                baseOpacity: Double.random(in: 0.3...0.9),
                phase: Double.random(in: 0...(2 * .pi))
            )
        }
    }

    private func animateOrbs() {
        withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
            orb1Offset = CGSize(width: 30, height: 40)
        }
        withAnimation(.easeInOut(duration: 11).repeatForever(autoreverses: true)) {
            orb2Offset = CGSize(width: -20, height: -30)
        }
        withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
            orb3Offset = CGSize(width: 15, height: -20)
        }
    }
}
