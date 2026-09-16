class_name ItemPiece
extends Node2D

@onready var fill_node: Sprite2D = $Fill
@onready var outline_node: Sprite2D = $Outline
@onready var highlighted_fill_node: Sprite2D = $HighlightedFill

func setup(piece: PieceData) -> void:
	fill_node.texture = piece.fill
	outline_node.texture = piece.outline
	highlighted_fill_node.texture = piece.highlighted_fill
	highlighted_fill_node.hide()
