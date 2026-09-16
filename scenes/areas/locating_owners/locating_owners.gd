extends Node2D

@export var owners: Array[OwnerData]

@onready var background: Sprite2D = $Background
@onready var character: Sprite2D = $Character
@onready var dialog_component: DialogComponent = $DialogComponent

func _ready() -> void:
	_display_owner(owners[2], 0)

func _display_owner(input_owner: OwnerData, dialog_nb: int) -> void:
	background.texture = input_owner.background
	character.texture = input_owner.character
	dialog_component.play_dialog(input_owner.dialogs[dialog_nb])
