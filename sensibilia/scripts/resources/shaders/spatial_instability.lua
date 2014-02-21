spatial_instability_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, fullscreen_vertex_shader)
spatial_instability_fragment_shader = GLSL_shader(GL.GL_FRAGMENT_SHADER, [[
#version 330
in vec2 theTexcoord;
out vec4 outputColor;

uniform sampler2D basic_texture;
uniform sampler2D intensity_texture;

uniform int time;
uniform float rotation;
uniform float multiplier;

void main() 
{	
	float ac = cos(rotation);
	float as = sin(rotation);
	
	// rotate the texture coordinate
	vec2 rotated_texcoord = vec2(theTexcoord.x * ac - theTexcoord.y * as, theTexcoord.x * as + theTexcoord.y * ac);
	
	// get the pixel from scene
	vec4 pixel = texture(basic_texture, theTexcoord);
	
	// get temporal input and convert it to float, slow down it a little
	float used_time = time;
	used_time = used_time / 20;
	
	// take one more pixel from a coordinate randomly shifted in time
	vec4 effect_pixel = texture(basic_texture, theTexcoord + vec2(sin(used_time/10+rotation)*0.01, tan(used_time/10+rotation)*0.01));
	float effect_amount = 10;
	
	// shortcuts to simplify notation
	float X = 100*multiplier;
	float Y = 100*multiplier;
	vec2 c = rotated_texcoord;
	
	// totally random calculations that produce interesting color effect
	vec4 my_colors = 
	
	vec4(
		cos(c.x*X+used_time+effect_pixel.r*effect_amount)+sin(c.y*Y+used_time*2.0+effect_pixel.r*effect_amount),	
		sin(c.x*Y+effect_pixel.g*effect_amount)+cos(c.y*X+used_time+effect_pixel.g*effect_amount),
		sin(c.x*c.y+used_time+effect_pixel.b*effect_amount)+cos(c.y*X+used_time+effect_pixel.b*effect_amount), 
		1.0
	);
	
	// clamp it
	my_colors = clamp(my_colors, vec4(0.0), vec4(1.0));
	
	// get the corresponding pixel from intensity map
	float intensity = texture(intensity_texture, theTexcoord).r;
	
	// interpolate between the actual pixel on scene and the calculated pixel
	outputColor = mix(pixel, my_colors, intensity); 
}

]])












spatial_instability_program = GLSL_program()
spatial_instability_program:attach(spatial_instability_vertex_shader)
spatial_instability_program:attach(spatial_instability_fragment_shader)
spatial_instability_program:use()
GL.glUniform1i(GL.glGetUniformLocation(spatial_instability_program.id, "basic_texture"), 0)
GL.glUniform1i(GL.glGetUniformLocation(spatial_instability_program.id, "intensity_texture"), 1)

spatial_instability_time = GL.glGetUniformLocation(spatial_instability_program.id, "time")
GL.glUniform1i(spatial_instability_time, 0)

spatial_instability_rotation = GL.glGetUniformLocation(spatial_instability_program.id, "rotation")
GL.glUniform1i(spatial_instability_rotation, 0)

spatial_instability_multiplier = GL.glGetUniformLocation(spatial_instability_program.id, "multiplier")
GL.glUniform1i(spatial_instability_multiplier, 1)


