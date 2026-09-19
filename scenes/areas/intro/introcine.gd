extends AnimatedSprite2D

@export var animation_1_duration: float = 6.0
@export var music: AudioStream

var reached_start_screen: bool = false
var skipped: bool = false

func _ready():
	Debug.skip_minigame.connect(_skip_intro)

	MusicPlayer.music_transition(music)
	play("default")
	# Wait X seconds
	await get_tree().create_timer(animation_1_duration).timeout
	if skipped:
		return
	play("water")
	await animation_finished
	reached_start_screen = true
	if skipped:
		return
	play("titleloop")

func _skip_intro() -> void:
	skipped = true
	reached_start_screen = true
	play("titleloop")

func _unhandled_input(event: InputEvent) -> void:
	if not reached_start_screen:
		return
	if event.is_action_pressed("a"):
		AreaManager.switch_area(AreaManager.Area.HUB)
