import SwiftUI

private let matrixChars: [String] = Array(
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
).map(String.init) + ["ｦ", "ｧ", "ｨ", "ｩ", "ｪ", "ｫ", "ｬ", "ｭ", "ｮ", "ｯ"]

private let charWidth: CGFloat = 14
private let charHeight: CGFloat = 18
private let trailLength: Int = 10

private struct RainColumn {
    let x: CGFloat
    var headY: CGFloat
    let speed: Double          // px per second
    let chars: [String]        // pre-generated, fixed per column
}

struct MatrixRainLayer: View {
    @State private var columns: [RainColumn] = []

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(minimumInterval: 0.1)) { timeline in
                Canvas { context, size in
                    let t = timeline.date.timeIntervalSinceReferenceDate
                    let matrixGreen = Color(red: 0.0, green: 1.0, blue: 0.25)

                    for column in columns {
                        let cycleHeight = size.height + CGFloat(trailLength) * charHeight
                        let elapsed = t * column.speed
                        let headY = CGFloat(elapsed.truncatingRemainder(dividingBy: Double(cycleHeight)))

                        for i in 0..<trailLength {
                            let charY = headY - CGFloat(i) * charHeight
                            guard charY > -charHeight && charY < size.height + charHeight else { continue }

                            let charIndex = (Int(headY / charHeight) + i) % column.chars.count
                            let char = column.chars[charIndex]

                            let opacity: Double
                            if i == 0 {
                                opacity = 1.0   // bright head
                            } else if i == 1 {
                                opacity = 0.55
                            } else if i < 4 {
                                opacity = 0.25
                            } else {
                                opacity = max(0.04, 0.15 - Double(i) * 0.012)
                            }

                            var ctx = context
                            ctx.opacity = opacity

                            let point = CGPoint(x: column.x, y: charY)
                            ctx.draw(
                                Text(char)
                                    .font(.system(size: 13, weight: i == 0 ? .bold : .regular, design: .monospaced))
                                    .foregroundColor(matrixGreen),
                                at: point,
                                anchor: .topLeading
                            )
                        }
                    }
                }
                .opacity(0.22)
            }
            .onAppear {
                generateColumns(in: geo.size)
            }
        }
    }

    private func generateColumns(in size: CGSize) {
        let count = Int(size.width / charWidth) + 1
        columns = (0..<count).map { i in
            RainColumn(
                x: CGFloat(i) * charWidth,
                headY: CGFloat.random(in: 0...(size.height + CGFloat(trailLength) * charHeight)),
                speed: Double.random(in: 60...160),
                chars: (0..<20).map { _ in matrixChars.randomElement()! }
            )
        }
    }
}
