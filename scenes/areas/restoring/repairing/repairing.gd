class_name Repairing
extends Node2D

signal finished_restoring

enum Mode { SELECT, MOVE, ROTATE }

const ROTATION_NB: int = 24
const POSITION_TOLERANCE: int = 2 #in px
const ROTATION_TOLERANCE: float = 0.01

@export var navigate_sfx: AudioStream
@export var enter_sfx: AudioStream
@export var sfx_player: SFXPlayer

@export var speed: float = 0.25
@export var rotation_speed: float = 0.1 #seconds between each tick
@export var piece_hitbox: Vector2 = Vector2(16.0, 16.0)

var user_interactions_allowed: bool
var pieces_initial_positions: Array

var mode: Mode = Mode.SELECT
var selected_index: int = 0
var rotation_cooldown: float = 0.0

var finished_texture: Texture2D
var final_shift: Vector2

@onready var broken_item: Node2D = $BrokenItem
@onready var pieces: Array = $BrokenItem.get_children()
@onready var finished_image: Sprite2D = $FinishedImage
@onready var bounds: Rect2 = Rect2(piece_hitbox / 2.0, get_viewport_rect().size - piece_hitbox)

func _ready() -> void:
	pieces_initial_positions = pieces.map(func(piece): return piece.position)

func setup(item: Item) -> void:
	finished_image.hide()
	for piece in pieces:
		piece.show()

	finished_texture = item.type.clean_texture
	finished_image.texture = finished_texture

	var shuffled_positions: Array = pieces_initial_positions.duplicate()
	shuffled_positions.shuffle()

	for i in pieces.size():
		pieces[i].setup(item.type.broken_pieces[i])
		pieces[i].position = shuffled_positions[i]
		pieces[i].rotation = (2 * PI / ROTATION_NB) * randi_range(0, ROTATION_NB - 1)

	_update_selected(0)

func complete() -> void:
	for piece in pieces:
		piece.hide()
	finished_image.position = broken_item.position + final_shift
	finished_image.show()

func skip() -> void:
	if not user_interactions_allowed:
		return
	user_interactions_allowed = false
	var center := (get_viewport_rect().size - finished_texture.get_size()) / 2.0
	final_shift = center - broken_item.position
	finished_restoring.emit()

func image_to_make_shine() -> Node2D:
	return finished_image

func _update_selected(index: int):
	selected_index = index
	for i in pieces.size():
		pieces[i].highlight(mode == Mode.SELECT and i == selected_index)

func _unhandled_input(event: InputEvent) -> void:
	if not user_interactions_allowed:
		return
	if event.is_action_pressed("ui_accept"):
		_change_mode()
		sfx_player.play_sfx(enter_sfx)
	elif event.is_action_pressed("ui_cancel"):
		_set_mode(Mode.SELECT)
	elif mode == Mode.SELECT:
		_menu_navigate(event)

func _menu_navigate(event: InputEvent) -> void:
	var direction: Vector2 = Vector2.ZERO
	if event.is_action_pressed("up"): direction = Vector2.UP
	elif event.is_action_pressed("down"): direction = Vector2.DOWN
	elif event.is_action_pressed("right"): direction = Vector2.RIGHT
	elif event.is_action_pressed("left"): direction = Vector2.LEFT
	else:
		return
	var closest_piece_index: int = _closest_piece_in_direction(direction)
	if closest_piece_index != -1:
		_update_selected(closest_piece_index)
		sfx_player.play_sfx(navigate_sfx)

func _closest_piece_in_direction(direction: Vector2) -> int:
	var start: Vector2 = pieces[selected_index].position
	var distances: Array = pieces.map(func(piece):
		var vector: Vector2 = piece.position - start
		return vector.length() if vector.dot(direction) > 0.0 else INF
	)
	var min_distance: float = distances.min()
	var argmin: int = distances.find(min_distance) if min_distance < INF else -1
	return argmin

func _change_mode() -> void:
	match mode:
		Mode.SELECT: _set_mode(Mode.MOVE)
		Mode.MOVE: _set_mode(Mode.ROTATE)
		Mode.ROTATE: _set_mode(Mode.MOVE)

func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_update_selected(selected_index)

func _physics_process(delta: float) -> void:
	if not user_interactions_allowed:
		return
	if mode == Mode.MOVE:
		Player.move(pieces[selected_index], speed, bounds)
		_check_finished()
	elif mode == Mode.ROTATE:
		rotation_cooldown -= delta
		var clockwiseness: float = Input.get_axis("left", "right")
		if clockwiseness != 0.0 and rotation_cooldown <= 0.0:
			pieces[selected_index].rotation += clockwiseness * ( 2 * PI / ROTATION_NB)
			rotation_cooldown = rotation_speed
			_check_finished()
		elif clockwiseness == 0.0:
			rotation_cooldown = 0.0 #instant move

func _check_finished() -> void:
	var global_shift: Vector2 = pieces[0].position - pieces[0].centroid
	for piece in pieces:
		if (piece.position - piece.centroid).distance_to(global_shift) > POSITION_TOLERANCE:
			return
		if absf(wrapf(piece.rotation, -PI, PI)) > ROTATION_TOLERANCE:
			return
	final_shift = global_shift
	user_interactions_allowed = false
	finished_restoring.emit()
