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
	// get the pixel from scene
	vec4 pixel = texture(basic_texture, theTexcoord);
	
	
	// get the corresponding pixel from intensity map
	vec4 intensity_pixel = texture(intensity_texture, theTexcoord); 
	
	float enemy_intensity = intensity_pixel.r;
	float player_intensity = intensity_pixel.g;
	
	float basic_intensity = max(enemy_intensity, player_intensity);
	
	// get temporal input and convert it to float, slow down it a little
	float used_time = time;
	used_time = used_time / 50 ;
	
	// take one more pixel from a coordinate randomly shifted in time
	vec4 effect_pixel = texture(basic_texture, theTexcoord + vec2(sin(used_time/10+rotation)*0.01, tan(used_time/10+rotation)*0.007));
	float effect_amount = 10;
	
	float used_multiplier = multiplier + (1-enemy_intensity)*1;
	// shortcuts to simplify notation
	float X = 70*(1-multiplier) - 10*basic_intensity;
	float Y = 70*(1-multiplier) - 10*basic_intensity;
	
	float ac = cos(rotation);
	float as = sin(rotation);
	
	// rotate the texture coordinate
	vec2 rotated_texcoord = theTexcoord;//vec2(theTexcoord.x * ac - theTexcoord.y * as, theTexcoord.x * as + theTexcoord.y * ac);
	
	vec2 rt = rotated_texcoord;
	
	vec2 z = vec2(rotated_texcoord.y, rotated_texcoord.x)*1.2
	- vec2(0.5+sin(used_time/50)*0.15 + 0.1*basic_intensity,0.5+sin(used_time/50)*0.15+ 0.1*basic_intensity)*1.2;
	vec2 c = vec2(0.36+tan(used_time/20 + rotation )*0.007, 0.36+tan(used_time/20 - rotation)*0.007);

	int iterations = 100;
    int i;
    for(i=0; i<iterations; i++) {
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;

        if((x * x + y * y) > 2.0) break;
        z.x = x;
        z.y = y;
    }
	
	float fractal_amnt = ((i == iterations ? 0.0 : float(i)) / iterations);
	
	effect_amount = 15 + (enemy_intensity)*2;
	// totally random calculations that produce interesting color effect
	vec4 my_colors = 
	
	vec4(
		cos(fractal_amnt*used_multiplier*10+rt.x*X+used_time+effect_pixel.r*effect_amount+(enemy_intensity))+sin(rt.y*Y+used_time*2.0+effect_pixel.r*effect_amount),	
		(sin(fractal_amnt*used_multiplier*10+rt.x*Y+effect_pixel.g*effect_amount)+cos(rt.y*X+used_time+effect_pixel.g*effect_amount)),
		(sin(fractal_amnt*used_multiplier*10+rt.x*rt.y+used_time+effect_pixel.b*effect_amount)+cos(rt.y*X+used_time+effect_pixel.b*effect_amount+(enemy_intensity))), 
		1.0
	);
	
	// clamp it
	my_colors = clamp(my_colors, vec4(0.0), vec4(1.0));

	float avg = (my_colors.r + my_colors.g + my_colors.b) / 3;
	my_colors = mix(my_colors, vec4(avg, avg, avg, my_colors.a), enemy_intensity);
	
	float avg_pixel = (pixel.r + pixel.g + pixel.b) / 3;
	
	// interpolate between the actual pixel on scene and the calculated pixel
	outputColor = mix(mix(pixel, vec4(avg_pixel, avg_pixel, avg_pixel, 1.0), multiplier*multiplier), my_colors, basic_intensity * ((my_colors.r +my_colors.g +my_colors.b)/3)
	); 
	//outputColor = vec4(vec3(fractal_amnt), 1.0);
	//outputColor = texture(basic_texture, theTexcoord+vec2(fractal_amnt*0.02, -fractal_amnt*0.02));
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


