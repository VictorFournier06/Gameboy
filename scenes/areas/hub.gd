extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$FishPole.grab_focus()
	$FishPole.pressed.connect(_on_area_selected.bind(AreaManager.Area.FISHING))
	$Door.pressed.connect(_on_area_selected.bind(AreaManager.Area.LOCATING_OWNERS))
	$Workshop.pressed.connect(_on_area_selected.bind(AreaManager.Area.RESTORING))

func _on_area_selected(area: AreaManager.Area) -> void:
	AreaManager.switch_area(area)
