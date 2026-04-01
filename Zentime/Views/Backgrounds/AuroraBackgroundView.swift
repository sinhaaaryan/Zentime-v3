import SwiftUI

// MARK: - Star model

private struct Star {
    let x: CGFloat
    let y: CGFloat
    let radius: CGFloat
    let baseOpacity: Double
    let phase: Double
    let twinkleFreq: Double
}

// MARK: - Aurora band model

private struct AuroraBand {
    let nx: Double       // normalized center x
    let ny: Double       // normalized center y
    let rx: Double       // x radius
    let ry: Double       // y radius
    let r: Double        // color red
    let g: Double        // color green
    let b: Double        // color blue
    let baseOp: Double   // base opacity
    let phaseX: Double
    let phaseY: Double
    let period: Double
    let driftX: Double
    let driftY: Double
}

// MARK: - AuroraBackgroundView

struct AuroraBackgroundView: View {
    var isActive: Bool = false

    @State private var stars: [Star] = []

    private let bands: [AuroraBand] = [
        AuroraBand(nx: 0.55, ny: 0.14, rx: 310, ry: 115, r: 0.28, g: 0.12, b: 1.00, baseOp: 0.26, phaseX: 0.0, phaseY: 1.1, period: 12, driftX: 30, driftY: 20),
        AuroraBand(nx: 0.28, ny: 0.25, rx: 250, ry: 95,  r: 0.40, g: 0.00, b: 0.82, baseOp: 0.20, phaseX: 2.0, phaseY: 0.4, period: 15, driftX: 22, driftY: 24),
        AuroraBand(nx: 0.70, ny: 0.40, rx: 200, ry: 85,  r: 0.03, g: 0.20, b: 1.00, baseOp: 0.18, phaseX: 4.2, phaseY: 3.0, period: 10, driftX: 24, driftY: 18),
        AuroraBand(nx: 0.42, ny: 0.10, rx: 270, ry: 75,  r: 0.20, g: 0.04, b: 0.75, baseOp: 0.15, phaseX: 1.4, phaseY: 2.7, period: 17, driftX: 18, driftY: 15),
        AuroraBand(nx: 0.62, ny: 0.52, rx: 175, ry: 70,  r: 0.12, g: 0.28, b: 1.00, baseOp: 0.14, phaseX: 3.6, phaseY: 0.8, period: 13, driftX: 16, driftY: 22),
        AuroraBand(nx: 0.20, ny: 0.44, rx: 190, ry: 80,  r: 0.51, g: 0.08, b: 0.90, baseOp: 0.13, phaseX: 5.1, phaseY: 1.9, period: 9,  driftX: 20, driftY: 16),
    ]

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate * (isActive ? 1.25 : 1.0)
            Canvas { context, size in
                drawBackground(context: &context, size: size, time: t)
                drawAurora(context: &context, size: size, time: t)
                drawStars(context: &context, size: size, time: t)
            }
        }
        .onAppear { generateStars() }
    }

    // MARK: - Background

    private func drawBackground(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(red: 0.008, green: 0.003, blue: 0.040)))
    }

    // MARK: - Aurora bands

    private func drawAurora(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        for band in bands {
            let dx = sin(time * .pi * 2 / band.period + band.phaseX) * band.driftX
            let dy = cos(time * .pi * 2 / band.period + band.phaseY) * band.driftY
            let cx = band.nx * Double(size.width)  + dx
            let cy = band.ny * Double(size.height) + dy
            let pulse = 0.70 + 0.30 * sin(time * 0.45 + band.phaseX)
            let alpha = band.baseOp * pulse

            // 4 nested ellipses for smooth falloff (screen blend)
            for layer in stride(from: 4, through: 1, by: -1) {
                let scale  = 1.0 + Double(layer) * 0.18
                let rx     = band.rx * scale
                let ry     = band.ry * scale
                let layerAlpha = alpha * (Double(layer) / 4.0) * 0.65

                let rect = CGRect(
                    x: cx - rx, y: cy - ry * (ry / rx),
                    width: rx * 2, height: ry * 2
                )
                // Approximate radial gradient with a blurred ellipse color
                let col = Color(red: band.r, green: band.g, blue: band.b)
                    .opacity(layerAlpha)
                context.blendMode = .screen
                context.opacity = 1.0
                context.fill(Path(ellipseIn: rect), with: .color(col))
            }
        }
        context.blendMode = .normal
    }

    // MARK: - Stars

    private func generateStars() {
        let count = isActive ? 100 : 160
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

    private func drawStars(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        context.blendMode = .normal
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
            if r > 1.1 && opacity > 0.5 {
                context.opacity = opacity * 0.25
                var h = Path(); h.move(to: CGPoint(x: sx - r * 3.5, y: sy)); h.addLine(to: CGPoint(x: sx + r * 3.5, y: sy))
                var v = Path(); v.move(to: CGPoint(x: sx, y: sy - r * 3.5)); v.addLine(to: CGPoint(x: sx, y: sy + r * 3.5))
                context.stroke(h, with: .color(Color(red: 0.8, green: 0.85, blue: 1.0)), lineWidth: 0.4)
                context.stroke(v, with: .color(Color(red: 0.8, green: 0.85, blue: 1.0)), lineWidth: 0.4)
            }
        }
        context.opacity = 1.0
    }
}

#Preview {
    AuroraBackgroundView()
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
}
