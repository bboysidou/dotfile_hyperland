#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec2 texel;
    vec4 outlineColour;
    float stroke;
    float strength;
    float solidFrom;
    float solidTo;
};

layout(binding = 1) uniform sampler2D source;

const int RING = 16;
const float TAU = 6.28318530718;

float solid(vec2 uv) {
    return smoothstep(solidFrom, solidTo, texture(source, uv).a);
}

void main() {
    vec4 base = texture(source, qt_TexCoord0);
    float near = 0.0;

    for (int i = 0; i < RING; ++i) {
        float angle = TAU * float(i) / float(RING);
        vec2 dir = vec2(cos(angle), sin(angle)) * texel;
        near = max(near, solid(qt_TexCoord0 + dir * stroke));
        near = max(near, solid(qt_TexCoord0 + dir * stroke * 0.5));
    }

    float edge = near * (1.0 - smoothstep(solidFrom, solidTo, base.a)) * strength;
    fragColor = mix(base, outlineColour, edge) * qt_Opacity;
}
