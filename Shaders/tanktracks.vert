#version 420 core

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec2 a_texcoord;

uniform mat4 modelViewProjectionMatrix;
uniform float trackOffset;

out vec2 v_uv;

void main() {
    v_uv = vec2(mod(a_texcoord.x + trackOffset, 1.0), a_texcoord.y);
    gl_Position = modelViewProjectionMatrix * vec4(a_position, 1.0);
}
