
scene_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, [[
#version 330

uniform mat4 projection_matrix;
layout(location = 0) in vec2 position;
layout(location = 1) in vec2 texcoord;
layout(location = 2) in vec4 color;

smooth out vec4 theColor;
 out vec2 theTexcoord;

void main() 
{
	vec4 output_vert;
	output_vert.x = position.x;		
	output_vert.y = position.y;				
	output_vert.z = 0.0f;						
	output_vert.w = 1.0f;
	
	gl_Position = projection_matrix*output_vert;
	theColor = color;
	theTexcoord = texcoord;
}

]])
 
scene_fragment_shader = GLSL_shader(GL.GL_FRAGMENT_SHADER, [[
#version 330
smooth in vec4 theColor;
 in vec2 theTexcoord;

out vec4 outputColor;

uniform sampler2D basic_texture;

void main() 
{
    outputColor = theColor * texture(basic_texture, theTexcoord);
}

]])


scene_program = GLSL_program()
scene_program:attach(scene_vertex_shader)
scene_program:attach(scene_fragment_shader)
scene_program:use()

projection_matrix_uniform = GL.glGetUniformLocation(scene_program.id, "projection_matrix")
GL.glUniform1i(GL.glGetUniformLocation(scene_program.id, "basic_texture"), 0)