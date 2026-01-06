shader_type spatial;

uniform sampler2D mask_texture : source_color;
uniform vec4 albedo_a : source_color = vec4(1.0f);
uniform sampler2D texture_a : source_color;
// From: https://godotshaders.com/shader/texture-blend/
uniform vec4 albedo_b : source_color = vec4(1.0f);
uniform sampler2D texture_b : source_color;
uniform float threshold : hint_range(0.0, 1.0, 0.01);

void fragment() {
	vec3 mask = texture(mask_texture, UV).rgb;
	vec3 a = albedo_a.rgb * texture(texture_a, UV).rgb;
	vec3 b = albedo_b.rgb * texture(texture_b, UV).rgb;
	vec3 color = mix(a, b, mask);
	ALBEDO = color;
    
    vec3 mask_data = texture(mask_texture, UV).rgb;
    ALPHA = step(mask_data, vec3(threshold)).x * mask_data.x;
    ALBEDO = mask_data;
}