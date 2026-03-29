import SwiftUI

// MARK: - Shooting Star

private struct ShootingStar {
    var x: CGFloat
    var y: CGFloat
    let angle: Double
    let speed: CGFloat
    let length: CGFloat
    var opacity: Double
    let createdAt: TimeInterval
}

// MARK: - Orbit Ring

private struct OrbitRing {
    let centerX: CGFloat
    let centerY: CGFloat
    let radiusX: CGFloat
    let radiusY: CGFloat
    let rotation: Double
    let speed: Double
    let dotCount: Int
    let dotRadius: CGFloat
    let opacity: Double
}

// MARK: - Space Background Layer

struct SpaceBackgroundLayer: View {
    @State private var stars: [(x: CGFloat, y: CGFloat, radius: CGFloat, baseOpacity: Double, phase: Double)] = []
    @State private var shootingStars: [ShootingStar] = []
    @State private var nebulaOffset1: CGSize = .zero
    @State private var nebulaOffset2: CGSize = .zero
    @State private var pulseScale: CGFloat = 1.0

    private let orbitRings: [OrbitRing] = [
        OrbitRing(centerX: 0.5, centerY: 0.35, radiusX: 160, radiusY: 50, rotation: -15, speed: 0.3, dotCount: 3, dotRadius: 2, opacity: 0.15),
        OrbitRing(centerX: 0.5, centerY: 0.35, radiusX: 200, radiusY: 65, rotation: 25, speed: -0.2, dotCount: 2, dotRadius: 1.5, opacity: 0.1),
        OrbitRing(centerX: 0.5, centerY: 0.35, radiusX: 240, radiusY: 80, rotation: 45, speed: 0.15, dotCount: 4, dotRadius: 1.2, opacity: 0.08),
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Subtle nebula clouds (white/gray only)
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.04), .clear],
                            center: .center, startRadius: 0, endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 240)
                    .blur(radius: 80)
                    .offset(x: geo.size.width * 0.1 + nebulaOffset1.width,
                            y: geo.size.height * 0.15 + nebulaOffset1.height)

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [Color.white.opacity(0.03), .clear],
                            center: .center, startRadius: 0, endRadius: 140
                        )
                    )
                    .frame(width: 280, height: 200)
                    .blur(radius: 70)
                    .offset(x: -geo.size.width * 0.15 + nebulaOffset2.width,
                            y: geo.size.height * 0.6 + nebulaOffset2.height)

                // Stars + shooting stars + orbit rings
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let time = timeline.date.timeIntervalSinceReferenceDate

                        // Draw twinkling stars
                        for star in stars {
                            let twinkle = (sin(time * 1.5 + star.phase) + 1.0) / 2.0
                            let opacity = star.baseOpacity * (0.2 + 0.8 * twinkle)
                            context.opacity = opacity
                            let rect = CGRect(
                                x: star.x * size.width - star.radius,
                                y: star.y * size.height - star.radius,
                                width: star.radius * 2,
                                height: star.radius * 2
                            )
                            context.fill(Path(ellipseIn: rect), with: .color(.white))
                        }

                        // Draw orbit rings
                        for ring in orbitRings {
                            let cx = ring.centerX * size.width
                            let cy = ring.centerY * size.height

                            // Draw the ellipse track
                            context.opacity = ring.opacity * 0.5
                            var trackPath = Path()
                            for i in 0...100 {
                                let angle = Double(i) / 100.0 * 2 * .pi
                                let px = cos(angle) * ring.radiusX
                                let py = sin(angle) * ring.radiusY
                                let rotRad = ring.rotation * .pi / 180
                                let rx = px * cos(rotRad) - py * sin(rotRad) + cx
                                let ry = px * sin(rotRad) + py * cos(rotRad) + cy
                                if i == 0 {
                                    trackPath.move(to: CGPoint(x: rx, y: ry))
                                } else {
                                    trackPath.addLine(to: CGPoint(x: rx, y: ry))
                                }
                            }
                            trackPath.closeSubpath()
                            context.stroke(trackPath, with: .color(.white), lineWidth: 0.5)

                            // Draw orbiting dots
                            for d in 0..<ring.dotCount {
                                let baseAngle = Double(d) / Double(ring.dotCount) * 2 * .pi
                                let angle = baseAngle + time * ring.speed
                                let px = cos(angle) * ring.radiusX
                                let py = sin(angle) * ring.radiusY
                                let rotRad = ring.rotation * .pi / 180
                                let rx = px * cos(rotRad) - py * sin(rotRad) + cx
                                let ry = px * sin(rotRad) + py * cos(rotRad) + cy

                                context.opacity = ring.opacity * 2.5
                                let dotRect = CGRect(
                                    x: rx - ring.dotRadius,
                                    y: ry - ring.dotRadius,
                                    width: ring.dotRadius * 2,
                                    height: ring.dotRadius * 2
                                )
                                context.fill(Path(ellipseIn: dotRect), with: .color(.white))
                            }
                        }

                        // Draw shooting stars
                        for star in shootingStars {
                            let age = time - star.createdAt
                            guard age > 0 && age < 1.5 else { continue }

                            let progress = age / 1.5
                            let fadeIn = min(progress * 4, 1.0)
                            let fadeOut = max(0, 1.0 - (progress - 0.5) * 2)
                            let alpha = min(fadeIn, fadeOut) * star.opacity

                            let currentX = star.x + CGFloat(age) * star.speed * cos(CGFloat(star.angle))
                            let currentY = star.y + CGFloat(age) * star.speed * sin(CGFloat(star.angle))
                            let tailX = currentX - star.length * cos(CGFloat(star.angle))
                            let tailY = currentY - star.length * sin(CGFloat(star.angle))

                            context.opacity = alpha
                            var path = Path()
                            path.move(to: CGPoint(x: tailX * size.width, y: tailY * size.height))
                            path.addLine(to: CGPoint(x: currentX * size.width, y: currentY * size.height))
                            context.stroke(path, with: .color(.white), lineWidth: 1.2)
                        }
                    }
                }
            }
            .onAppear {
                generateStars()
                animateNebula()
                startShootingStarTimer()
            }
        }
    }

    private func generateStars() {
        stars = (0..<120).map { _ in
            (
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                radius: CGFloat.random(in: 0.4...1.8),
                baseOpacity: Double.random(in: 0.2...0.8),
                phase: Double.random(in: 0...(2 * .pi))
            )
        }
    }

    private func animateNebula() {
        withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
            nebulaOffset1 = CGSize(width: 25, height: 35)
        }
        withAnimation(.easeInOut(duration: 15).repeatForever(autoreverses: true)) {
            nebulaOffset2 = CGSize(width: -20, height: -25)
        }
    }

    private func startShootingStarTimer() {
        // Spawn a shooting star every few seconds
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            let newStar = ShootingStar(
                x: CGFloat.random(in: 0.1...0.9),
                y: CGFloat.random(in: 0.05...0.4),
                angle: Double.random(in: 0.3...0.8),
                speed: CGFloat.random(in: 0.3...0.6),
                length: CGFloat.random(in: 0.03...0.08),
                opacity: Double.random(in: 0.4...0.9),
                createdAt: Date.timeIntervalSinceReferenceDate
            )
            shootingStars.append(newStar)
            // Keep array manageable
            if shootingStars.count > 10 {
                shootingStars.removeFirst(5)
            }
        }
    }
}
