extends Control

@export var music: AudioStream

func _ready() -> void:
	MusicPlayer.music_transition(music)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("a"):
		AreaManager.switch_area(AreaManager.Area.HUB)
