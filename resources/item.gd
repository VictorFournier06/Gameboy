class_name Item
extends Resource

enum Artefact { OLD_GOLD, AMPHORA, MUSIC_BOX, LOST_KEY, MOSSY_CASKET }

@export var artefact: Artefact = Artefact.OLD_GOLD

@export var dirty: bool = false:
	set(value):
		dirty = value
		emit_changed()

@export var broken: bool = false:
	set(value):
		broken = value
		emit_changed()

var restored: bool:
	get:
		return not broken and not dirty
