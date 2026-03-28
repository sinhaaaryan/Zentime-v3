import Foundation

struct TimerConfig {
    var focusMinutes: Int
    var breakMinutes: Int
    var rounds: Int

    var focusSeconds: Int { focusMinutes * 60 }
    var breakSeconds: Int { breakMinutes * 60 }

    static func defaultConfig(for mode: AppMode) -> TimerConfig {
        TimerConfig(
            focusMinutes: mode.defaultFocusMinutes,
            breakMinutes: mode.defaultBreakMinutes,
            rounds: mode.defaultRounds
        )
    }
}
