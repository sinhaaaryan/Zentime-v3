import SwiftUI

@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    var currentPrototype: PrototypeTheme {
        didSet {
            UserDefaults.standard.set(currentPrototype.rawValue, forKey: "zentime_prototype")
        }
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "zentime_prototype") ?? ""
        currentPrototype = PrototypeTheme(rawValue: saved) ?? .classic
    }
}
