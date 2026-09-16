shader_type canvas_item;

uniform sampler2D clean_texture;
uniform sampler2D grid_texture;
uniform float shine_animation_progress = 0.0;

//these two are set by restorable_object.gd
uniform vec4 shine_color: source_color;
uniform float shine_width;

// Called for every pixel the material is visible on.
void fragment() {
	vec4 dirty_pixel = texture(TEXTURE, UV);
	vec4 clean_pixel = texture(clean_texture, UV);
	float grid_pixel = texture(grid_texture, UV).r; //we sample red for the brightness of the mask
	float threshold = texture(grid_texture, UV).g; //we sample green for the threshold of the mask
	COLOR = (grid_pixel > threshold) ? clean_pixel : dirty_pixel;

	float d = UV.x + (1.0 - UV.y); //equation of the diagonal bottom left towards top right
	float fringe_center = shine_animation_progress * 2.0; //d is in [0,2]
	if (shine_animation_progress > 0.0 && abs(d - fringe_center) < shine_width && COLOR.a > 0.0) { //only shine opaque pixels
		COLOR.rgb = shine_color.rgb;
	}
}
