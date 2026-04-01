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
