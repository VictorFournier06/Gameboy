shader_type canvas_item;

uniform float shine_animation_progress = 0.0;

//these two are set by restorable_object.gd
uniform vec4 shine_color: source_color;
uniform float shine_width;

// Called for every pixel the material is visible on.
void fragment() {
	COLOR = texture(TEXTURE, UV);
	float d = UV.x + (1.0 - UV.y); //equation of the diagonal bottom left towards top right
	float fringe_center = shine_animation_progress * 2.0; //d is in [0,2]
	if (shine_animation_progress > 0.0 && abs(d - fringe_center) < shine_width && COLOR.a > 0.0) { //only shine opaque pixels
		COLOR.rgb = shine_color.rgb;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
