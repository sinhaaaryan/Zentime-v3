# Galactic Core Space Animation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the current `SpaceBackgroundLayer` with a premium "Galactic Core" animation featuring a procedurally-rendered spiral galaxy with warm golden core, cool blue arms, colored-tint twinkle stars, swirling dust, and shooting comets — applied to both `HomeView` and `ActiveTimerView`.

**Architecture:** A single drop-in SwiftUI `View` called `GalacticBackgroundLayer` replaces `SpaceBackgroundLayer`. It renders entirely inside a `TimelineView` + `Canvas` for GPU-efficient frame drawing. A separate `GalacticTimerBackground` wraps it for the `ActiveTimerView` with a slightly more intense effect (faster rotation, brighter core) signalled via a `Bool` parameter.

**Tech Stack:** SwiftUI `Canvas`, `TimelineView(.animation)`, `GraphicsContext`, `Path`, `withAnimation`, pure Swift math (sin/cos/atan2) — no external dependencies.

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `Zentime/Views/Prototypes/AnimationLayers/GalacticBackgroundLayer.swift` | **Create** | Full galaxy rendering: core glow, spiral arm dust, starfield with color tints, shooting comets |
| `Zentime/Views/HomeView.swift` | **Modify** | Swap `SpaceBackgroundLayer()` → `GalacticBackgroundLayer()` |
| `Zentime/Views/ActiveTimerView.swift` | **Modify** | Add `GalacticBackgroundLayer(isActive: true)` behind the existing `ThemedBackground` when theme is `.classic` (the space theme used on that screen) |
| `Zentime/Views/Prototypes/AnimationLayers/SpaceBackgroundLayer.swift` | **Keep** | Not deleted — still used as reference; just replaced in HomeView |

---

### Task 1: Create `GalacticBackgroundLayer` — Core Glow + Starfield

**Files:**
- Create: `Zentime/Views/Prototypes/AnimationLayers/GalacticBackgroundLayer.swift`

This task builds the foundational struct and the two simplest render passes: the warm/cool galactic core bloom and the star field with color-tinted twinkle.

- [ ] **Step 1: Create the file with data models and star generation**

Create `Zentime/Views/Prototypes/AnimationLayers/GalacticBackgroundLayer.swift` with the following content:

```swift
import SwiftUI

// MARK: - Data Models

private struct GalaxyStar {
    let x: CGFloat          // 0–1 normalised
    let y: CGFloat          // 0–1 normalised
    let radius: CGFloat     // px
    let baseOpacity: Double
    let phase: Double       // twinkle phase offset
    let colorIndex: Int     // 0=white 1=warm 2=cool
}

private struct Comet {
    var x: CGFloat          // normalised position of head
    var y: CGFloat
    let angle: Double       // radians, always roughly diagonal
    let speed: CGFloat      // normalised units/sec
    let tailLength: CGFloat // normalised
    var opacity: Double
    let createdAt: TimeInterval
    let lifetime: Double    // seconds
}

// MARK: - Galactic Background Layer

struct GalacticBackgroundLayer: View {
    /// Pass `true` on the active-timer screen for a slightly more intense effect.
    var isActive: Bool = false

    @State private var stars: [GalaxyStar] = []
    @State private var comets: [Comet] = []
    @State private var nebulaOffset1: CGSize = .zero
    @State private var nebulaOffset2: CGSize = .zero

    // Dust cloud colours (warm arm / cool arm)
    private let armColorWarm = Color(red: 1.00, green: 0.90, blue: 0.55)  // golden
    private let armColorCool = Color(red: 0.55, green: 0.75, blue: 1.00)  // ice blue

    // Star tint palette
    private let starColors: [Color] = [
        .white,
        Color(red: 1.00, green: 0.92, blue: 0.70),  // warm ivory
        Color(red: 0.70, green: 0.88, blue: 1.00),  // cool blue
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // --- Static soft nebula blobs (SwiftUI layer) ---
                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [armColorWarm.opacity(isActive ? 0.09 : 0.06), .clear],
                            center: .center, startRadius: 0, endRadius: 220
                        )
                    )
                    .frame(width: 440, height: 260)
                    .blur(radius: 90)
                    .offset(
                        x: geo.size.width * 0.05 + nebulaOffset1.width,
                        y: geo.size.height * 0.12 + nebulaOffset1.height
                    )

                Ellipse()
                    .fill(
                        RadialGradient(
                            colors: [armColorCool.opacity(isActive ? 0.07 : 0.05), .clear],
                            center: .center, startRadius: 0, endRadius: 180
                        )
                    )
                    .frame(width: 360, height: 240)
                    .blur(radius: 80)
                    .offset(
                        x: -geo.size.width * 0.10 + nebulaOffset2.width,
                        y: geo.size.height * 0.65 + nebulaOffset2.height
                    )

                // --- Animated canvas (galaxy + stars + comets) ---
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let t = timeline.date.timeIntervalSinceReferenceDate
                        drawGalaxyCore(context: &context, size: size, time: t)
                        drawSpiralDust(context: &context, size: size, time: t)
                        drawStars(context: &context, size: size, time: t)
                        drawComets(context: &context, size: size, time: t)
                    }
                }
            }
            .onAppear {
                generateStars(in: geo.size)
                animateNebula()
                scheduleCometSpawner()
            }
        }
    }

    // MARK: - Star Generation

    private func generateStars(in size: CGSize) {
        let count = isActive ? 90 : 130
        stars = (0..<count).map { _ in
            GalaxyStar(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                radius: CGFloat.random(in: 0.4...2.0),
                baseOpacity: Double.random(in: 0.25...0.85),
                phase: Double.random(in: 0...(2 * .pi)),
                colorIndex: [0, 0, 0, 1, 2].randomElement()!  // mostly white
            )
        }
    }

    // MARK: - Nebula Animation

    private func animateNebula() {
        withAnimation(.easeInOut(duration: 14).repeatForever(autoreverses: true)) {
            nebulaOffset1 = CGSize(width: 30, height: 40)
        }
        withAnimation(.easeInOut(duration: 17).repeatForever(autoreverses: true)) {
            nebulaOffset2 = CGSize(width: -25, height: -30)
        }
    }

    // MARK: - Comet Spawner

    private func scheduleCometSpawner() {
        let interval: Double = isActive ? 2.5 : 4.0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            spawnComet()
        }
        // Spawn one immediately after a short delay so it doesn't start empty
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { spawnComet() }
    }

    private func spawnComet() {
        let c = Comet(
            x: CGFloat.random(in: 0.05...0.85),
            y: CGFloat.random(in: 0.03...0.50),
            angle: Double.random(in: 0.25...0.70),
            speed: CGFloat.random(in: 0.25...0.55),
            tailLength: CGFloat.random(in: 0.06...0.14),
            opacity: Double.random(in: 0.45...0.90),
            createdAt: Date.timeIntervalSinceReferenceDate,
            lifetime: Double.random(in: 1.2...2.0)
        )
        comets.append(c)
        if comets.count > 8 { comets.removeFirst(4) }
    }

    // MARK: - Draw: Galaxy Core

    private func drawGalaxyCore(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let cx = size.width * 0.50
        let cy = size.height * 0.36
        let pulse = CGFloat(0.90 + 0.10 * sin(time * (isActive ? 0.9 : 0.6)))
        let intensity: CGFloat = isActive ? 1.3 : 1.0

        // Outer halo — cool blue
        for i in stride(from: 5, through: 1, by: -1) {
            let r = CGFloat(i) * (isActive ? 60 : 50) * pulse
            let a = Double(6 - i) / 5.0 * 0.035 * Double(intensity)
            context.opacity = a
            let rect = CGRect(x: cx - r, y: cy - r * 0.55, width: r * 2, height: r * 1.10)
            // Use a radial blend: cool outer, warm inner
            let blueish = Color(red: 0.65, green: 0.80, blue: 1.00)
            context.fill(Path(ellipseIn: rect), with: .color(blueish))
        }

        // Inner warm core glow
        for i in stride(from: 4, through: 1, by: -1) {
            let r = CGFloat(i) * (isActive ? 28 : 22) * pulse
            let a = Double(5 - i) / 4.0 * 0.07 * Double(intensity)
            context.opacity = a
            let rect = CGRect(x: cx - r, y: cy - r * 0.65, width: r * 2, height: r * 1.30)
            let warm = Color(red: 1.00, green: 0.88, blue: 0.55)
            context.fill(Path(ellipseIn: rect), with: .color(warm))
        }

        // Bright nucleus
        context.opacity = 0.55 * Double(intensity) * (0.85 + 0.15 * sin(time * 1.4))
        let nr = CGFloat(isActive ? 7 : 5) * pulse
        let nRect = CGRect(x: cx - nr, y: cy - nr, width: nr * 2, height: nr * 2)
        context.fill(Path(ellipseIn: nRect), with: .color(Color(red: 1.0, green: 0.97, blue: 0.88)))
    }

    // MARK: - Draw: Spiral Dust Arms

    private func drawSpiralDust(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        let cx = size.width * 0.50
        let cy = size.height * 0.36
        let rotSpeed: Double = isActive ? 0.018 : 0.010  // radians/sec
        let rotation = time * rotSpeed

        // Two arms, offset by π
        for armIndex in 0..<2 {
            let armOffset = Double(armIndex) * .pi
            let armIsWarm = armIndex == 0

            // Each arm is a series of dust blobs along a logarithmic spiral
            // r = a * e^(b*θ)  — we approximate with linear spacing + exponential scale
            let blobCount = 22
            for i in 0..<blobCount {
                let t = Double(i) / Double(blobCount - 1)  // 0–1 along arm
                let theta = armOffset + rotation + t * 2.6 * .pi  // sweep angle
                let radius = 18.0 + t * (isActive ? 230.0 : 200.0)  // grows outward

                let bx = cx + CGFloat(cos(theta) * radius)
                let by = cy + CGFloat(sin(theta) * radius * 0.45)  // flatten into ellipse

                // Opacity: bright near core, fades at tips
                let tipFade = 1.0 - t * 0.85
                let basePulse = 0.5 + 0.5 * sin(time * 0.3 + Double(i) * 0.4)
                let alpha = tipFade * basePulse * (isActive ? 0.065 : 0.045)

                let blobR = CGFloat(3.0 + t * 18.0)
                context.opacity = alpha
                let rect = CGRect(x: bx - blobR, y: by - blobR * 0.6, width: blobR * 2, height: blobR * 1.2)
                let col = armIsWarm ? Color(red: 1.00, green: 0.88, blue: 0.55)
                                    : Color(red: 0.65, green: 0.82, blue: 1.00)
                context.fill(Path(ellipseIn: rect), with: .color(col))
            }
        }

        // Dust bar across equator (adds depth)
        context.opacity = isActive ? 0.018 : 0.012
        let barRect = CGRect(x: cx - (isActive ? 160 : 140), y: cy - 4, width: isActive ? 320 : 280, height: 8)
        context.fill(Path(roundedRect: barRect, cornerRadius: 4), with: .color(Color(red: 1.0, green: 0.95, blue: 0.80)))
    }

    // MARK: - Draw: Stars

    private func drawStars(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        for star in stars {
            let twinkle = (sin(time * 1.3 + star.phase) + 1.0) / 2.0
            let opacity = star.baseOpacity * (0.15 + 0.85 * twinkle)
            context.opacity = opacity
            let sx = star.x * size.width
            let sy = star.y * size.height
            let r = star.radius
            let rect = CGRect(x: sx - r, y: sy - r, width: r * 2, height: r * 2)
            context.fill(Path(ellipseIn: rect), with: .color(starColors[star.colorIndex]))

            // Larger stars get a subtle cross-diffraction spike
            if r > 1.4 && opacity > 0.55 {
                context.opacity = opacity * 0.30
                var h = Path(); h.move(to: CGPoint(x: sx - r * 3, y: sy)); h.addLine(to: CGPoint(x: sx + r * 3, y: sy))
                var v = Path(); v.move(to: CGPoint(x: sx, y: sy - r * 3)); v.addLine(to: CGPoint(x: sx, y: sy + r * 3))
                context.stroke(h, with: .color(starColors[star.colorIndex]), lineWidth: 0.4)
                context.stroke(v, with: .color(starColors[star.colorIndex]), lineWidth: 0.4)
            }
        }
    }

    // MARK: - Draw: Comets

    private func drawComets(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        for comet in comets {
            let age = time - comet.createdAt
            guard age >= 0 && age < comet.lifetime else { continue }

            let progress = age / comet.lifetime
            let fadeIn  = min(progress * 5.0, 1.0)
            let fadeOut = max(0.0, 1.0 - (progress - 0.4) * 1.8)
            let alpha   = min(fadeIn, fadeOut) * comet.opacity

            let ac = CGFloat(cos(comet.angle))
            let as_ = CGFloat(sin(comet.angle))
            let dist = CGFloat(age) * comet.speed
            let hx = (comet.x + dist * ac) * size.width
            let hy = (comet.y + dist * as_) * size.height
            let tx = hx - comet.tailLength * ac * size.width
            let ty = hy - comet.tailLength * as_ * size.height

            // Gradient tail: transparent → white head
            context.opacity = alpha
            var tailPath = Path()
            tailPath.move(to: CGPoint(x: tx, y: ty))
            tailPath.addLine(to: CGPoint(x: hx, y: hy))
            context.stroke(tailPath, with: .color(.white), lineWidth: 1.0)

            // Bright head dot
            context.opacity = alpha * 1.4
            let hr: CGFloat = 1.5
            context.fill(Path(ellipseIn: CGRect(x: hx - hr, y: hy - hr, width: hr * 2, height: hr * 2)), with: .color(.white))
        }
    }
}
```

- [ ] **Step 2: Verify the file was created**

Run: `ls Zentime/Views/Prototypes/AnimationLayers/GalacticBackgroundLayer.swift`
Expected: file path printed with no error.

- [ ] **Step 3: Commit**

```bash
git add Zentime/Views/Prototypes/AnimationLayers/GalacticBackgroundLayer.swift
git commit -m "feat: add GalacticBackgroundLayer with spiral arms, core glow, tinted stars, comets"
```

---

### Task 2: Wire `GalacticBackgroundLayer` into `HomeView`

**Files:**
- Modify: `Zentime/Views/HomeView.swift`

- [ ] **Step 1: Open `HomeView.swift` and find the background stack**

In `HomeView.swift`, lines 18–21 currently read:
```swift
// Space background
Color.black.ignoresSafeArea()
SpaceBackgroundLayer()
    .ignoresSafeArea()
```

- [ ] **Step 2: Replace `SpaceBackgroundLayer` with `GalacticBackgroundLayer`**

Change those lines to:
```swift
// Galactic background
Color.black.ignoresSafeArea()
GalacticBackgroundLayer()
    .ignoresSafeArea()
```

- [ ] **Step 3: Build and check for compiler errors**

Run:
```bash
xcodebuild -scheme Zentime -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|warning:|BUILD"
```
Expected: `BUILD SUCCEEDED` with no `error:` lines.

- [ ] **Step 4: Commit**

```bash
git add Zentime/Views/HomeView.swift
git commit -m "feat: use GalacticBackgroundLayer on HomeView"
```

---

### Task 3: Wire `GalacticBackgroundLayer` into `ActiveTimerView`

**Files:**
- Modify: `Zentime/Views/ActiveTimerView.swift`

`ActiveTimerView` already uses `ThemedBackground(theme: theme)` as its `.background`. The classic theme has a plain black background with no animated layer. We add `GalacticBackgroundLayer(isActive: true)` for the classic theme only (the space theme), layered beneath `ThemedBackground`.

- [ ] **Step 1: Open `ActiveTimerView.swift` and locate the background modifier**

Line 181 currently reads:
```swift
.background(ThemedBackground(theme: theme))
```

- [ ] **Step 2: Replace single background with a ZStack background**

Change that line to:
```swift
.background {
    ZStack {
        if theme == .classic {
            Color.black.ignoresSafeArea()
            GalacticBackgroundLayer(isActive: true)
                .ignoresSafeArea()
        } else {
            ThemedBackground(theme: theme)
        }
    }
}
```

- [ ] **Step 3: Build and check for compiler errors**

Run:
```bash
xcodebuild -scheme Zentime -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|warning:|BUILD"
```
Expected: `BUILD SUCCEEDED` with no `error:` lines.

- [ ] **Step 4: Commit**

```bash
git add Zentime/Views/ActiveTimerView.swift
git commit -m "feat: galactic core animation on ActiveTimerView (classic theme)"
```

---

### Task 4: Register `GalacticBackgroundLayer.swift` in Xcode project

**Files:**
- Modify: `Zentime.xcodeproj/project.pbxproj`

New Swift files added to the filesystem are not automatically picked up by Xcode — they need to be added to the `.pbxproj`. The easiest way is to run `xcodebuild` which reports if the file is missing, or add it via the project file directly.

- [ ] **Step 1: Check if xcodebuild already sees the file**

Run:
```bash
xcodebuild -scheme Zentime -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "GalacticBackgroundLayer|error:|BUILD"
```

If output contains `BUILD SUCCEEDED` → the file was already picked up (Xcode sometimes picks up files in the same directory group automatically). **Skip to Step 4.**

If output contains `cannot find type 'GalacticBackgroundLayer'` → proceed to Step 2.

- [ ] **Step 2: Add the file via `xcodebuild` file reference**

The safest way without opening Xcode is to use `ruby` with `xcodeproj` gem or manually add the reference. Check if the xcodeproj gem is available:

```bash
gem list xcodeproj 2>/dev/null | head -1
```

If installed, run:
```bash
ruby -e "
require 'xcodeproj'
proj = Xcodeproj::Project.open('Zentime.xcodeproj')
target = proj.targets.find { |t| t.name == 'Zentime' }
group = proj.main_group.find_subpath('Zentime/Views/Prototypes/AnimationLayers', false)
file_ref = group.new_reference('GalacticBackgroundLayer.swift')
target.source_build_phase.add_file_reference(file_ref)
proj.save
"
```

- [ ] **Step 3: If xcodeproj gem is not available, open Xcode and add the file manually**

In Xcode: right-click `Zentime/Views/Prototypes/AnimationLayers` group → "Add Files to Zentime" → select `GalacticBackgroundLayer.swift` → ensure "Add to target: Zentime" is checked → Add.

- [ ] **Step 4: Build again to confirm**

Run:
```bash
xcodebuild -scheme Zentime -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | grep -E "error:|BUILD"
```
Expected: `BUILD SUCCEEDED` with no `error:` lines.

- [ ] **Step 5: Commit pbxproj if it changed**

```bash
git add Zentime.xcodeproj/project.pbxproj
git commit -m "chore: register GalacticBackgroundLayer.swift in Xcode project"
```

---

### Task 5: Final visual verification

- [ ] **Step 1: Boot the simulator**

```bash
xcrun simctl boot "iPhone 16" 2>/dev/null || true
open -a Simulator
```

- [ ] **Step 2: Install and launch**

```bash
xcodebuild -scheme Zentime -destination 'platform=iOS Simulator,name=iPhone 16' -derivedDataPath /tmp/zentime-dd install 2>&1 | tail -5
xcrun simctl launch booted $(xcodebuild -scheme Zentime -showBuildSettings 2>/dev/null | grep PRODUCT_BUNDLE_IDENTIFIER | head -1 | awk '{print $3}')
```

- [ ] **Step 3: Confirm visuals**

On the **HomeView**: golden core bloom visible near top-third, spiral dust arms rotating slowly, tinted stars twinkle, comets streak diagonally every few seconds.

On the **ActiveTimerView** (launch a focus session): same galaxy, slightly brighter/faster, visible behind the progress ring.

- [ ] **Step 4: Final commit**

```bash
git commit --allow-empty -m "feat: galactic core animation complete on HomeView and ActiveTimerView"
```
