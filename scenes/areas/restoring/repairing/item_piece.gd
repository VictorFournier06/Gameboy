class_name ItemPiece
extends Node2D

var centroid: Vector2

@onready var fill_node: Sprite2D = $Fill
@onready var outline_node: Sprite2D = $Outline
@onready var highlighted_fill_node: Sprite2D = $HighlightedFill

func setup(piece: PieceData) -> void:
	fill_node.texture = piece.fill
	outline_node.texture = piece.outline
	highlighted_fill_node.texture = piece.highlighted_fill
	highlighted_fill_node.hide()

	centroid = _compute_centroid(piece.fill)
	for node in [fill_node, outline_node, highlighted_fill_node]:
		node.centered = false
		node.offset = -centroid

func _compute_centroid(texture: Texture2D) -> Vector2:
	var image: Image = texture.get_image()
	var sum: Vector2 = Vector2.ZERO
	var pixel_nb: int = 0
	for x in image.get_width():
		for y in image.get_height():
			if image.get_pixel(x, y).a > 0.0:
				sum += Vector2(x, y)
				pixel_nb += 1
	return sum / pixel_nb
