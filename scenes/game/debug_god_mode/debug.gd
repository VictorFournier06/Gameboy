extends Node

signal skip_minigame

var debug_mode: bool = OS.is_debug_build()

func _unhandled_input(event: InputEvent) -> void:
	if debug_mode and event is InputEventKey and event.pressed and event.keycode == KEY_F:
		skip_minigame.emit()
