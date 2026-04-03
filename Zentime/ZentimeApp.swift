import SwiftUI
import SwiftData

@main
struct ZentimeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [ScheduledSession.self, CompletedSession.self])
    }
}
