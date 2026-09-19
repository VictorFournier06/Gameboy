class_name DialogComponent
extends Control

signal dialog_finished

@export var text_speed: float = 0.04
@export var dialog_sfx: AudioStream
@export var char_per_sfx: int = 3

var current_line_nb: int
var reveal_tween: Tween
var dialog: DialogData

var char_nb_before_last_sfx: int = 0

@onready var label: RichTextLabel = $RichTextLabel
@onready var sfx_player: SFXPlayer = $SFXPlayer
@onready var dialog_box: Sprite2D = $DialogBox
@onready var arrow: Sprite2D = $DialogBox/Arrow

func _ready() -> void:
	dialog_finished.connect(hide)
	arrow_bobbing()

func arrow_bobbing() -> void:
	var idle_y = arrow.position.y
	var bobbing_tween: Tween = create_tween().set_loops()
	bobbing_tween.tween_property(arrow, "position:y", idle_y + 2, 0.2)
	bobbing_tween.tween_property(arrow, "position:y", idle_y, 0.2)
	bobbing_tween.tween_interval(1.0)

func play_dialog(input_dialog: DialogData, palette: ColorPalette) -> void:
	label.add_theme_color_override("default_color", palette.colors[3])
	dialog_box.material.set_shader_parameter("black_color", palette.colors[3])
	dialog_box.material.set_shader_parameter("white_color", palette.colors[0])

	show()
	dialog = input_dialog
	current_line_nb = 0
	show_line()

func show_line() -> void:
	if current_line_nb >= dialog.lines.size():
		dialog_finished.emit()
		return

	arrow.hide()

	label.text = dialog.lines[current_line_nb]
	label.visible_ratio = 0.0

	reveal_tween = create_tween()
	reveal_tween.tween_property(
		label,
		"visible_ratio",
		1.0,
		label.get_total_character_count() * text_speed
	)
	reveal_tween.tween_callback(show_arrow)

	char_nb_before_last_sfx = 0

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event.is_action_pressed("ui_accept"):
		return

	if reveal_tween and reveal_tween.is_running(): #reveal instant
		reveal_tween.kill()
		label.visible_ratio = 1.0
		show_arrow()
	else:
		current_line_nb += 1
		show_line()
	get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	if reveal_tween and reveal_tween.is_running():
		var char_nb: int = label.visible_characters
		if char_nb - char_nb_before_last_sfx >= char_per_sfx:
			char_nb_before_last_sfx = char_nb
			sfx_player.play_sfx(dialog_sfx, -8.0)

func show_arrow():
	if current_line_nb < dialog.lines.size() - 1:
		arrow.show()
