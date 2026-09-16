class_name Repairing
extends Node2D

signal finished_restoring

const ROTATION_NB = 24

var user_interactions_allowed: bool
var pieces_initial_positions: Array

@onready var pieces: Array = $BrokenItem.get_children()

func _ready() -> void:
	pieces_initial_positions = pieces.map(func(piece): return piece.position)

func setup(item: Item) -> void:
	var shuffled_positions: Array = pieces_initial_positions.duplicate()
	shuffled_positions.shuffle()

	for i in pieces.size():
		pieces[i].setup(item.type.broken_pieces[i])
		pieces[i].position = shuffled_positions[i]
		pieces[i].rotation = (2 * PI / ROTATION_NB) * randi_range(0, ROTATION_NB - 1)

func complete() -> void:
	pass

func skip() -> void:
	pass
