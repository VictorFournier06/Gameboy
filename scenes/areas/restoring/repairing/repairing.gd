class_name Repairing
extends Node2D

signal finished_restoring

var user_interactions_allowed: bool

@onready var pieces: Array = $BrokenItem.get_children()

func setup(item: Item) -> void:
	for i in pieces.size():
		pieces[i].setup(item.type.broken_pieces[i])

func complete() -> void:
	pass

func skip() -> void:
	pass
