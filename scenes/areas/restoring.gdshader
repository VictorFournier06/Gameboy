shader_type canvas_item;

uniform sampler2D clean_texture;
uniform sampler2D grid_texture : filter_linear;
uniform float cutoff = 0.5;

// Called for every pixel the material is visible on.
void fragment() {
	vec4 dirty_pixel = texture(TEXTURE, UV);
	vec4 clean_pixel = texture(clean_texture, UV);
	float grid_pixel_red = texture(grid_texture, UV).r; //we sample red for the brightness of the mask
	COLOR = (grid_pixel_red > cutoff) ? clean_pixel : dirty_pixel;
}
