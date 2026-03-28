import Foundation

enum AppMode: String, CaseIterable, Hashable, Identifiable {
    case focus
    case resetBrain
    case sleep
    case nap
    case meditation
    case deepWork
    case windDown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focus: "Focus"
        case .resetBrain: "Reset Brain"
        case .sleep: "Sleep"
        case .nap: "Nap"
        case .meditation: "Meditation"
        case .deepWork: "Deep Work"
        case .windDown: "Wind Down"
        }
    }

    var subtitle: String {
        switch self {
        case .focus: "Deep work with timed breaks"
        case .resetBrain: "Mental reset with binaural tones"
        case .sleep: "Wind down and drift off"
        case .nap: "Power nap to recharge"
        case .meditation: "Mindful stillness"
        case .deepWork: "Extended focus sessions"
        case .windDown: "Relax and unwind"
        }
    }

    var iconName: String {
        switch self {
        case .focus: "bolt.fill"
        case .resetBrain: "brain.head.profile"
        case .sleep: "moon.fill"
        case .nap: "bed.double.fill"
        case .meditation: "figure.mind.and.body"
        case .deepWork: "laptopcomputer"
        case .windDown: "sunset.fill"
        }
    }

    var audioFileName: String? {
        switch self {
        case .focus: "focus_brown_noise_10m"
        case .resetBrain: "brain_reset_852hz_5m"
        case .sleep: nil
        case .nap: "nap_ambient"
        case .meditation: "meditation_bells"
        case .deepWork: "deep_work_noise"
        case .windDown: "wind_down_ambient"
        }
    }

    var hasBreaks: Bool {
        self == .focus || self == .deepWork
    }

    var hasRounds: Bool {
        self == .focus || self == .deepWork
    }

    var defaultFocusMinutes: Int {
        switch self {
        case .focus: 25
        case .resetBrain: 10
        case .sleep: 15
        case .nap: 20
        case .meditation: 15
        case .deepWork: 50
        case .windDown: 20
        }
    }

    var defaultBreakMinutes: Int {
        switch self {
        case .focus: 5
        case .deepWork: 10
        case .resetBrain, .sleep, .nap, .meditation, .windDown: 0
        }
    }

    var defaultRounds: Int {
        switch self {
        case .focus: 4
        case .deepWork: 3
        case .resetBrain, .sleep, .nap, .meditation, .windDown: 1
        }
    }
}
