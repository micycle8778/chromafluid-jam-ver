shader_type canvas_item;

void fragment() {
	float l = length(UV - vec2(0.5));
	COLOR.a = smoothstep(l, l + 0.08, 0.5);
}
