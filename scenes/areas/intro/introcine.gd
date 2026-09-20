extends AnimatedSprite2D

@export var animation_1_duration: float = 6.0
@export var music: AudioStream
@export var gbjam_drop_duration: float = 2.0
@export var gbjam_idle_wait_time: float = 1.0
@export var gbjam_sfx: AudioStream

var reached_start_screen: bool = false
var skipped: bool = false

@onready var gbjam_background: Sprite2D = $"../GBJAMBackground"
@onready var gbjam_foreground: Sprite2D = $"../GBJAMForeground"
@onready var sfx_player: SFXPlayer = $"../SFXPlayer"

func _ready():
	Debug.skip_minigame.connect(_skip_intro)

	hide() #hide during gbjam splash art
	var tween: Tween = create_tween()
	tween.tween_property(gbjam_foreground, "position:y", 0.0, gbjam_drop_duration)
	await tween.finished
	if skipped:
		return
	sfx_player.play_sfx(gbjam_sfx)
	await sfx_player.finished
	if skipped:
		return
	await get_tree().create_timer(gbjam_idle_wait_time).timeout
	if skipped:
		return

	gbjam_background.hide()
	gbjam_foreground.hide()
	show()

	# start our intro
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
	gbjam_background.hide()
	gbjam_foreground.hide()
	show()
	if not MusicPlayer.playing:
		MusicPlayer.music_transition(music)
	play("titleloop")

func _unhandled_input(event: InputEvent) -> void:
	if not reached_start_screen:
		return
	if event.is_action_pressed("a"):
		AreaManager.switch_area(AreaManager.Area.HUB)
