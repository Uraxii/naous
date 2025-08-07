// a simple ripple/wavy vertex displacement shader
// using a lookup texture - nice for waves and flags

shader_type spatial;

uniform sampler2D windTexture;
uniform float windSpeed = 1.0;
uniform float windStrength = 1.0;

void vertex() {
  vec2 uv = UV;
  float noise_value = texture(windTexture, uv + vec2(TIME * windSpeed, 0.0)).r;
  VERTEX.y += (noise_value - 0.5) * windStrength * uv.r; // less effect to the left
}