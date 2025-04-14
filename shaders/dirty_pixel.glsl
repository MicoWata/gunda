#version 460 core
#include <flutter/runtime_effect.glsl>

// Uniforms provided by Flutter
uniform vec2 uResolution; // The size of the paint area
uniform float uTime;      // Time elapsed, for animation

// Output color for the fragment
out vec4 fragColor;

// Simple pseudo-random number generator
// Takes a 2D vector and returns a float between 0.0 and 1.0
float random(vec2 st) {
    // Using sine and dot product for a simple hash-like function
    // The specific numbers are arbitrary "magic numbers" often used in procedural generation
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Noise function based on the random generator
// Smooths the random output using interpolation
float noise(vec2 st) {
    vec2 i = floor(st); // Integer part of the coordinate
    vec2 f = fract(st); // Fractional part of the coordinate

    // Four corners of the grid cell
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smoothly interpolate between the corners based on the fractional part
    vec2 u = f * f * (3.0 - 2.0 * f); // Smoothstep function: 3x^2 - 2x^3
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}


void main() {
    // Get the fragment coordinates normalized to the range [0, 1]
    vec2 uv = FlutterFragCoord().xy / uResolution.xy;

    // --- Dirty Pixel Effect ---

    // 1. Base Layer (Subtle Noise)
    // Generate low-frequency noise for a subtle background variation
    float baseNoise = noise(uv * 5.0 + uTime * 0.1) * 0.05; // Slow moving, large scale noise

    // 2. Pixel Grid "Dirt"
    // Create a grid effect by flooring the UV coordinates scaled up
    // This gives us a coordinate that's constant within each "pixel" block
    vec2 gridUv = floor(uv * 150.0) / 150.0; // Adjust 150.0 to change pixel size

    // Generate a random value for this grid cell
    float dirtRandom = random(gridUv + floor(uTime * 2.0)); // Change pattern over time

    // Determine if this "pixel" should be dirty
    float dirtMask = 0.0;
    float dirtThreshold = 0.98; // Only a small percentage of pixels are dirty (adjust 0.0 to 1.0)
    if (dirtRandom > dirtThreshold) {
        dirtMask = (dirtRandom - dirtThreshold) / (1.0 - dirtThreshold); // Intensity of dirt
        dirtMask = pow(dirtMask, 2.0); // Make it more pronounced
    }

    // 3. Combine Effects
    // Start with a transparent base
    vec4 color = vec4(0.0, 0.0, 0.0, 0.0);

    // Add the subtle base noise as a slight alpha variation
    color.a += baseNoise;

    // Add the "dirt" - make dirty pixels slightly darker and more opaque
    // Using a dark brown/grey color for dirt
    vec3 dirtColor = vec3(0.1, 0.08, 0.05);
    color.rgb += dirtColor * dirtMask * 0.5; // Add color based on dirt mask
    color.a += dirtMask * 0.1; // Increase opacity slightly for dirty pixels

    // Ensure alpha stays within valid range
    color.a = clamp(color.a, 0.0, 1.0);

    // Set the final fragment color
    fragColor = color;
}
