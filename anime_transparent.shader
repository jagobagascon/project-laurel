shader_type spatial;

uniform sampler2D color_texture : hint_albedo;

uniform sampler2D normal_map : hint_normal;
uniform float normals_strength : hint_range(0.0, 10.0) = 0f;

uniform sampler2D specular_map : hint_albedo;

uniform vec4 ambient_light : hint_color = vec4(.5, .5, .5, 1.0);
uniform float glossiness : hint_range(0, 1000) = 500f;
uniform float specular_multiplier : hint_range(0f, 10f) = 5f;
uniform float specular_color_source : hint_range(0f, 1f) = 0f;
uniform float rim_amount : hint_range(0f, 1f) = 0.716f;
uniform float rim_threshold : hint_range(0f, 1f) = 0.1f;
uniform vec4 rim_color : hint_color = vec4(1, 1, 1, .1);

void fragment() {
	vec4 frag_color = texture(color_texture, UV);
	ALBEDO = frag_color.rgb;
	ALPHA = frag_color.a;
	
	vec4 normals = texture(normal_map, UV.xy);
	// only apply normals if set
	if (length(normals.rgb) < 1f) {
		NORMALMAP = normals.rgb;
		NORMALMAP_DEPTH = normals_strength;
	}
}

void light() {
	vec3 white_color = vec3(1);
	vec3 normalized_light_color = min(LIGHT_COLOR, white_color);
	float lightDot = dot(NORMAL, LIGHT);
	float lightIntensity = smoothstep(0, 0.05, lightDot * ATTENUATION.r);
	DIFFUSE_LIGHT += normalized_light_color * lightIntensity * ALBEDO;
	
	// rim
	float rimDot = 1f - dot(NORMAL, VIEW);
	float rimIntensity = rimDot * pow(lightDot, rim_threshold);
	rimIntensity = smoothstep(rim_amount - 0.01, rim_amount + 0.01, rimIntensity * ATTENUATION.r);
	vec3 rim = rimIntensity * rim_color.rgb * rim_color.a;
	DIFFUSE_LIGHT += rim;
	
	// Add at least ambient_light light
	DIFFUSE_LIGHT = max(DIFFUSE_LIGHT, ambient_light.rgb * ALBEDO);
	
	// vector entre la vista y la luz
	vec4 specular_strength = texture(specular_map, UV);
	float gloss_map = length(specular_strength.rgb);
	vec3 half_vector = normalize(VIEW + LIGHT);
	float viewDot = dot(NORMAL, half_vector);
	float specularIntensity = pow(viewDot * lightIntensity, glossiness) * gloss_map;
	float specularIntensitySharp = smoothstep(0.05, 0.07, specularIntensity * ATTENUATION.r);
	vec3 base_color = ALBEDO * (1f - specular_color_source) + white_color * specular_color_source;
	SPECULAR_LIGHT += normalized_light_color * base_color * specularIntensitySharp * specular_multiplier;
}
