class_name Item
extends Resource

enum Deterioration { NONE, DIRTY, BROKEN }

@export var type: ItemType = preload("res://resources/items/old_gold.tres")

@export var deterioration: Deterioration:
	set(value):
		deterioration = value
		emit_changed()

func _init(
	item_type: ItemType = ItemCatalog.OLD_GOLD,
	item_deterioration: Deterioration = Deterioration.DIRTY
	) -> void:
	type = item_type
	deterioration = item_deterioration
