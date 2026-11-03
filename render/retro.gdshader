// Placeholder retro surface: flat colour, Lambert light, vertex snapping (PS1 wobble).
// The final look gets real textures from the Tripo/Fal pipeline; the snap stays as a tunable.
shader_type spatial;
render_mode diffuse_lambert, specular_disabled;

uniform vec4 albedo : source_color = vec4(1.0);
uniform float emission = 0.0;
uniform float snap_res = 180.0;
uniform float alpha = 1.0;

void vertex() {
	vec4 clip = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec2 ndc = clip.xy / clip.w;
	ndc = floor(ndc * snap_res + 0.5) / snap_res;
	clip.xy = ndc * clip.w;
	POSITION = clip;
}

void fragment() {
	ALBEDO = albedo.rgb;
	EMISSION = albedo.rgb * emission;
	if (alpha < 0.99) {
		ALPHA = alpha;
	}
}
