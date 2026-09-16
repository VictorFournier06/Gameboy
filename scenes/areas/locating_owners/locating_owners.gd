extends Node2D

@export var dialog: DialogData
@export var background: Sprite2D
@export var character: Sprite2D

@onready var dialog_component: DialogComponent = $DialogComponent

func _ready() -> void:
	dialog_component.play_dialog(dialog)
