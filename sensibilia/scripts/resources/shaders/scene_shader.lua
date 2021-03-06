
scene_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, [[
#version 330

uniform mat4 projection_matrix;
layout(location = 0) in vec2 position;
layout(location = 1) in vec2 texcoord;
layout(location = 2) in vec4 color;

uniform vec2 player_pos;
uniform float shift_amount;
uniform int time;

smooth out vec4 theColor;
 out vec2 theTexcoord;

void main() 
{
	float used_time = time;
	vec4 normal_vert = projection_matrix*vec4(position.xy, 0.0f, 1.0f);
	
	vec4 output_vert = vec4(normal_vert.xy + normalize(player_pos - position) * (-1.1) * sin(time/2000.0+shift_amount/3000*position.x)*(shift_amount/850)
	//+ (cos(normal_vert.x/300 + used_time/800.0) + sin(used_time/800.0 + normal_vert.x/800.0 + player_pos.x/100.0 + player_pos.y/100.0))*shift_amount/300.0
	,

	0.0f, 1.0f);
	
	gl_Position = output_vert;
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
scene_shader_time_uniform = GL.glGetUniformLocation(scene_program.id, "time")


GL.glUniform1i(GL.glGetUniformLocation(scene_program.id, "basic_texture"), 0)

GL.glUniform2f(player_pos_uniform, 0, 0)
GL.glUniform1f(shift_amount_uniform, 0)
GL.glUniform1i(scene_shader_time_uniform, 0)