shader_type spatial;
render_mode unshaded;

uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_linear_mipmap;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec3 normal = texture(NORMAL_TEXTURE, SCREEN_UV).rgb;
	ALBEDO = normal;
}
