extends Node2D

const GAUGE_HEIGHT: float = 63

@export var max_spawn_distance: float
@export var min_spawn_distance: float
@export var catch_distance: float

@export var player_speed: float
@export var sweep_timer: float
@export var echo_duration: float

@export var treasure_sfx: AudioStream
@export var miss_sfx: AudioStream

var target_position: Vector2
var bounds: Rect2
var y_gauge_bottom: float
var echo_alive_since: float = 0.0

var sweep_progress: float = 0.0 #in [0,1]
var imprinted_echo: bool = false

@onready var player: Node2D = $Player
@onready var rising_bar: Sprite2D = $Gauge/RisingBar
@onready var echo_bar: Sprite2D = $Gauge/EchoBar
@onready var sfx_player: SFXPlayer = $SFXPlayer

func _ready() -> void:
	var diagonal: Vector2 = Vector2(max_spawn_distance, max_spawn_distance)
	bounds = Rect2(
		-diagonal,
		2.0 * diagonal
	)
	y_gauge_bottom = rising_bar.position.y
	_spawn_target()

func _spawn_target() -> void:
	player.position = Vector2.ZERO
	var distance: float = randf_range(min_spawn_distance, max_spawn_distance)
	var angle: float = randf() * 2 * PI
	target_position = distance * Vector2.from_angle(angle)

func _physics_process(_delta: float) -> void:
	Player.move(player, player_speed, bounds)

func _process(delta: float) -> void:
	sweep_progress += delta / sweep_timer
	echo_alive_since += delta

	if sweep_progress >= 1.0:
		sweep_progress -= 1.0
		imprinted_echo = false

	if echo_alive_since >= echo_duration:
		echo_bar.hide()

	var rising_bar_height: float = sweep_progress * GAUGE_HEIGHT
	rising_bar.position.y = y_gauge_bottom - rising_bar_height

	var target_distance = player.position.distance_to(target_position)
	var echo_height: float = _convert_distance_to_gauge_height(target_distance)
	if not imprinted_echo and rising_bar_height >= echo_height:
		imprinted_echo = true
		echo_bar.position.y = y_gauge_bottom - echo_height
		echo_bar.show()
		echo_alive_since = 0.0

	if Input.is_action_just_pressed("a"):
		_catch_attempt()

func _convert_distance_to_gauge_height(distance: float) -> float:
	return clampf((1.0 - distance / max_spawn_distance) * GAUGE_HEIGHT, 0.0, GAUGE_HEIGHT)

func _catch_attempt() -> void:
	if player.position.distance_to(target_position) <= catch_distance:
		sfx_player.play_sfx(treasure_sfx)
		_spawn_target()
	else:
		sfx_player.play_sfx(miss_sfx)
