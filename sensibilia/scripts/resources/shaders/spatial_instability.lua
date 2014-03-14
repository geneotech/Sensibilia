spatial_instability_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, fullscreen_vertex_shader)
spatial_instability_fragment_shader = GLSL_shader(GL.GL_FRAGMENT_SHADER, [[
#version 330
in vec2 theTexcoord;
out vec4 outputColor;

uniform sampler2D basic_texture;
uniform sampler2D intensity_texture;

uniform int time;
uniform float rotation;
uniform float zoom;
uniform float multiplier;
uniform vec2 player_pos;
uniform vec2 crosshair_pos;

uniform vec3 light_attenuation;


vec4 desaturated(vec4 input_v) {
	float avg_pixel = (input_v.r + input_v.g + input_v.b) / 3;
	return vec4(avg_pixel, avg_pixel, avg_pixel, 1.0);
}
	

float radtodeg(float f) {
	return f / 0.01745329251994329576923690768489; 
}

vec2 rotate(vec2 v, vec2 origin, float angle) {
	angle *= 0.01745329251994329576923690768489;
	float s = sin(angle);
	float c = cos(angle);
	vec2 rotated;

	v -= origin;

	rotated.x = v.x * c - v.y * s;
	rotated.y = v.x * s + v.y * c;

	return v = (rotated + origin);
}
	

void main() 
{	

	// get temporal input and convert it to float, slow down it a little
	float used_time = time;
	used_time = used_time / 520 ;
	
	
	// get the pixel from scene
	vec4 pixel = texture(basic_texture, theTexcoord);
	
	// get the corresponding pixel from intensity map
	vec4 intensity_pixel = texture(intensity_texture, theTexcoord); 
	
	float enemy_intensity = intensity_pixel.r;
	float player_intensity = intensity_pixel.g;
	
	float[3] intensities;
	{
		vec2 res = vec2(1920, 1080);
		
		vec2 r_fcoord = rotate(gl_FragCoord.xy, player_pos, radtodeg(rotation) + 90.0);
		vec2 ppos = player_pos/res;
		
		vec2 uv = r_fcoord.xy/res;
		
		 
		 
		intensities[0] = int(abs(
		
		//1-smoothstep(0.0, 0.0010*(sin(used_time/40)+1.1)+0.06*multiplier, abs(
		
		(1+cos(uv.x*0.2-used_time)/cos(uv.x*2-used_time/20)/3-(1-ppos.y)
		
		
		//) - uv.y));
		
		) - uv.y) < 0.0008*(sin(used_time/40)+1.01)+0.06*multiplier );
		intensities[1] = int(abs(
		
		(1+sin(uv.x*0.2-used_time)/cos(uv.x*2-used_time/20)/2-(1-ppos.y)
		
		) - uv.y) < 0.0006*multiplier+ 0.010*(cos(used_time/70)+1.01));
		intensities[2]	=	int(abs(
		
		(1+cos(uv.x*0.2-used_time)/sin(uv.x*2-used_time/20)/3-(1-ppos.y)
		
		) - uv.y) < 0.0006*multiplier+ 0.010*(sin(used_time/50)+1.01));	
	}
		
	float earlier = player_intensity;
	player_intensity *= (intensities[0] + intensities[1] + intensities[2]);
	player_intensity += earlier;
	
	float light_intensity = intensity_pixel.b + player_intensity;
	
	// take one more pixel from a coordinate randomly shifted in time
	vec4 effect_pixel = texture(basic_texture, theTexcoord + vec2(0.02, -0.02) //+sin(used_time/100)//+ vec2(0.04, 0.04)*multiplier
	//(player_intensity + enemy_intensity*10)*
	//vec2(player_intensity*0.09+sin(used_time/10+rotation)*0.017+0.09-multiplier, player_intensity*0.09+sin(used_time/10+rotation)*0.017-0.09*multiplier)
	
	);
	
	float light_distance = length(gl_FragCoord.xy - player_pos) * zoom;
	float crosshair_light_distance = length(gl_FragCoord.xy - crosshair_pos) * zoom;
	
	float aux = (crosshair_light_distance/352 + 0.01);
	float crosshair_light_factor = 1.0/(0.00001+0.0001*crosshair_light_distance+0.01*crosshair_light_distance*crosshair_light_distance);
	vec3 used_attenuation = light_attenuation; //* (1-multiplier);
	
	
	float light_factor = //(light_intensity*light_intensity) 
	((light_intensity*((1-enemy_intensity)+0.01))* (
	//1.0/((light_distance/1500 + 1.0)*(light_distance/1500 + 1.0))
	1.0/(used_attenuation.x+used_attenuation.y*light_distance+used_attenuation.z*light_distance*light_distance)
	
	+ 
	crosshair_light_factor)
	
	* (1+(tan(used_time/5000000*(1-multiplier))*0.07*multiplier)));
	

	
	
	//float avg_pixel = (pixel.r + pixel.g + pixel.b) / 3;
	
	vec4 desat = desaturated(pixel);
	vec4 final_pixel = mix(pixel, desat, 0.7+sin(used_time/280)*0.3);
		
	
	
	final_pixel = mix(final_pixel, vec4(vec3(153*sin(used_time), 85*cos(used_time), 187*tan(used_time))/255.0, 1.0), (enemy_intensity + player_intensity)*(intensities[0] + intensities[1] + intensities[2]));
	final_pixel = mix(vec4(0.7) * (vec4(-0.2) + final_pixel), vec4(2.5) * (vec4(0.1) + final_pixel), 
	light_factor
	
	); 
	
	outputColor = final_pixel;
	//outputColor = pixel;
	outputColor.a = 1 - player_intensity * enemy_intensity;
	
	//{
	//	vec2 res = vec2(]] .. config_table.resolution_w .. [[,]] .. config_table.resolution_h .. [[);
	//	
	//	vec2 r_fcoord = rotate(gl_FragCoord.xy, player_pos, radtodeg(rotation) + 90.0);
	//	vec2 ppos = player_pos/res;
	//	
	//	vec2 uv = r_fcoord.xy/res;
    //
	//	
	//	
	//	outputColor += vec4(0, 0, abs(
	//	
	//	(1+sin(uv.x*20+used_time)*cos(uv.x+used_time/20)/16-(1-ppos.y)
	//	
	//	) - uv.y) < 0.01, 0);
	//	
	//	outputColor += vec4(abs((1+cos(uv.x*20+used_time)*cos(uv.x+used_time/20)/16-(1-ppos.y)) - uv.y) < 0.001, 0, 0, 0);
	//}



	//* ((my_colors.r +my_colors.g +my_colors.b)/3);
//outputColor = vec4(vec3(light_intensity), 1.0);	
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

spatial_instability_player_pos = GL.glGetUniformLocation(spatial_instability_program.id, "player_pos")
GL.glUniform2f(spatial_instability_player_pos, 0, 0)

spatial_instability_crosshair_pos = GL.glGetUniformLocation(spatial_instability_program.id, "crosshair_pos")
GL.glUniform2f(spatial_instability_crosshair_pos, 0, 0)

spatial_instability_light_attenuation = GL.glGetUniformLocation(spatial_instability_program.id, "light_attenuation")
GL.glUniform3f(spatial_instability_light_attenuation, 0.51166, 0.002001, 0.0000002)

spatial_instability_zoom = GL.glGetUniformLocation(spatial_instability_program.id, "zoom")
GL.glUniform1f(spatial_instability_zoom, 1)

