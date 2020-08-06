shader_type spatial;
render_mode depth_draw_alpha_prepass, depth_draw_always;

uniform vec4 DepthGradientShallow: hint_color = vec4(0.325, 0.807, 0.971, 0.725);
uniform vec4 DepthGradientDeep: hint_color = vec4(0.086, 0.407, 1, 0.749);
uniform float DepthMaxDistance: hint_range(0.05, 5.0) = 1.0;

uniform bool Flows = false;
uniform vec2 FlowDirection = vec2(0.0, 0.0);

uniform sampler2D wave_noise;
uniform vec2 WaveScale = vec2(1.0, 1.0);
// noise
uniform float SurfaceNoiseCutoff: hint_range(0.0, 1.0) = 1.0;
// foam
uniform bool FoamMovement = false;
uniform float FoamMovementAmount = 0.1;
uniform float FoamCutoff: hint_range(0.0, 1.0) = 1.0;
uniform float FoamSpeed: hint_range(0.0, 5.0) = 1.0;

float get_noise(vec2 p, float t) {
	p *= WaveScale;
	vec2 t_main = vec2(t / 2.0, t / 2.0);
	vec2 t_detail = vec2(-t, -t);
	if (Flows) {
		p += FlowDirection * t * 10.0;
		t_detail *= -1.0 * FlowDirection * 10.0;
	}
	float f = 0.0;
	f += 1.0 * texture(wave_noise, p + t_main).g; p=2.*p;
	f += 0.5 * texture(wave_noise, p + t_detail).g; p=2.*p;
	f += 0.25 * texture(wave_noise, p + t_detail).g; p=2.*p;
	f += 0.125 * texture(wave_noise, p + t_detail).g; p=2.*p;
	f += 0.0625 * texture(wave_noise, p + t_detail).g; p=2.*p;
	return clamp(f / 1.5, 0.0, 1.0);
}

void fragment() {
	float depth = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth * 2.0 - 1.0, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	
	float water_depth = clamp(distance(VERTEX, pixel_position), 0.0, 1.0);
	bool negative_depth = (VERTEX - pixel_position).z <= 0.0;
	
	if (negative_depth) {
		ALPHA = 0.0;
	} else {
		// water color base on depth
		float waterDepthDifference01 = water_depth > DepthMaxDistance ? 1.0 : water_depth / DepthMaxDistance;
		vec4 waterColor = mix(DepthGradientShallow, DepthGradientDeep, waterDepthDifference01);
		// surface noise
		float noise_value = get_noise(UV, TIME / 100.0);
		float surfaceNoise = noise_value < SurfaceNoiseCutoff ? 1.0 : 0.0;
		// foam
		float foamMovement = FoamMovement ? sin(TIME * FoamSpeed) * FoamMovementAmount : 0.0;
		float foamCutoff = FoamCutoff + foamMovement;
		float shoreline_foam = noise_value < foamCutoff / water_depth ? 1.0 : 0.0;

		ALBEDO = waterColor.rgb + clamp(surfaceNoise + shoreline_foam, 0.0, 1.0);
		ALPHA = waterColor.a;
		ROUGHNESS = 0.65;
	}
}