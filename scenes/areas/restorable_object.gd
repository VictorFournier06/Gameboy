class_name RestorableObject
extends Sprite2D

const GRID_SIZE: int = 16
const CLEAN_THRESHOLD: float = 0.75

var grid_image: Image
var cleaning_grid: ImageTexture
var current_item: Item

func _ready() -> void:
	grid_image = Image.create_empty(GRID_SIZE, GRID_SIZE, false, Image.FORMAT_RGBA8)
	cleaning_grid = ImageTexture.create_from_image(grid_image)
	material.set_shader_parameter("grid_texture", cleaning_grid)

	current_item = Inventory.get_first_restorable_item(Item.Deterioration.DIRTY)

func _reset() -> void:
	grid_image.fill(Color(0, 0, 0, 1))
	cleaning_grid.update(grid_image)

	current_item = Inventory.get_first_restorable_item(Item.Deterioration.DIRTY)

func scrub_at(world_position: Vector2, scrub_kernel: Array) -> void:
	if current_item == null:
		return

	var local_position: Vector2 = to_local(world_position)
	var uv_position: Vector2 = local_position / texture.get_size()
	var cell_position = Vector2i(uv_position * GRID_SIZE)

	var scrub_size: Vector2i = Vector2i(scrub_kernel[0].size(), scrub_kernel.size())
	var scrub_top_left: Vector2i = cell_position - scrub_size / 2

	var scrub_rect: Rect2i = Rect2i(scrub_top_left, scrub_size)
	var grid_rect: Rect2i = Rect2i(0, 0, GRID_SIZE, GRID_SIZE)
	var overlap: Rect2i = grid_rect.intersection(scrub_rect)

	for x in range(overlap.position.x, overlap.end.x):
		for y in range(overlap.position.y, overlap.end.y):
			var current_color_value: float = grid_image.get_pixel(x, y).r
			var scrubbed_amount: float = scrub_kernel[y - scrub_top_left.y][x - scrub_top_left.x]
			var new_color_value: float = clampf(current_color_value + scrubbed_amount, 0.0, 1.0)
			var new_color: Color = Color(new_color_value, new_color_value, new_color_value)
			grid_image.set_pixel(x, y, new_color)
	cleaning_grid.update(grid_image)

	if average(grid_image) > CLEAN_THRESHOLD:
		current_item.deterioration = Item.Deterioration.NONE
		_reset()

func average(image: Image) -> float:
	var image_width = image.get_width()
	var image_height = image.get_height()

	var sum: float = 0.0
	for x in range(image_width):
		for y in range(image_height):
			sum += image.get_pixel(x, y).r
	return sum / (image_width * image_height)
