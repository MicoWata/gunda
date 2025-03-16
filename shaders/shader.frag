#version 460 core

#include <flutter/runtime_effect.glsl>

uniform float width;
uniform float height;
uniform float time;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / vec2(width, height);
    
    // Animated color wave
    float wave = sin(uv.x * 10.0 + time) * 0.5 + 0.5;
    
    // Circular animation
    vec2 center = vec2(0.5, 0.5);
    float dist = length(uv - center);
    float circle = smoothstep(0.3, 0.31, dist + sin(time) * 0.1);
    
    // Color composition
    vec3 color = vec3(
        wave,
        sin(time) * 0.5 + 0.5,
        cos(time) * 0.5 + 0.5
    );
    
    // Animated alpha
    float alpha = mix(0.1, 0.2, wave);
    
    fragColor = vec4(color, alpha);
}
