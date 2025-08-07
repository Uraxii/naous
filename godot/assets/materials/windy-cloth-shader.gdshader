// a simple ripple/wavy vertex displacement shader
// using a lookup texture - nice for waves and flags

shader_type spatial;

uniform sampler2D clothTexture;
uniform sampler2D windTexture;
uniform float windSpeed = 0.25;
uniform float windStrength = 1.0;

void vertex() {
  vec2 uv = UV;
  float noise_value = texture(windTexture, uv + vec2(TIME * windSpeed, 0.0)).x;
  
  VERTEX.y += (noise_value)
	* windStrength
	* uv.x; // less effect to the left so there is no movement neat flagpole
  
  // and a larger slower sin base movement
  VERTEX.y += (cos(TIME * 3.0 * windSpeed + uv.y*4.0)/4.0)*uv.x;	
}

void fragment() {
	vec4 tex_color = texture(clothTexture, UV);
	ALBEDO = tex_color.rgb;
	ALPHA = tex_color.a;
}