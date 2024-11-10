shader_type canvas_item;
render_mode blend_add;

uniform vec3 base_color : source_color;
uniform sampler2D noise;
uniform float decay : hint_range(0., .6);

vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat) {
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoom, angle * repeat), 1.0);
}

void fragment() {
	vec2 uv = polar_coordinates(UV, vec2(0.5), 1., 1.);
	float l = length(UV - vec2(0.5));

	float t = texture(noise, vec2(uv.y)).x;
	COLOR.rgba = vec4(t - mix(0., 1.4, l));
	COLOR.rgb = mix(base_color * 2.5, vec3(-0.2), 1. - t);
	COLOR.a *= 5.;

	//COLOR.a *= step(l, 0.5);
	COLOR.a *= smoothstep(decay, decay + 0.005, l);
}