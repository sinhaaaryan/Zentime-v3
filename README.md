# Zentime

**A premium focus and wellness timer for iOS.**

<p align="center">
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro Max - 2026-04-05 at 17.27.04.png" width="30%" alt="Home Screen" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro Max - 2026-04-05 at 17.27.13.png" width="30%" alt="Focus Timer" />
  <img src="screenshots/Simulator Screenshot - iPhone 17 Pro Max - 2026-04-05 at 17.27.20.png" width="30%" alt="Plan Screen" />
</p>

Zentime is built around one idea: the quality of your attention determines the quality of your work. It gives you structured time blocks, ambient audio, and a streak system that makes showing up every day feel worth it — all wrapped in an aurora-lit interface that makes opening the app feel like a ritual.

---

## What It Does

Zentime is a mode-based timer. You pick a mode, hit Start Focus, and the app handles the rest — countdown, audio, break transitions, and logging the session when you finish.

**Modes:**

| Mode | Duration | What it's for |
|---|---|---|
| Focus | 25 min × 4 rounds | Classic Pomodoro. Deep work with timed breaks. |
| Deep Work | 50 min × 3 rounds | Extended sessions for complex problems. |
| Reset Brain | 10 min | Mental reset with 852 Hz binaural tones. |
| Meditation | 15 min | Mindful stillness. No audio, no pressure. |
| Nap | 20 min | Power nap to recharge mid-day. |
| Wind Down | 20 min | Relax and decompress before sleep. |
| Sleep | 15 min | Wind-down ambient to ease into rest. |

Each session plays ambient audio through the system audio layer — meaning it continues when the screen locks, shows up in Control Center, and responds to hardware play/pause. When a session ends, it's written to a local SwiftData store so your history is always there.

---

## Features

**Streak Tracking**

The home screen shows your current streak and a week grid (Mon–Sun). A day counts if you completed at least one session. The streak is computed live from your session history — no server, no account.

**Evening Planning**

A Plan tab lets you schedule sessions for tonight. You set the time and the mode; the app sends a local notification reminder. Nothing leaves your device.

**Aurora Background**

The home screen and active timer use a Metal shader aurora — a real-time GPU animation of flowing violet, indigo, and blue light with a star canvas underneath. It runs at 60 fps and adapts to the display's refresh rate.

**Now Playing Bar**

When a session is active, a persistent bar sits at the bottom of the home screen showing the current mode, time remaining, and a pause control. The same info is mirrored in Control Center and on the Lock Screen.

**Haptics**

Session start, completion, and mode changes use calibrated UIKit haptics. Nothing excessive — one tap, one feel.

**Themes**

A theme switcher lets you cycle through visual styles: Classic, Space, Aurora, Ember, Matrix Rain, and Petals. Each has its own animated background layer.

---

## Architecture

Pure SwiftUI + SwiftData. No third-party dependencies.

```
Zentime/
├── Models/
│   ├── AppMode.swift           # Timer mode definitions, defaults, audio mapping
│   ├── TimerConfig.swift       # Focus/break durations, round counts
│   ├── TimerPhase.swift        # State machine: idle → running → paused → finished
│   ├── CompletedSession.swift  # SwiftData model for session history
│   └── ScheduledSession.swift  # SwiftData model for planned sessions
├── ViewModels/
│   └── TimerViewModel.swift    # Timer engine, audio coordination, background handling
├── Services/
│   ├── AudioManager.swift      # AVAudioPlayer + MPNowPlayingInfoCenter + RemoteCommandCenter
│   ├── NotificationService.swift # UNUserNotificationCenter, evening reminder scheduling
│   └── HapticManager.swift     # UIImpactFeedbackGenerator wrappers
├── Views/
│   ├── HomeView.swift          # Streak card, mode selector, start button
│   ├── ActiveTimerView.swift   # Full-screen timer with aurora background
│   ├── PlanView.swift          # Tonight's plan, scheduled sessions
│   ├── Backgrounds/
│   │   └── AuroraBackgroundView.swift  # Metal shader + SwiftUI Canvas star layer
│   └── Components/
│       ├── StreakCard.swift
│       ├── FocusActivityGridView.swift
│       ├── ModeSelector.swift
│       ├── NowPlayingBar.swift
│       ├── TonightsPlanView.swift
│       ├── AddSessionSheet.swift
│       └── EveningReminderSettingsSheet.swift
├── Shaders/
│   └── AuroraShader.metal      # FBM-based aurora with violet/indigo/blue palette
└── Theme/
    ├── ThemeManager.swift
    ├── ZentimeTheme.swift
    └── PrototypeTheme.swift
```

**Timer state machine** (`TimerPhase`): `idle → running(isFocus: true) → running(isFocus: false) → ... → finished`. Phase transitions are driven by a 0.1s `Timer` that computes remaining time against a `phaseEndTime: Date`, so backgrounding the app doesn't corrupt the countdown.

**Audio** runs on `AVAudioSession.playback` so it continues when the screen locks. Remote commands (play/pause from Control Center or headphone button) route back into `TimerViewModel.togglePause()` via a closure.

**Session persistence** uses SwiftData with a shared `ModelContainer` initialized at the app level and injected into the view hierarchy. `CompletedSession` records are written in the `onSessionComplete` callback on `TimerViewModel`.

---

## Requirements

- iOS 17+
- Xcode 15+
- Swift 5.9+

No external packages. No CocoaPods. No SPM dependencies.

---

## Getting Started

```bash
git clone https://github.com/sinhaaaryan/Zentime-v3.git
cd Zentime-v3
open Zentime.xcodeproj
```

Select a simulator or device, hit Run. That's it.

---

## Design Philosophy

Zentime is intentionally minimal. There's no social layer, no gamification beyond the streak, no subscription. The interface is dark by default — not as an aesthetic choice, but because it's what you want open at 6 AM or 11 PM.

The aurora background exists because the act of starting a focus session should feel like entering a different space. Small rituals compound.
