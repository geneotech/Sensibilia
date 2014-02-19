
scene_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, [[
#version 330

uniform mat4 projection_matrix;
layout(location = 0) in vec2 position;
layout(location = 1) in vec2 texcoord;
layout(location = 2) in vec4 color;

uniform vec2 player_pos;
uniform float shift_amount;

smooth out vec4 theColor;
 out vec2 theTexcoord;

void main() 
{
	vec4 output_vert = vec4(position.xy + normalize(player_pos - position)*shift_amount, 0.0f, 1.0f);
	//output_vert.x = position.x;		
	//output_vert.y = position.y;				
	//output_vert.z = 0.0f;						
	//output_vert.w = 1.0f;
	
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

player_pos_uniform = GL.glGetUniformLocation(scene_program.id, "player_pos")
shift_amount_uniform = GL.glGetUniformLocation(scene_program.id, "shift_amount")


GL.glUniform1i(GL.glGetUniformLocation(scene_program.id, "basic_texture"), 0)

GL.glUniform2f(player_pos_uniform, 0, 0)
GL.glUniform1f(shift_amount_uniform, 0)