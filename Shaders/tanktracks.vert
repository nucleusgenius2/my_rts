#version 120                       // ядро GLSL 1.20

attribute vec3 a_vertex;           // то, что Spring передаёт автоматически
attribute vec2 a_texcoord;

varying   vec2 v_uv;

uniform float trackOffset;         // смещение, которое пишет виджет

void main()
{
    v_uv = vec2(mod(a_texcoord.x + trackOffset, 1.0), a_texcoord.y);
    gl_Position = gl_ModelViewProjectionMatrix * vec4(a_vertex, 1.0);
}
