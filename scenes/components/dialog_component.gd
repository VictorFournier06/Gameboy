class_name DialogComponent
extends Control

@export var text_speed: float = 0.04
@export var dialog_sfx: AudioStream
@export var char_per_sfx: int = 3

#those depend on the palette
@export var black_color: Color
@export var white_color: Color

var current_line_nb: int
var reveal_tween: Tween
var dialog: DialogData

var char_nb_before_last_sfx: int = 0

@onready var label: RichTextLabel = $RichTextLabel
@onready var sfx_player: SFXPlayer = $SFXPlayer
@onready var dialog_box: Sprite2D = $DialogBox

func _ready() -> void:
	label.add_theme_color_override("default_color", black_color)
	dialog_box.material.set_shader_parameter("black_color", black_color)
	dialog_box.material.set_shader_parameter("white_color", white_color)

func play_dialog(input_dialog: DialogData) -> void:
	dialog = input_dialog
	current_line_nb = 0
	show_line()

func show_line() -> void:
	if current_line_nb >= dialog.lines.size():
		return

	label.text = dialog.lines[current_line_nb]
	label.visible_ratio = 0.0

	reveal_tween = create_tween()
	reveal_tween.tween_property(
		label,
		"visible_ratio",
		1.0,
		label.get_total_character_count() * text_speed
	)

	char_nb_before_last_sfx = 0

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return

	if reveal_tween and reveal_tween.is_running(): #reveal instant
		reveal_tween.kill()
		label.visible_ratio = 1.0
	else:
		current_line_nb += 1
		show_line()

func _process(_delta: float) -> void:
	if reveal_tween and reveal_tween.is_running():
		var char_nb: int = label.visible_characters
		if char_nb - char_nb_before_last_sfx >= char_per_sfx:
			char_nb_before_last_sfx = char_nb
			sfx_player.play_sfx(dialog_sfx, -8.0)
