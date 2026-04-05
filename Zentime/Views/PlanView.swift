// Zentime/Views/PlanView.swift
import SwiftUI

struct PlanView: View {
    @Environment(NotificationService.self) private var notificationService

    var body: some View {
        ZStack {
            AuroraBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 50)

                    FocusActivityGridView()

                    TonightsPlanView()

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, ZentimeTheme.spacing)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            if !notificationService.isAuthorized {
                await notificationService.requestPermission()
            }
        }
    }
}

#Preview {
    PlanView()
        .environment(NotificationService.shared)
        .environment(ThemeManager.shared)
        .preferredColorScheme(.dark)
}
