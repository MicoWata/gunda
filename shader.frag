#version 460 core

#include <flutter/runtime_effect.glsl>

uniform float width;
uniform float height;
uniform float time;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / vec2(width, height);
    vec3 color = vec3(uv.x, uv.y, abs(sin(time)));
    fragColor = vec4(color, 1.0);
}
