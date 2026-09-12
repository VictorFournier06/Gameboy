extends Node

enum Area { FISHING, HUB, LOCATING_OWNERS, RESTORING, SHOP }

const AREA_MAPPING := {
	Area.FISHING : "res://scenes/areas/fishing.tscn",
	Area.HUB : "res://scenes/areas/hub.tscn",
	Area.LOCATING_OWNERS : "res://scenes/areas/locating_owners.tscn",
	Area.RESTORING : "res://scenes/areas/restoring.tscn",
	Area.SHOP : "res://scenes/areas/shop.tscn",
}

var origin_area: Area = Area.FISHING
var current_area: Area = Area.HUB

func switch_area(new_area: Area) -> void:
	get_tree().change_scene_to_file(AREA_MAPPING[new_area])
	origin_area = current_area
	current_area = new_area

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("start") and current_area != Area.HUB:
		switch_area(Area.HUB)
