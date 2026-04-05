# Cosmic Aurora Background Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace `GalacticBackgroundLayer` with a high-quality Metal shader aurora background (violet + indigo + electric blue) inspired by Inigo Quilez's FBM aurora technique, used on both `HomeView` and `ActiveTimerView`.

**Architecture:** A `.metal` file contains a fragment shader using Fractional Brownian Motion (FBM) noise to produce animated aurora curtains. A SwiftUI `AuroraBackgroundView` applies the shader via `.colorEffect` and layers a Canvas-based star field on top. The new view replaces `GalacticBackgroundLayer` everywhere it is used.

**Tech Stack:** Metal (MSL), SwiftUI Canvas + TimelineView, SwiftUI `.colorEffect` (iOS 17+)

---

## File Map

| Action | Path | Responsibility |
|--------|------|---------------|
| Create | `Zentime/Shaders/AuroraShader.metal` | FBM aurora fragment shader in MSL |
| Create | `Zentime/Views/Backgrounds/AuroraBackgroundView.swift` | SwiftUI view: shader layer + star canvas |
| Modify | `Zentime/Views/HomeView.swift` | Swap `GalacticBackgroundLayer` → `AuroraBackgroundView` |
| Modify | `Zentime/Views/ActiveTimerView.swift` | Swap `GalacticBackgroundLayer(isActive: true)` → `AuroraBackgroundView(isActive: true)` |
| Delete | `Zentime/Views/Prototypes/AnimationLayers/GalacticBackgroundLayer.swift` | Replaced entirely |

---

## Task 1: Create the Metal Aurora Shader

**Files:**
- Create: `Zentime/Shaders/AuroraShader.metal`

This shader uses layered FBM noise to produce drifting aurora curtains. The color palette is violet + indigo + electric blue. The `time` uniform drives all animation. This is a `[[ color_effect ]]` shader — it receives the original pixel color and the position, and outputs a new color.

- [ ] **Step 1: Create the Shaders directory and Metal file**

Create `Zentime/Shaders/AuroraShader.metal` with this exact content:

```metal
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// --- Noise helpers ---

float hash(float2 p) {
    p = fract(p * float2(127.1, 311.7));
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(hash(i + float2(0,0)), hash(i + float2(1,0)), u.x),
        mix(hash(i + float2(0,1)), hash(i + float2(1,1)), u.x),
        u.y
    );
}

// Fractional Brownian Motion — 5 octaves
float fbm(float2 p) {
    float v = 0.0;
    float amp = 0.5;
    float2x2 rot = float2x2(0.8, -0.6, 0.6, 0.8);
    for (int i = 0; i < 5; i++) {
        v += amp * noise(p);
        p = rot * p * 2.1;
        amp *= 0.5;
    }
    return v;
}

// --- Aurora color palette: violet / indigo / electric blue ---
float3 auroraColor(float t) {
    // t in [0,1]: maps to the aurora palette
    float3 violet  = float3(0.42, 0.18, 1.00);
    float3 indigo  = float3(0.22, 0.10, 0.80);
    float3 blue    = float3(0.08, 0.30, 1.00);
    float3 deepVio = float3(0.55, 0.05, 0.90);

    if (t < 0.33)
        return mix(indigo, violet, t / 0.33);
    else if (t < 0.66)
        return mix(violet, blue, (t - 0.33) / 0.33);
    else
        return mix(blue, deepVio, (t - 0.66) / 0.34);
}

// --- Main shader ---
[[ stitchable ]]
half4 auroraEffect(float2 position,
                   half4 currentColor,
                   float2 size,
                   float time)
{
    // Normalize to [0,1], flip Y so top is 0
    float2 uv = position / size;
    float2 p  = uv * float2(2.5, 1.8);   // aspect + density scale

    // Slow horizontal drift
    p.x += time * 0.018;

    // Domain warp: offset sampling position by fbm to get wispy edges
    float2 warp = float2(fbm(p + float2(0.0, time * 0.04)),
                         fbm(p + float2(3.2, time * 0.04)));
    float2 warped = p + 0.55 * warp;

    // Aurora curtain: vertical FBM band
    float curtain = fbm(warped + float2(time * 0.012, 0.0));

    // Intensity falloff: brighter near top, fades at bottom
    float topFade    = smoothstep(0.85, 0.0, uv.y);  // strong near top
    float bottomFade = smoothstep(0.0, 0.55, uv.y);  // fade in from very top edge
    float intensity  = curtain * topFade * bottomFade;

    // Remap to sharpen bands
    intensity = pow(intensity, 1.4);
    intensity = clamp(intensity * 1.6, 0.0, 1.0);

    // Subtle slow pulse
    float pulse = 0.85 + 0.15 * sin(time * 0.35 + fbm(p * 0.5) * 6.28);
    intensity *= pulse;

    // Color from palette driven by warped FBM value + slow shift
    float colorT = fract(curtain * 1.4 + time * 0.025);
    float3 col = auroraColor(colorT);

    // Deep space background: near-black with slight blue tint
    float3 bg = float3(0.005, 0.002, 0.025);
    float3 final = mix(bg, col, intensity * 0.88);

    return half4(half3(final), 1.0);
}
```

- [ ] **Step 2: Register the Shaders folder in Xcode**

In Xcode:
1. Right-click `Zentime` group in the Project Navigator
2. Choose "New Group" → name it `Shaders`
3. Right-click `Shaders` group → "Add Files to Zentime..."
4. Select `Zentime/Shaders/AuroraShader.metal`
5. Make sure "Add to target: Zentime" is checked

> **Why this matters:** Metal files must be in the Xcode project to be compiled. The `.metal` extension is enough for Xcode to include them in the Metal shader library automatically — no `Build Phases` edits needed beyond adding the file.

- [ ] **Step 3: Build to verify shader compiles**

In Xcode: Product → Build (⌘B)

Expected: Build succeeds with no errors. If you see `error: use of undeclared identifier 'auroraEffect'` it means the file wasn't added to the target — repeat Step 2.

- [ ] **Step 4: Commit**

```bash
git add Zentime/Shaders/AuroraShader.metal
git commit -m "feat: add FBM aurora Metal shader (violet/indigo/blue palette)"
```

---

## Task 2: Create AuroraBackgroundView

**Files:**
- Create: `Zentime/Views/Backgrounds/AuroraBackgroundView.swift`

This SwiftUI view has two layers stacked in a `ZStack`:
1. A `Rectangle` with `.colorEffect` applying `auroraEffect` — driven by `TimelineView(.animation)`
2. A `Canvas` drawing twinkling stars on top

- [ ] **Step 1: Create the Backgrounds directory and Swift file**

Create `Zentime/Views/Backgrounds/AuroraBackgroundView.swift`:

```swift
import SwiftUI

// MARK: - Star model

private struct Star {
    let x: CGFloat        // 0–1 normalized
    let y: CGFloat        // 0–1 normalized
    let radius: CGFloat   // pt
    let baseOpacity: Double
    let phase: Double
    let twinkleFreq: Double
}

// MARK: - AuroraBackgroundView

struct AuroraBackgroundView: View {
    /// Pass true on the active-timer screen for slightly more intense aurora.
    var isActive: Bool = false

    @State private var stars: [Star] = []

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                ZStack {
                    // Layer 1: Metal aurora shader
                    Rectangle()
                        .colorEffect(
                            ShaderLibrary.auroraEffect(
                                .float2(geo.size),
                                .float(Float(t) * (isActive ? 1.25 : 1.0))
                            )
                        )

                    // Layer 2: Star field
                    Canvas { context, size in
                        drawStars(context: &context, size: size, time: t)
                    }
                }
                .onAppear {
                    generateStars(in: geo.size)
                }
            }
        }
    }

    // MARK: - Star generation

    private func generateStars(in size: CGSize) {
        let count = isActive ? 100 : 150
        stars = (0..<count).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                radius: CGFloat.random(in: 0.3...1.6),
                baseOpacity: Double.random(in: 0.20...0.75),
                phase: Double.random(in: 0...(2 * .pi)),
                twinkleFreq: Double.random(in: 0.3...1.0)
            )
        }
    }

    // MARK: - Star drawing

    private func drawStars(context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        for star in stars {
            let twinkle = (sin(time * star.twinkleFreq + star.phase) + 1.0) / 2.0
            let opacity = star.baseOpacity * (0.15 + 0.85 * twinkle)
            context.opacity = opacity

            let sx = star.x * size.width
            let sy = star.y * size.height
            let r  = star.radius
            context.fill(
                Path(ellipseIn: CGRect(x: sx - r, y: sy - r, width: r * 2, height: r * 2)),
                with: .color(.white)
            )

            // Diffraction cross for larger bright stars
            if r > 1.1 && opacity > 0.5 {
                context.opacity = opacity * 0.25
                var h = Path()
                h.move(to: CGPoint(x: sx - r * 3.5, y: sy))
                h.addLine(to: CGPoint(x: sx + r * 3.5, y: sy))
                var v = Path()
                v.move(to: CGPoint(x: sx, y: sy - r * 3.5))
                v.addLine(to: CGPoint(x: sx, y: sy + r * 3.5))
                context.stroke(h, with: .color(Color(red: 0.8, green: 0.85, blue: 1.0)), lineWidth: 0.4)
                context.stroke(v, with: .color(Color(red: 0.8, green: 0.85, blue: 1.0)), lineWidth: 0.4)
            }
        }
    }
}

#Preview {
    AuroraBackgroundView()
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
}
```

- [ ] **Step 2: Register the file in Xcode**

In Xcode:
1. Right-click `Views` group → "New Group" → name it `Backgrounds`
2. Right-click `Backgrounds` group → "Add Files to Zentime..."
3. Select `Zentime/Views/Backgrounds/AuroraBackgroundView.swift`
4. Ensure "Add to target: Zentime" is checked

- [ ] **Step 3: Build to verify it compiles**

⌘B. Expected: success. Common error: `'auroraEffect' is not a member of 'ShaderLibrary'` — this means the `.metal` file isn't compiled into the target. Revisit Task 1 Step 2.

- [ ] **Step 4: Run the preview**

Open `AuroraBackgroundView.swift`, click Resume in the canvas. You should see a full-screen aurora animation with stars. If the preview shows a black screen with no animation, make sure `TimelineView(.animation)` is inside the view body (it is — just verify the file saved correctly).

- [ ] **Step 5: Commit**

```bash
git add Zentime/Views/Backgrounds/AuroraBackgroundView.swift
git commit -m "feat: add AuroraBackgroundView (Metal shader + star canvas)"
```

---

## Task 3: Wire AuroraBackgroundView into HomeView

**Files:**
- Modify: `Zentime/Views/HomeView.swift`

Replace the two lines that set the background (black + `GalacticBackgroundLayer`) with `AuroraBackgroundView`.

- [ ] **Step 1: Edit HomeView.swift**

In `HomeView.swift`, find this block (lines 16–19):

```swift
// Galactic background
Color.black.ignoresSafeArea()
GalacticBackgroundLayer()
    .ignoresSafeArea()
```

Replace it with:

```swift
// Aurora background
AuroraBackgroundView()
    .ignoresSafeArea()
```

- [ ] **Step 2: Build and run on simulator**

⌘R. On the HomeView you should see the violet/indigo/blue aurora animating behind the streak card, start button, and mode selector. Stars should be twinkling on top.

- [ ] **Step 3: Commit**

```bash
git add Zentime/Views/HomeView.swift
git commit -m "feat: use AuroraBackgroundView on HomeView"
```

---

## Task 4: Wire AuroraBackgroundView into ActiveTimerView

**Files:**
- Modify: `Zentime/Views/ActiveTimerView.swift`

- [ ] **Step 1: Find the background block in ActiveTimerView**

In `ActiveTimerView.swift`, search for `GalacticBackgroundLayer`. It appears around line 185 inside a `ZStack` that also has `ThemedBackground`. The block looks like:

```swift
GalacticBackgroundLayer(isActive: true)
    .ignoresSafeArea()
```

Replace it with:

```swift
AuroraBackgroundView(isActive: true)
    .ignoresSafeArea()
```

- [ ] **Step 2: Build and run**

⌘R. Navigate to an active timer session — the aurora should appear on that screen too, slightly more intense than on HomeView (the `isActive: true` parameter speeds up the time uniform by 1.25×).

- [ ] **Step 3: Commit**

```bash
git add Zentime/Views/ActiveTimerView.swift
git commit -m "feat: use AuroraBackgroundView on ActiveTimerView"
```

---

## Task 5: Delete GalacticBackgroundLayer

**Files:**
- Delete: `Zentime/Views/Prototypes/AnimationLayers/GalacticBackgroundLayer.swift`

- [ ] **Step 1: Delete the file**

In Xcode, right-click `GalacticBackgroundLayer.swift` in the Project Navigator → Delete → "Move to Trash".

Alternatively from terminal:
```bash
rm Zentime/Views/Prototypes/AnimationLayers/GalacticBackgroundLayer.swift
```
Then in Xcode, the file reference will show in red — right-click it → Delete.

- [ ] **Step 2: Build to confirm no dangling references**

⌘B. Expected: success with no "use of unresolved identifier 'GalacticBackgroundLayer'" errors. If you see that error, search the codebase:

```bash
grep -r "GalacticBackgroundLayer" Zentime/ --include="*.swift"
```

Fix any remaining references by replacing with `AuroraBackgroundView`.

- [ ] **Step 3: Commit**

```bash
git add -u
git commit -m "chore: remove GalacticBackgroundLayer (replaced by AuroraBackgroundView)"
```

---

## Task 6: Verify and Final Build

- [ ] **Step 1: Full clean build**

In Xcode: Product → Clean Build Folder (⌘⇧K), then ⌘B.

Expected: 0 errors, 0 warnings related to aurora/shader code.

- [ ] **Step 2: Run on device or simulator and verify both screens**

- HomeView: aurora animating, stars twinkling, UI cards readable on top
- ActiveTimerView: aurora slightly more intense (`isActive: true`)

- [ ] **Step 3: Verify xcodebuild from terminal**

```bash
xcodebuild -scheme Zentime -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```

Expected last line: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Final commit**

```bash
git add -A
git commit -m "chore: final cleanup after aurora background implementation"
```
