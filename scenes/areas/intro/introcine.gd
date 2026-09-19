extends AnimatedSprite2D

@export var animation_1_duration: float = 6.0
@export var music: AudioStream

var reached_start_screen: bool = false

func _ready():
	MusicPlayer.music_transition(music)
	play("default")
	# Wait X seconds
	await get_tree().create_timer(animation_1_duration).timeout
	play("water")
	await animation_finished
	reached_start_screen = true
	play("titleloop")

func _unhandled_input(event: InputEvent) -> void:
	if not reached_start_screen:
		return
	if event.is_action_pressed("a"):
		AreaManager.switch_area(AreaManager.Area.HUB)
