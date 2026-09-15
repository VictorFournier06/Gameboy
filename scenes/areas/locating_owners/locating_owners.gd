extends Node2D

@export var dialog: DialogData
@export var text_speed := 0.04

var current_line_nb := 0
var reveal_tween: Tween

@onready var label: RichTextLabel = $RichTextLabel

func _ready() -> void:
	show_line()

func show_line() -> void:
	if current_line_nb >= dialog.lines.size():
		return

	label.text = dialog.lines[current_line_nb]
	label.visible_ratio = 0.0

	var count: int = label.get_total_character_count()

	reveal_tween = create_tween()
	reveal_tween.tween_property(label, "visible_ratio", 1.0, count * text_speed)

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_accept"):
		return

	if reveal_tween and reveal_tween.is_running(): #reveal instant
		reveal_tween.kill()
		label.visible_ratio = 1.0
	else:
		current_line_nb += 1
		show_line()
