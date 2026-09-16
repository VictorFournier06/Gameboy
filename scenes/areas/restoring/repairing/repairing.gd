class_name Repairing
extends Node2D

signal finished_restoring

enum Mode { SELECT, MOVE, ROTATE }

const ROTATION_NB = 24

@export var navigate_sfx: AudioStream
@export var enter_sfx: AudioStream
@export var sfx_player: SFXPlayer

var user_interactions_allowed: bool
var pieces_initial_positions: Array

var mode: Mode = Mode.SELECT
var selected_index: int = 0

@onready var pieces: Array = $BrokenItem.get_children()

func _ready() -> void:
	pieces_initial_positions = pieces.map(func(piece): return piece.position)

func setup(item: Item) -> void:
	var shuffled_positions: Array = pieces_initial_positions.duplicate()
	shuffled_positions.shuffle()

	for i in pieces.size():
		pieces[i].setup(item.type.broken_pieces[i])
		pieces[i].position = shuffled_positions[i]
		pieces[i].rotation = (2 * PI / ROTATION_NB) * randi_range(0, ROTATION_NB - 1)

	_update_selected(0)

func complete() -> void:
	pass

func skip() -> void:
	pass

func _update_selected(index: int):
	selected_index = index
	for i in pieces.size():
		pieces[i].highlight(mode == Mode.SELECT and i == selected_index)

func _unhandled_input(event: InputEvent) -> void:
	if not user_interactions_allowed or mode != Mode.SELECT:
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
	_set_mode(
		Mode.MOVE if mode == Mode.SELECT
		else (Mode.ROTATE if mode == Mode.MOVE
		else Mode.MOVE)
	)

func _set_mode(new_mode: Mode) -> void:
	mode = new_mode
	_update_selected(selected_index)
