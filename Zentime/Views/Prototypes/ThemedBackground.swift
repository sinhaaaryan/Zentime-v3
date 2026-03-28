import SwiftUI

struct ThemedBackground: View {
    let theme: PrototypeTheme

    var body: some View {
        ZStack {
            theme.backgroundColor
                .ignoresSafeArea()

            if theme.hasAnimatedBackground {
                animationLayer
                    .ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private var animationLayer: some View {
        switch theme {
        case .nebula:  StarfieldLayer()
        case .aurora:  AuroraLayer()
        case .forge:   EmberLayer()
        case .sakura:  PetalLayer()
        case .matrix:  MatrixRainLayer()
        case .classic: EmptyView()
        }
    }
}
