extends Node2D

@export var dialog: DialogData
@export var text_speed: float = 0.04
@export var dialog_sfx: AudioStream
@export var char_per_sfx: int = 3
@export var enter_sfx: AudioStream

var current_line_nb: int = 0
var reveal_tween: Tween

var char_nb_before_last_sfx: int = 0

@onready var background: Sprite2D = $Background
@onready var character: Sprite2D = $Character
@onready var label: RichTextLabel = $RichTextLabel
@onready var sfx_player: SFXPlayer = $SFXPlayer

func _ready() -> void:
	background.texture=dialog.background
	character.texture=dialog.character
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
