#version 120

varying vec2 v_uv;
uniform sampler2D tex0;

void main()
{
    gl_FragColor = texture2D(tex0, v_uv);
}
