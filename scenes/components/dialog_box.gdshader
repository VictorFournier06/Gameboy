shader_type canvas_item;

uniform vec4 black_color: source_color;
uniform vec4 white_color: source_color;

// Called for every pixel the material is visible on.
void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	COLOR = (current_color.r < 0.5) ? black_color : white_color; //don't try at home
	COLOR.a = current_color.a;
}
