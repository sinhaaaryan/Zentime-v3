import SwiftUI

private struct Ember {
    let xFraction: CGFloat   // 0...1 horizontal position
    let speed: Double         // pixels per second
    let drift: Double         // horizontal drift amplitude
    let driftFreq: Double     // horizontal drift frequency
    let size: CGFloat
    let phase: Double         // time offset so embers are staggered
}

struct EmberLayer: View {
    @State private var embers: [Ember] = []

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    for ember in embers {
                        let elapsed = (t + ember.phase).truncatingRemainder(dividingBy: (size.height + 20) / ember.speed)
                        let rawY = size.height - elapsed * ember.speed
                        let x = ember.xFraction * size.width + CGFloat(sin(t * ember.driftFreq + ember.phase) * ember.drift)
                        let y = rawY

                        // Fade out as ember rises (closer to top = more transparent)
                        let heightFraction = max(0, min(1, y / size.height))
                        let opacity = heightFraction * 0.8

                        let rect = CGRect(
                            x: x - ember.size / 2,
                            y: y - ember.size / 2,
                            width: ember.size,
                            height: ember.size
                        )

                        // Hot core: bright amber/orange
                        context.opacity = opacity
                        let color = ember.size > 2.5
                            ? Color(red: 1.0, green: 0.55, blue: 0.10)
                            : Color(red: 1.0, green: 0.75, blue: 0.30)
                        context.fill(Path(ellipseIn: rect), with: .color(color))

                        // Glow halo
                        let glowRect = rect.insetBy(dx: -ember.size, dy: -ember.size)
                        context.opacity = opacity * 0.25
                        context.fill(Path(ellipseIn: glowRect),
                                     with: .color(Color(red: 1.0, green: 0.35, blue: 0.0)))
                    }
                }
            }
            .onAppear {
                generateEmbers()
            }
        }
    }

    private func generateEmbers() {
        embers = (0..<35).map { _ in
            Ember(
                xFraction: CGFloat.random(in: 0.05...0.95),
                speed: Double.random(in: 40...90),
                drift: Double.random(in: 5...25),
                driftFreq: Double.random(in: 0.3...1.2),
                size: CGFloat.random(in: 1.5...4.0),
                phase: Double.random(in: 0...20)
            )
        }
    }
}
