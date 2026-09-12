extends Sprite2D

var grid_size = 16

func _ready() -> void:
	var image: Image = Image.create_empty(grid_size, grid_size, false, Image.FORMAT_RGBA8)
	var cleaning_grid: ImageTexture = ImageTexture.create_from_image(image)
	material.set_shader_parameter("grid_texture", cleaning_grid)
