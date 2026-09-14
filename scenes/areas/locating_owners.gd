extends Node2D

@export var dialogue: DialogueData
@export var text_speed := 0.04

var current_line := 0
var typing := false

@onready var label: Label = $Label

func _ready():
	show_line()

func show_line():
	if current_line >= dialogue.lines.size():
		label.text = ""
		return

	label.text = ""
	typing = true

	var line = dialogue.lines[current_line]

	for character in line:
		if not typing:
			break

		label.text += character
		await get_tree().create_timer(text_speed).timeout

	typing = false


func _input(event):
	if event.is_action_pressed("ui_accept"):
		if typing:
			typing = false
			label.text = dialogue.lines[current_line]
		else:
			current_line += 1
			show_line()
