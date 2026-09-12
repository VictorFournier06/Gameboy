class_name Item
extends Resource

enum Deterioration { NONE, DIRTY, BROKEN }
enum Artefact { OLD_GOLD, AMPHORA, MUSIC_BOX, LOST_KEY, MOSSY_CASKET }

@export var artefact: Artefact = Artefact.OLD_GOLD

@export var deterioration: Deterioration:
	set(value):
		deterioration = value
		emit_changed()
