class_name RestorableObject
extends Sprite2D

var grid_size = 16
var image: Image = Image.create_empty(grid_size, grid_size, false, Image.FORMAT_RGBA8)
var cleaning_grid: ImageTexture = ImageTexture.create_from_image(image)

func _ready() -> void:
	material.set_shader_parameter("grid_texture", cleaning_grid)

func scrub_at(world_position: Vector2, scrub_kernel: Array) -> void:
	var local_position: Vector2 = to_local(world_position)
	var uv_position: Vector2 = local_position / texture.get_size()
	var cell_postion = Vector2i(uv_position * grid_size)

	var scrub_size: Vector2i = Vector2i(scrub_kernel[0].size(), scrub_kernel.size())
	var scrub_top_left: Vector2i = cell_postion - scrub_size / 2

	var scrub_rect: Rect2i = Rect2i(scrub_top_left, scrub_size)
	var grid_rect: Rect2i = Rect2i(0, 0, grid_size, grid_size)
	var overlap: Rect2i = grid_rect.intersection(scrub_rect)

	for x in range(overlap.position.x, overlap.end.x):
		for y in range(overlap.position.y, overlap.end.y):
			var current_color_value: float = image.get_pixel(x, y).r
			var scrubbed_amount: float = scrub_kernel[y - scrub_top_left.y][x - scrub_top_left.x]
			var new_color_value: float = clampf(current_color_value + scrubbed_amount, 0.0, 1.0)
			var new_color: Color = Color(new_color_value, new_color_value, new_color_value)
			image.set_pixel(x, y, new_color)
	cleaning_grid.update(image)
