shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_alpha_prepass;

uniform float Size;
uniform float EventHorizonAmount;
uniform float GravityForce = 0.0;

vec2 hit_sphere(vec3 ray_origin, vec3 ray_direction, vec3 center, float radius){
    vec3 oc = ray_origin - center;
    float a = dot(ray_direction, ray_direction);
    float b = 2.0 * dot(oc, ray_direction);
    float c = dot(oc,oc) - radius*radius;
    float discriminant = b*b - 4.*a*c;
    if(discriminant < 0.){
        return vec2(-1.0);
    }
    else{
        return vec2((-b - sqrt(discriminant)) / (2.0*a), (-b + sqrt(discriminant)) / (2.0*a));
    }
}

void fragment() {
	// get camera position
	vec3 camera_pos = (CAMERA_MATRIX * vec4(0.0, 0.0, 0.0, 1.0f)).xyz;
	
	// Calculate the direction using the camera projection matrix and the UV coordinates
	// Without taking the UV coordinates into account, this would be an orthogonal camera
	vec3 direction = normalize((CAMERA_MATRIX * vec4(VIEW, 0.0)).xyz);

	vec3 hole_center = (WORLD_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	
	float depth_tex = textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).r;
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_tex * 2.0 - 1.0, 1.0);
	vec3 pixel_position = upos.xyz / upos.w;
	float depth = -pixel_position.z;
	
	vec2 event_horizon = hit_sphere(camera_pos, direction, hole_center, Size);
	
	float len = event_horizon.y - event_horizon.x;
	float fresnel = dot(VIEW, NORMAL);
	
	if (fresnel > .95) {
		ALBEDO = vec3(0.0);
	} else {
		vec4 screen_hole_view_pos = (PROJECTION_MATRIX * INV_CAMERA_MATRIX * vec4(hole_center, 1.0));
		vec3 screen_hole_clip_pos = screen_hole_view_pos.xyz / screen_hole_view_pos.w / 2.0 + .5;
		
		
		vec2 warp_direction = -normalize(screen_hole_clip_pos.xy - SCREEN_UV);
		float gravity_pull_force = clamp(exp(-fresnel * GravityForce), 0.0, 1.0);
		ALBEDO = texture(SCREEN_TEXTURE, SCREEN_UV + pow(fresnel, 10) * warp_direction * (gravity_pull_force - 1.0)).xyz;
	}
}