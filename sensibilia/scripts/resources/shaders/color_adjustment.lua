color_adjustment_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, fullscreen_vertex_shader)
color_adjustment_fragment_shader = GLSL_shader(GL.GL_FRAGMENT_SHADER, [[
#version 330
in vec2 theTexcoord;
out vec4 outputColor;

uniform sampler2D basic_texture;

vec3 ContrastSaturationBrightness(vec3 color, float brt, float sat, float con)
{
	// Increase or decrease theese values to adjust r, g and b color channels seperately
	const float AvgLumR = 0.5;
	const float AvgLumG = 0.5;
	const float AvgLumB = 0.5;
	
	const vec3 LumCoeff = vec3(0.2125, 0.7154, 0.0721);
	
	vec3 AvgLumin = vec3(AvgLumR, AvgLumG, AvgLumB);
	vec3 brtColor = color * brt;
	vec3 intensity = vec3(dot(brtColor, LumCoeff));
	vec3 satColor = mix(intensity, brtColor, sat);
	vec3 conColor = mix(AvgLumin, satColor, con);
	return conColor;
}

void main() 
{	
	vec4 pixel = texture(basic_texture, theTexcoord);
	outputColor = vec4(ContrastSaturationBrightness(pixel.rgb, 1.2, 1.0, 2.0), 1.0);
}

]])


color_adjustment_program = GLSL_program()
color_adjustment_program:attach(color_adjustment_vertex_shader)
color_adjustment_program:attach(color_adjustment_fragment_shader)
color_adjustment_program:use()
GL.glUniform1i(GL.glGetUniformLocation(color_adjustment_program.id, "basic_texture"), 0)


