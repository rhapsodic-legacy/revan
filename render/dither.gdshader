// Post-process on the low-res 3D view: 4x4 ordered dither + colour quantisation.
shader_type canvas_item;

uniform float levels = 20.0;
uniform float strength = 1.0;
uniform float pixel = 3.0;

const float bayer[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	ivec2 p = ivec2(mod(floor(FRAGCOORD.xy / pixel), 4.0));
	float t = (bayer[p.y * 4 + p.x] / 16.0 - 0.5) * strength;
	c.rgb = floor(c.rgb * levels + t + 0.5) / levels;
	COLOR = vec4(c.rgb, 1.0);
}
