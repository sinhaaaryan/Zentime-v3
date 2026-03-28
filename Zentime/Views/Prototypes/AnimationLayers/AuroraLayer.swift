import SwiftUI

struct AuroraLayer: View {
    @State private var offset1: CGSize = .zero
    @State private var offset2: CGSize = .zero
    @State private var offset3: CGSize = .zero
    @State private var offset4: CGSize = .zero
    @State private var scale1: CGFloat = 1.0
    @State private var scale2: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Wave 1 — teal
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.05, green: 0.85, blue: 0.75).opacity(0.35),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geo.size.width * 0.9, height: 220)
                    .blur(radius: 90)
                    .scaleEffect(x: scale1, y: 1.0)
                    .offset(x: offset1.width, y: geo.size.height * 0.15 + offset1.height)

                // Wave 2 — cyan/green
                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.10, green: 0.90, blue: 0.50).opacity(0.30),
                                Color.clear
                            ],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(width: geo.size.width * 1.1, height: 180)
                    .blur(radius: 100)
                    .scaleEffect(x: scale2, y: 1.0)
                    .offset(x: offset2.width, y: geo.size.height * 0.40 + offset2.height)

                // Wave 3 — mint
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.30, green: 1.00, blue: 0.70).opacity(0.22),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 200
                        )
                    )
                    .frame(width: geo.size.width * 0.7, height: 160)
                    .blur(radius: 80)
                    .offset(x: offset3.width, y: geo.size.height * 0.65 + offset3.height)

                // Wave 4 — deep teal
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.0, green: 0.70, blue: 0.60).opacity(0.25),
                                .clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 180
                        )
                    )
                    .frame(width: geo.size.width * 0.6, height: 140)
                    .blur(radius: 70)
                    .offset(x: offset4.width, y: geo.size.height * 0.85 + offset4.height)
            }
            .opacity(0.55)
            .onAppear {
                withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) {
                    offset1 = CGSize(width: 40, height: -30)
                    scale1 = 1.15
                }
                withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                    offset2 = CGSize(width: -50, height: 25)
                    scale2 = 0.90
                }
                withAnimation(.easeInOut(duration: 8.5).repeatForever(autoreverses: true)) {
                    offset3 = CGSize(width: 25, height: -20)
                }
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    offset4 = CGSize(width: -30, height: 15)
                }
            }
        }
    }
}
