chromatic_aberration_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, fullscreen_vertex_shader)
chromatic_aberration_fragment_shader = GLSL_shader(GL.GL_FRAGMENT_SHADER, [[
#version 330
in vec2 theTexcoord;
out vec4 outputColor;

uniform sampler2D basic_texture;
uniform vec2 aberration_offset;

void main() 
{	
    vec4 fbo1 = texture(basic_texture, theTexcoord - aberration_offset);  
    vec4 fbo2 = texture(basic_texture, theTexcoord - aberration_offset/3);  
    vec4 fbo3 = texture(basic_texture, theTexcoord + aberration_offset);

    vec4 colFinal = vec4(fbo1.r, fbo2.g, fbo3.b, 1.);	

	outputColor = colFinal;
}

]])


chromatic_aberration_program = GLSL_program()
chromatic_aberration_program:attach(chromatic_aberration_vertex_shader)
chromatic_aberration_program:attach(chromatic_aberration_fragment_shader)
chromatic_aberration_program:use()
GL.glUniform1i(GL.glGetUniformLocation(chromatic_aberration_program.id, "basic_texture"), 0)

chromatic_aberration_offset = GL.glGetUniformLocation(chromatic_aberration_program.id, "aberration_offset")
GL.glUniform2f(chromatic_aberration_offset, 0.003, 0.003)