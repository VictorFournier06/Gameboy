class_name ItemPiece
extends Node2D

@export var fill: Texture2D
@export var outline: Texture2D
@export var highlighted_fill: Texture2D

@onready var fill_node: Sprite2D = $Fill
@onready var outline_node: Sprite2D = $Outline
@onready var highlighted_fill_node: Sprite2D = $HighlightedFill

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_node.texture = fill
	outline_node.texture = outline
	highlighted_fill_node.texture = highlighted_fill
	highlighted_fill_node.hide()
