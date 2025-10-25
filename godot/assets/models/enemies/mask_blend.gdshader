// From: https://godotshaders.com/shader/threshold-mask-blend/
shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform sampler2D Albedo;
uniform sampler2D BlendTexture;
uniform vec4 BlendColor : source_color = vec4(0.9, 0.0, 0.0, 1.0);
uniform sampler2D BlendMask;
uniform float blend : hint_range(0.0, 1.0, 0.10) = 0.0;
uniform float threshold : hint_range(0.0, 1.0, 0.01) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 _albedo = vec4(1.);

	vec4 _blend_texture = texture(BlendTexture, UV);

	vec3 _colored_blend_texture = vec3(_blend_texture.xyz) * vec3(BlendColor.xyz);

    vec4 mask_data = texture(BlendMask, UV);
    //vec4 mask_data = step(texture(BlendMask, UV), vec4(threshold));
	vec4 stencil_mask = step(1. - mask_data, vec4(blend));
	vec4 mixed_textures = mix(_albedo, vec4(_colored_blend_texture, 0.0), stencil_mask.x);

    ALPHA = step(mask_data.rgb, vec3(threshold)).x * mask_data.r;
	ALBEDO = vec3(mask_data.rgb);
    //ALPHA = 0.5;
    //ALBEDO = vec3(0., 0., 0.);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
