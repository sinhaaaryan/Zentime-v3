import Foundation
import SwiftUI

@Observable
final class TimerViewModel {
    // MARK: - State

    var mode: AppMode = .focus
    var config: TimerConfig = .defaultConfig(for: .focus)
    var phase: TimerPhase = .idle
    var remainingSeconds: Double = 0
    var currentRound: Int = 1
    var showActiveTimer = false

    // MARK: - Private

    private var timer: Timer?
    private var phaseEndTime: Date?
    private var pausedRemainingSeconds: Double = 0
    private var backgroundEntryDate: Date?
    private let audioManager = AudioManager()
    private var nowPlayingUpdateCounter = 0

    // Callback set by ContentView to write CompletedSession to SwiftData
    var onSessionComplete: ((String, Int) -> Void)?  // (mode.rawValue, durationMinutes)

    // MARK: - Init

    init() {
        audioManager.onRemoteTogglePause = { [weak self] in
            self?.togglePause()
        }
    }

    // MARK: - Computed

    var progress: Double {
        let total = totalSecondsForCurrentPhase
        guard total > 0 else { return 0 }
        return 1.0 - (remainingSeconds / total)
    }

    var formattedTime: String {
        let totalSeconds = max(0, Int(ceil(remainingSeconds)))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var totalSecondsForCurrentPhase: Double {
        if phase.isFocusPhase {
            return Double(config.focusSeconds)
        } else {
            return Double(config.breakSeconds)
        }
    }

    var roundsDisplay: String {
        guard mode.hasRounds else { return "" }
        return "Round \(currentRound) of \(config.rounds)"
    }

    var isSessionActive: Bool {
        phase == .running(isFocus: true) || phase == .running(isFocus: false) ||
        phase == .paused(isFocus: true) || phase == .paused(isFocus: false)
    }

    // MARK: - Mode Selection

    func selectMode(_ newMode: AppMode) {
        guard !isSessionActive else { return }
        mode = newMode
        config = .defaultConfig(for: newMode)
        reset()
    }

    func dismiss() {
        showActiveTimer = false
    }

    // MARK: - Timer Controls

    func start() {
        phase = .running(isFocus: true)
        currentRound = 1
        remainingSeconds = Double(config.focusSeconds)
        showActiveTimer = true
        startTimer()
        startAudio()
    }

    func togglePause() {
        switch phase {
        case .running(let isFocus):
            phase = .paused(isFocus: isFocus)
            pausedRemainingSeconds = remainingSeconds
            stopTimer()
            audioManager.pause()
        case .paused(let isFocus):
            phase = .running(isFocus: isFocus)
            phaseEndTime = Date().addingTimeInterval(pausedRemainingSeconds)
            startTimer()
            if mode.audioFileName != nil {
                audioManager.resume()
            }
        default:
            break
        }
    }

    func stop() {
        stopTimer()
        audioManager.stop()
        phase = .idle
        remainingSeconds = 0
        currentRound = 1
        showActiveTimer = false
    }

    func reset() {
        stopTimer()
        audioManager.stop()
        phase = .idle
        remainingSeconds = 0
        currentRound = 1
    }

    // MARK: - Background Handling

    func handleBackgrounding() {
        if case .running = phase {
            backgroundEntryDate = Date()
        }
    }

    func handleForegrounding() {
        guard let bgDate = backgroundEntryDate, case .running = phase else {
            backgroundEntryDate = nil
            return
        }

        let elapsed = Date().timeIntervalSince(bgDate)
        backgroundEntryDate = nil

        // Reconcile time while in background
        reconcileElapsedTime(elapsed)
    }

    // MARK: - Private Methods

    private func startTimer() {
        phaseEndTime = Date().addingTimeInterval(remainingSeconds)
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard let endTime = phaseEndTime else { return }
        remainingSeconds = max(0, endTime.timeIntervalSinceNow)

        if remainingSeconds <= 0 {
            advancePhase()
        } else {
            // Update Now Playing info ~every 1s (every 10 ticks at 0.1s interval)
            nowPlayingUpdateCounter += 1
            if nowPlayingUpdateCounter >= 10 {
                nowPlayingUpdateCounter = 0
                let title = "\(mode.title) — \(phase.label)"
                audioManager.updateNowPlayingElapsed(
                    remaining: remainingSeconds,
                    total: totalSecondsForCurrentPhase,
                    title: title
                )
            }
        }
    }

    private func reconcileElapsedTime(_ elapsed: TimeInterval) {
        remainingSeconds = max(0, remainingSeconds - elapsed)

        if remainingSeconds <= 0 {
            // Phase ended while backgrounded — advance
            let overflow = -remainingSeconds
            advancePhaseAfterBackground(overflow: overflow)
        } else {
            // Still in the same phase — update end time
            phaseEndTime = Date().addingTimeInterval(remainingSeconds)
        }
    }

    private func advancePhase() {
        stopTimer()

        switch phase {
        case .running(let isFocus):
            if isFocus && mode.hasBreaks && config.breakSeconds > 0 {
                // Focus -> Break
                phase = .running(isFocus: false)
                remainingSeconds = Double(config.breakSeconds)
                startTimer()
            } else if isFocus && mode.hasRounds && currentRound < config.rounds {
                // End of focus, start next round
                currentRound += 1
                phase = .running(isFocus: true)
                remainingSeconds = Double(config.focusSeconds)
                startTimer()
            } else if !isFocus {
                // Break ended
                if mode.hasRounds && currentRound < config.rounds {
                    currentRound += 1
                    phase = .running(isFocus: true)
                    remainingSeconds = Double(config.focusSeconds)
                    startTimer()
                } else {
                    finishSession()
                }
            } else {
                finishSession()
            }
        default:
            finishSession()
        }
    }

    private func advancePhaseAfterBackground(overflow: TimeInterval) {
        // Simplified: just advance phase without trying to chain through multiple phases
        advancePhase()
    }

    private func finishSession() {
        phase = .finished
        remainingSeconds = 0
        audioManager.stop()
        let durationMinutes = config.focusMinutes
        onSessionComplete?(mode.rawValue, durationMinutes)
    }

    private func startAudio() {
        let title = "\(mode.title) — Focus"
        if let fileName = mode.audioFileName {
            audioManager.play(fileName: fileName, title: title)
        }
        // Always push now-playing info so Control Center shows controls (even for Sleep)
        audioManager.updateNowPlayingElapsed(
            remaining: remainingSeconds,
            total: totalSecondsForCurrentPhase,
            title: title
        )
    }
}
