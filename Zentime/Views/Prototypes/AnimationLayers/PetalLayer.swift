import SwiftUI

private struct Petal {
    let xFraction: CGFloat
    let startYFraction: CGFloat   // start Y as fraction of height (petals start at different heights)
    let speed: Double             // px/s downward
    let swayAmplitude: Double     // horizontal sway amplitude in pts
    let swayFrequency: Double
    let rotation: Double          // initial rotation in radians
    let rotationSpeed: Double     // radians per second
    let width: CGFloat
    let height: CGFloat
    let phase: Double
}

struct PetalLayer: View {
    @State private var petals: [Petal] = []

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    for petal in petals {
                        let cycleTime = (size.height * (1 + petal.startYFraction)) / petal.speed
                        let elapsed = (t + petal.phase * cycleTime).truncatingRemainder(dividingBy: cycleTime)

                        let startY = -petal.startYFraction * size.height
                        let y = startY + elapsed * petal.speed
                        let x = petal.xFraction * size.width
                            + CGFloat(sin(t * petal.swayFrequency + petal.phase) * petal.swayAmplitude)

                        guard y < size.height + 20 else { continue }

                        let currentAngle = petal.rotation + t * petal.rotationSpeed

                        // Draw petal as a rotated ellipse via context transform
                        var ctx = context
                        ctx.translateBy(x: x, y: y)
                        ctx.rotate(by: Angle(radians: currentAngle))

                        let rect = CGRect(
                            x: -petal.width / 2,
                            y: -petal.height / 2,
                            width: petal.width,
                            height: petal.height
                        )

                        // Petal color: soft pink
                        ctx.opacity = 0.55
                        ctx.fill(
                            Path(ellipseIn: rect),
                            with: .color(Color(red: 0.95, green: 0.72, blue: 0.80))
                        )

                        // Subtle darker center vein
                        let veinRect = CGRect(x: -1, y: -petal.height / 2, width: 2, height: petal.height)
                        ctx.opacity = 0.15
                        ctx.fill(Path(ellipseIn: veinRect),
                                 with: .color(Color(red: 0.70, green: 0.40, blue: 0.55)))
                    }
                }
            }
            .onAppear {
                generatePetals()
            }
        }
    }

    private func generatePetals() {
        petals = (0..<15).map { _ in
            Petal(
                xFraction: CGFloat.random(in: 0.05...0.95),
                startYFraction: CGFloat.random(in: 0...1),
                speed: Double.random(in: 30...60),
                swayAmplitude: Double.random(in: 15...45),
                swayFrequency: Double.random(in: 0.2...0.7),
                rotation: Double.random(in: 0...(2 * .pi)),
                rotationSpeed: Double.random(in: -0.4...0.4),
                width: CGFloat.random(in: 8...16),
                height: CGFloat.random(in: 14...24),
                phase: Double.random(in: 0...1)
            )
        }
    }
}
