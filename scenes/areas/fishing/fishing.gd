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

@export var dirty_catch_phrase: DialogData #pun intended
@export var broken_catch_phrase: DialogData
@export var empty_sea_dialog: DialogData
@export var start_icon: Texture2D
@export var move_icon: Texture2D
@export var a_press_icon: Texture2D
@export var palette: ColorPalette

var target_position: Vector2
var bounds: Rect2
var y_gauge_bottom: float
var echo_alive_since: float = 0.0

var sweep_progress: float = 0.0 #in [0,1]
var imprinted_echo: bool = false

var items_fished: int = 0 #since in the scene

@onready var player: Node2D = $Player
@onready var rising_bar: Sprite2D = $Gauge/RisingBar
@onready var echo_bar: Sprite2D = $Gauge/EchoBar
@onready var sfx_player: SFXPlayer = $SFXPlayer
@onready var dialog_component: DialogComponent = $DialogComponent
@onready var gauge: Node2D = $Gauge

func _ready() -> void:
	var diagonal: Vector2 = Vector2(max_spawn_distance, max_spawn_distance)
	bounds = Rect2(
		-diagonal,
		2.0 * diagonal
	)
	y_gauge_bottom = rising_bar.position.y
	_spawn_target()
	if not Inventory._item_pool.is_empty():
		HintMenu.play(move_icon, palette)

	Debug.skip_minigame.connect(_obtain_item)

func _spawn_target() -> void:
	if Inventory._item_pool.is_empty():
		_disable_fishing()
	else:
		set_process(true)
		set_physics_process(true)
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

	var target_distance: float = player.position.distance_to(target_position)
	if target_distance <= catch_distance:
		HintMenu.play(a_press_icon, palette)

	var echo_height: float = _convert_distance_to_gauge_height(target_distance)
	if not imprinted_echo and rising_bar_height >= echo_height:
		imprinted_echo = true
		echo_bar.position.y = y_gauge_bottom - echo_height
		echo_bar.show()
		echo_alive_since = 0.0

func _convert_distance_to_gauge_height(distance: float) -> float:
	return clampf((1.0 - distance / max_spawn_distance) * GAUGE_HEIGHT, 0.0, GAUGE_HEIGHT)

func _catch_attempt() -> void:
	if player.position.distance_to(target_position) <= catch_distance:
		_obtain_item() #spawn new item after the dialog
	else:
		sfx_player.play_sfx(miss_sfx)
		HintMenu.play(move_icon, palette)

func _obtain_item() -> void:
	if not is_processing():
		return
	set_process(false)
	set_physics_process(false)
	sfx_player.play_sfx(treasure_sfx)
	var item_obtained: Item = Inventory.get_random_item_from_pool()

	if not Inventory.broken_pieces.has(item_obtained.type):
		items_fished += 1

	var item_dialog: DialogData
	if item_obtained.deterioration == Item.Deterioration.DIRTY:
		item_dialog = dirty_catch_phrase
	else:
		item_dialog = broken_catch_phrase

	var output_dialog: DialogData = DialogData.new()
	for line in item_dialog.lines:
		output_dialog.lines.append(line.format({
			"item": item_obtained.type.diplay_name,
			"count": Inventory.broken_pieces.get(
				item_obtained.type,
				item_obtained.type.broken_pieces.size()
			),
			"total": item_obtained.type.broken_pieces.size()
		}))
	dialog_component.dialog_finished.connect(_spawn_target, CONNECT_ONE_SHOT)
	if items_fished == 3:
		dialog_component.dialog_finished.connect(
			HintMenu.play.bind(start_icon, palette),
			CONNECT_ONE_SHOT
		)
	dialog_component.play_dialog(output_dialog, palette)

func _disable_fishing() -> void:
	set_process(false)
	set_physics_process(false)
	gauge.hide()

	dialog_component.dialog_finished.connect(HintMenu.play.bind(start_icon, palette), CONNECT_ONE_SHOT)
	dialog_component.play_dialog(empty_sea_dialog, palette)

func _unhandled_input(event: InputEvent) -> void:
	if is_processing() and event.is_action_pressed("a"):
		_catch_attempt()
