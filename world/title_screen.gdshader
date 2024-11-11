shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec3 other_color : source_color;
uniform vec3 alt_color : source_color;

//function easeOutSine(x: number): number {
  //return Math.sin((x * Math.PI) / 2);
//
//}

float ease_out(float x) {
	return 1. - pow(1. - x, 4.);
}

void fragment() {
	COLOR = textureLod(screen_texture, SCREEN_UV, 0.);

	float t = mod(TIME, 2.);
	float uv = UV.y;

	if (t < 1.) {
		t = ease_out(t);
		if (uv < t) {
			COLOR.rgb *= other_color;
		} else {
			COLOR.rgb *= alt_color;
		}
	} else {
		t = ease_out(t - 1.);
		if (uv < t) {
			COLOR.rgb *= alt_color;
		} else {
			COLOR.rgb *= other_color;
		}
	}
}
