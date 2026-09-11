extends Node

enum Area { FISHING, HUB, LOCATING_OWNERS, RESTORING, SHOP }

const AREA_MAPPING := {
	Area.FISHING : "res://scenes/areas/fishing.tscn",
	Area.HUB : "res://scenes/areas/hub.tscn",
	Area.LOCATING_OWNERS : "res://scenes/areas/locating_owners.tscn",
	Area.RESTORING : "res://scenes/areas/restoring.tscn",
	Area.SHOP : "res://scenes/areas/shop.tscn",
}

func switch_area(area: Area) -> void:
	get_tree().change_scene_to_file(AREA_MAPPING[area])
