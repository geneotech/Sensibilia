hblur_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, [[

#version 330
layout(location = 0) in vec2 position;

out vec2 theTexcoord;
out vec2 blur_coords[14];

uniform float offset_multiplier;

void main() 
{
	vec4 output_vert;
	output_vert.x = position.x * 2.0 - 1.0;		
	output_vert.y = position.y * 2.0 - 1.0;				
	output_vert.z = 0.0f;						
	output_vert.w = 1.0f;
	
	gl_Position = output_vert;
	theTexcoord = position;
	
	blur_coords[ 0] = theTexcoord + vec2(-0.028, 0.0)*offset_multiplier;
    blur_coords[ 1] = theTexcoord + vec2(-0.024, 0.0)*offset_multiplier;
    blur_coords[ 2] = theTexcoord + vec2(-0.020, 0.0)*offset_multiplier;
    blur_coords[ 3] = theTexcoord + vec2(-0.016, 0.0)*offset_multiplier;
    blur_coords[ 4] = theTexcoord + vec2(-0.012, 0.0)*offset_multiplier;
    blur_coords[ 5] = theTexcoord + vec2(-0.008, 0.0)*offset_multiplier;
    blur_coords[ 6] = theTexcoord + vec2(-0.004, 0.0)*offset_multiplier;
    blur_coords[ 7] = theTexcoord + vec2( 0.004, 0.0)*offset_multiplier;
    blur_coords[ 8] = theTexcoord + vec2( 0.008, 0.0)*offset_multiplier;
    blur_coords[ 9] = theTexcoord + vec2( 0.012, 0.0)*offset_multiplier;
    blur_coords[10] = theTexcoord + vec2( 0.016, 0.0)*offset_multiplier;
    blur_coords[11] = theTexcoord + vec2( 0.020, 0.0)*offset_multiplier;
    blur_coords[12] = theTexcoord + vec2( 0.024, 0.0)*offset_multiplier;
    blur_coords[13] = theTexcoord + vec2( 0.028, 0.0)*offset_multiplier;
}
]])

vblur_vertex_shader = GLSL_shader(GL.GL_VERTEX_SHADER, [[

#version 330
layout(location = 0) in vec2 position;

out vec2 theTexcoord;
out vec2 blur_coords[14];

uniform float offset_multiplier;

void main() 
{
	vec4 output_vert;
	output_vert.x = position.x * 2.0 - 1.0;		
	output_vert.y = position.y * 2.0 - 1.0;				
	output_vert.z = 0.0f;						
	output_vert.w = 1.0f;
	
	gl_Position = output_vert;
	theTexcoord = position;
	
	blur_coords[ 0] = theTexcoord + vec2(0.0, -0.028)*offset_multiplier;
    blur_coords[ 1] = theTexcoord + vec2(0.0, -0.024)*offset_multiplier;
    blur_coords[ 2] = theTexcoord + vec2(0.0, -0.020)*offset_multiplier;
    blur_coords[ 3] = theTexcoord + vec2(0.0, -0.016)*offset_multiplier;
    blur_coords[ 4] = theTexcoord + vec2(0.0, -0.012)*offset_multiplier;
    blur_coords[ 5] = theTexcoord + vec2(0.0, -0.008)*offset_multiplier;
    blur_coords[ 6] = theTexcoord + vec2(0.0, -0.004)*offset_multiplier;
    blur_coords[ 7] = theTexcoord + vec2(0.0,  0.004)*offset_multiplier;
    blur_coords[ 8] = theTexcoord + vec2(0.0,  0.008)*offset_multiplier;
    blur_coords[ 9] = theTexcoord + vec2(0.0,  0.012)*offset_multiplier;
    blur_coords[10] = theTexcoord + vec2(0.0,  0.016)*offset_multiplier;
    blur_coords[11] = theTexcoord + vec2(0.0,  0.020)*offset_multiplier;
    blur_coords[12] = theTexcoord + vec2(0.0,  0.024)*offset_multiplier;
    blur_coords[13] = theTexcoord + vec2(0.0,  0.028)*offset_multiplier;
}
]])

hblur_fragment_shader = GLSL_shader(GL.GL_FRAGMENT_SHADER, [[
#version 330
precision mediump float;
 
uniform sampler2D basic_texture;
 
in vec2 theTexcoord;
in vec2 blur_coords[14];
 
out vec4 outputColor;

void main()
{
    outputColor = vec4(0.0);
    outputColor += texture(basic_texture, blur_coords[ 0])*0.0044299121055113265;
    outputColor += texture(basic_texture, blur_coords[ 1])*0.00895781211794;
    outputColor += texture(basic_texture, blur_coords[ 2])*0.0215963866053;
    outputColor += texture(basic_texture, blur_coords[ 3])*0.0443683338718;
    outputColor += texture(basic_texture, blur_coords[ 4])*0.0776744219933;
    outputColor += texture(basic_texture, blur_coords[ 5])*0.115876621105;
    outputColor += texture(basic_texture, blur_coords[ 6])*0.147308056121;
    outputColor += texture(basic_texture, theTexcoord         )*0.159576912161;
    outputColor += texture(basic_texture, blur_coords[ 7])*0.147308056121;
    outputColor += texture(basic_texture, blur_coords[ 8])*0.115876621105;
    outputColor += texture(basic_texture, blur_coords[ 9])*0.0776744219933;
    outputColor += texture(basic_texture, blur_coords[10])*0.0443683338718;
    outputColor += texture(basic_texture, blur_coords[11])*0.0215963866053;
    outputColor += texture(basic_texture, blur_coords[12])*0.00895781211794;
    outputColor += texture(basic_texture, blur_coords[13])*0.0044299121055113265;
}
]])

vblur_fragment_shader = GLSL_shader(GL.GL_FRAGMENT_SHADER, [[
#version 330
precision mediump float;
 
uniform sampler2D basic_texture;
 
in vec2 theTexcoord;
in vec2 blur_coords[14];
 
out vec4 outputColor;

void main()
{
    outputColor = vec4(0.0);
    outputColor += texture(basic_texture, blur_coords[ 0])*0.0044299121055113265;
    outputColor += texture(basic_texture, blur_coords[ 1])*0.00895781211794;
    outputColor += texture(basic_texture, blur_coords[ 2])*0.0215963866053;
    outputColor += texture(basic_texture, blur_coords[ 3])*0.0443683338718;
    outputColor += texture(basic_texture, blur_coords[ 4])*0.0776744219933;
    outputColor += texture(basic_texture, blur_coords[ 5])*0.115876621105;
    outputColor += texture(basic_texture, blur_coords[ 6])*0.147308056121;
    outputColor += texture(basic_texture, theTexcoord         )*0.159576912161;
    outputColor += texture(basic_texture, blur_coords[ 7])*0.147308056121;
    outputColor += texture(basic_texture, blur_coords[ 8])*0.115876621105;
    outputColor += texture(basic_texture, blur_coords[ 9])*0.0776744219933;
    outputColor += texture(basic_texture, blur_coords[10])*0.0443683338718;
    outputColor += texture(basic_texture, blur_coords[11])*0.0215963866053;
    outputColor += texture(basic_texture, blur_coords[12])*0.00895781211794;
    outputColor += texture(basic_texture, blur_coords[13])*0.0044299121055113265;
}
]])

hblur_program = GLSL_program()
hblur_program:attach(hblur_vertex_shader)
hblur_program:attach(hblur_fragment_shader)
hblur_program:use()
GL.glUniform1i(GL.glGetUniformLocation(hblur_program.id, "basic_texture"), 0)

h_offset_multiplier = GL.glGetUniformLocation(hblur_program.id, "offset_multiplier")
GL.glUniform1f(h_offset_multiplier, 1/5)



vblur_program = GLSL_program()
vblur_program:attach(vblur_vertex_shader)
vblur_program:attach(vblur_fragment_shader)
vblur_program:use()
GL.glUniform1i(GL.glGetUniformLocation(vblur_program.id, "basic_texture"), 0)

v_offset_multiplier = GL.glGetUniformLocation(vblur_program.id, "offset_multiplier")
GL.glUniform1f(v_offset_multiplier, 1/5)