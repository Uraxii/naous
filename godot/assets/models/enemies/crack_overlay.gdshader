shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

uniform vec4 CrackColor : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Color of the cracks and their glow
uniform sampler2D CrackMask; // Texture mask to display on the model
uniform float crack_strength : hint_range(0.0, 1.0, 0.01) = 0.0; // Current strength of the crack blending
uniform float emission_strength : hint_range(1.0, 20, 0.1); // How strong the light emission is at full crack strength
uniform int crack_stages : hint_range(0, 20, 1) = 0; // How many times the cracks will intensify between 100% and 0% strength in steps
uniform float mask_noise_threshold : hint_range(0.0, 1.0, 0.01) = 0.0; // Minimum strength in the mask to register for being displayed as a cracked pixel
uniform bool invert_mask = false; // If the mask color data should be inverted

// Called for every pixel the material is visible on.
void fragment() {
    vec3 mask_data = texture(CrackMask, UV).rgb;
    float mask_strength = 1. - length(mask_data);
    float noise_threshold = 1. - mask_noise_threshold;
    if (invert_mask) {
        mask_strength = 1. - mask_strength;
        //noise_threshold = 1. - noise_threshold;
    }

    // Filters out any parts of the mask that don't meet the minimum strength threshold
    mask_strength = step(mask_strength, noise_threshold) * mask_strength;

    // How strong is this pixel for this stage
    float current_step = floor(crack_strength * float(crack_stages));
    float current_crack_strength = mask_strength * current_step;
    //current_crack_strength = current_crack_strength * step(current_crack_strength, 0.1);

    //float mask_crack_strength = step_strength * crack_strength;

    float blended_crack_strength = current_crack_strength * 1.;

    // ALPHA is used to filter out the noise and increase the relative strength of the cracks at each stage
    ALPHA = blended_crack_strength;

    // ALBEDO and EMISSION are simply tied to the associated crack color and the strength of the cracking
    vec3 blended_crack_color = CrackColor.rgb * blended_crack_strength;
	ALBEDO = blended_crack_color;
    EMISSION = blended_crack_color * emission_strength;
}
