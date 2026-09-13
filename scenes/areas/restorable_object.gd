class_name RestorableObject
extends Sprite2D

const GRID_SIZE: int = 16
const CLEAN_THRESHOLD: float = 0.75

var grid_image: Image #just there to update the ImageTexture
var cleaning_grid: ImageTexture #the square mask of 0->1s that gets cleaned

var current_item: Item
var current_item_shape_mask: Image #based on alpha, GRID_SIZE
var current_item_surface: int

func _ready() -> void:
	grid_image = Image.create_empty(GRID_SIZE, GRID_SIZE, false, Image.FORMAT_RGBA8)
	cleaning_grid = ImageTexture.create_from_image(grid_image)
	material.set_shader_parameter("grid_texture", cleaning_grid)
	_reset()

func _reset() -> void:
	grid_image.fill(Color(0, 0, 0, 1))
	cleaning_grid.update(grid_image)

	current_item = Inventory.get_first_restorable_item(Item.Deterioration.DIRTY)
	if current_item == null:
		return
	texture = current_item.type.dirty_texture
	material.set_shader_parameter("clean_texture", current_item.type.clean_texture)
	_set_current_item_shape()

func _set_current_item_shape():
	current_item_shape_mask = Image.create_empty(GRID_SIZE, GRID_SIZE, false, Image.FORMAT_RGBA8)
	var current_item_image = texture.get_image()
	var surface_sum: int = 0 #counts the number of pixels of the mask

	for x in range(current_item_image.get_width()):
		for y in range(current_item_image.get_height()):
			var cell_position = to_cell_position(Vector2(x, y))
			if current_item_image.get_pixel(x, y).a > 0:
				current_item_shape_mask.set_pixel(cell_position.x, cell_position.y, Color.WHITE)
				surface_sum += 1
	current_item_surface = surface_sum

func to_cell_position(local_position: Vector2) -> Vector2i:
	var uv_position: Vector2 = local_position / texture.get_size()
	var cell_position = Vector2i(uv_position * GRID_SIZE)
	return cell_position

## returns true if there is an object being scrubbe
func scrub_at(world_position: Vector2, scrub_kernel: Array) -> bool:
	var has_something_been_scrubbed: bool = false

	if current_item == null:
		return has_something_been_scrubbed

	var local_position: Vector2 = to_local(world_position)
	var cell_position = to_cell_position(local_position)

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

			if current_item_shape_mask.get_pixel(x, y).r > 0.0 and new_color_value > current_color_value:
				has_something_been_scrubbed = true

	cleaning_grid.update(grid_image)

	if average(grid_image) > CLEAN_THRESHOLD:
		current_item.deterioration = Item.Deterioration.NONE
		_reset()

	return has_something_been_scrubbed

#average of the grid image masked by the current item
func average(grid_sized_image: Image) -> float:
	assert(grid_sized_image.get_size() == Vector2i(GRID_SIZE, GRID_SIZE))

	var cleanness_sum: float = 0.0
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			cleanness_sum += grid_sized_image.get_pixel(x, y).r * current_item_shape_mask.get_pixel(x, y).r
	if current_item_surface == 0:
		return 0.0
	return cleanness_sum / current_item_surface
