import Foundation

enum TimerPhase: Equatable {
    case idle
    case running(isFocus: Bool)
    case paused(isFocus: Bool)
    case finished

    var isActive: Bool {
        switch self {
        case .running, .paused: true
        case .idle, .finished: false
        }
    }

    var isFocusPhase: Bool {
        switch self {
        case .running(let isFocus), .paused(let isFocus): isFocus
        default: true
        }
    }

    var label: String {
        switch self {
        case .idle: "Ready"
        case .running(let isFocus): isFocus ? "Focus" : "Break"
        case .paused: "Paused"
        case .finished: "Done"
        }
    }
}
