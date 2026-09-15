extends Node2D

@export var dialog: DialogData

@onready var background: Sprite2D = $Background
@onready var character: Sprite2D = $Character
@onready var dialog_component: DialogComponent = $DialogComponent

func _ready() -> void:
	background.texture = dialog.background
	character.texture = dialog.character
	dialog_component.play_dialog(dialog)
