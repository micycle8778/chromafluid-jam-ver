shader_type canvas_item;

uniform float progress : hint_range(-1., 1.);

void fragment() {
	COLOR.a = step(-progress, 1. - UV.y);
	COLOR.a *= step(progress, UV.y);
}
