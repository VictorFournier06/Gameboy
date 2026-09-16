extends Node2D

@export var no_object_dialog: DialogData

@onready var restorable_object: RestorableObject = $RestorableObject
@onready var dialog_component: DialogComponent = $DialogComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restorable_object.no_item.connect(dialog_component.play_dialog.bind(no_object_dialog))
