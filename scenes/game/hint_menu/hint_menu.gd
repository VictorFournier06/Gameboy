extends CanvasLayer

const SIZE: float = 24.0

@export var animation_time: float = 0.2
@export var wait_time: float = 2.0
@export var drawn_palette: ColorPalette

var tween: Tween
var currently_colored_icon: Texture2D

@onready var icon: Sprite2D = $Icon
@onready var background: Sprite2D = $Background
@onready var drawn_background_texture: Texture2D = background.texture

func play(input_icon: Texture2D, palette: ColorPalette) -> void:
	currently_colored_icon = input_icon
	background.texture = _recolor(drawn_background_texture, palette)
	icon.texture = _recolor(input_icon, palette)

	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "offset:x", SIZE, animation_time)
	tween.tween_interval(wait_time)
	tween.tween_property(self, "offset:x", 0.0, animation_time)

func _recolor(texture_to_recolor: Texture2D, palette: ColorPalette) -> Texture2D:
	var image: Image = texture_to_recolor.get_image()
	for x in image.get_width():
		for y in image.get_height():
			var old_palette_index: int = drawn_palette.colors.find(image.get_pixel(x, y))
			if old_palette_index != -1:
				image.set_pixel(x, y, palette.colors[old_palette_index])
	return ImageTexture.create_from_image(image)

func reset_palette() -> void:
	background.texture = drawn_background_texture
	if currently_colored_icon:
		icon.texture = currently_colored_icon
