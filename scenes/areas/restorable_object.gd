class_name RestorableObject
extends Sprite2D

const CLEAN_THRESHOLD: float = 0.95

var grid_size: Vector2i
var grid_image: Image #just there to update the ImageTexture
#r channel: the square cleanness of 0->1s that gets cleaned
#used as a mask to determine if dirty or clean is displayed
#g channel: the random thresholds for the ditherness
#b channel: mask, 0 if item alpha = 0
var cleaning_grid: ImageTexture
var cleanness_sum: float

var current_item: Item
var current_item_surface: int

func _ready() -> void:
	_reset()

func _reset() -> void:
	_switch_item()
	if current_item == null:
		return
	_build_grid()

func _build_grid() -> void:
	grid_size = texture.get_size()
	#recreate a new one each reset in case the item has a different size
	grid_image = Image.create_empty(grid_size.x, grid_size.y, false, Image.FORMAT_RGBA8)

	var current_item_image = texture.get_image()
	var surface_sum: int = 0 #counts the number of pixels of the mask

	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var opaque_pixel: bool = current_item_image.get_pixel(x, y).a > 0
			#random threshold on g channel -> scrubbing reshuffles the dirt
			grid_image.set_pixel(x, y, Color(0.0, randf(), 1.0 if opaque_pixel else 0.0, 1.0))
			if opaque_pixel:
				surface_sum += 1

	cleaning_grid = ImageTexture.create_from_image(grid_image)
	cleanness_sum = 0.0
	material.set_shader_parameter("grid_texture", cleaning_grid)

	current_item_surface = surface_sum

func _switch_item() -> void:
	current_item = Inventory.get_first_restorable_item(Item.Deterioration.DIRTY)
	if current_item == null:
		texture = null
		return
	texture = current_item.type.dirty_texture
	material.set_shader_parameter("clean_texture", current_item.type.clean_texture)

## returns true if there is an object being scrubbed
func scrub_at(world_position: Vector2, scrub_kernel: Array) -> bool:
	var has_something_been_scrubbed: bool = false

	if current_item == null:
		return has_something_been_scrubbed

	var local_position: Vector2i = Vector2i(to_local(world_position))

	var scrub_size: Vector2i = Vector2i(scrub_kernel[0].size(), scrub_kernel.size())
	var scrub_top_left: Vector2i = local_position - scrub_size / 2

	var scrub_rect: Rect2i = Rect2i(scrub_top_left, scrub_size)
	var grid_rect: Rect2i = Rect2i(0, 0, grid_size.x, grid_size.y)
	var overlap: Rect2i = grid_rect.intersection(scrub_rect)

	for x in range(overlap.position.x, overlap.end.x):
		for y in range(overlap.position.y, overlap.end.y):
			var pixel: Color = grid_image.get_pixel(x, y)
			var old_cleanness: float = pixel.r
			var scrubbed_amount: float = scrub_kernel[y - scrub_top_left.y][x - scrub_top_left.x]
			var new_cleanness: float = clampf(old_cleanness + scrubbed_amount, 0.0, 1.0)
			var new_color: Color = Color(new_cleanness, randf(), pixel.b)
			grid_image.set_pixel(x, y, new_color)

			var color_value_increase = new_cleanness - old_cleanness
			if pixel.b > 0.0 and color_value_increase > 0.0:
				has_something_been_scrubbed = true
				cleanness_sum += color_value_increase

	cleaning_grid.update(grid_image)
	_check_cleanness()

	return has_something_been_scrubbed

func _check_cleanness():
	if current_item_surface == 0:
		return
	var average_cleanness = cleanness_sum / current_item_surface
	if average_cleanness > CLEAN_THRESHOLD:
		current_item.deterioration = Item.Deterioration.NONE
		_reset()
