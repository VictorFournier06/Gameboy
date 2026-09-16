extends Node2D

@export var no_object_dialog: DialogData

@export var shine_animation_duration = 2.0
@export var shine_color = Color("#f3edd1") #white from palette
@export var shine_width = 0.1
@export var finished_restoring_pause = 1.0

@export var finished_restoring_sfx: AudioStream
@export var shiney_sfx: AudioStream
@export var pocketing_sfx: AudioStream

var current_item: Item
var minigame_instance  #untyped, cleaning or repairing

@onready var dialog_component: DialogComponent = $DialogComponent
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var cleaning: Cleaning = $Cleaning
@onready var repairing: Repairing = $Repairing
@onready var instance_deterioration_matching: Dictionary = {
	Item.Deterioration.DIRTY: cleaning,
	Item.Deterioration.BROKEN: repairing
}

func _ready() -> void:
	cleaning.finished_restoring.connect(_finished_restoring)
	repairing.finished_restoring.connect(_finished_restoring)
	_reset.call_deferred()

	Debug.skip_minigame.connect(_skip_restoring)

func _reset() -> void:
	current_item = Inventory.get_first_restorable_item(
		[Item.Deterioration.DIRTY, Item.Deterioration.BROKEN]
	)
	if current_item == null:
		if minigame_instance:
			minigame_instance.hide()
		dialog_component.play_dialog(no_object_dialog)
		return

	minigame_instance = instance_deterioration_matching[current_item.deterioration]
	for type in instance_deterioration_matching.values():
		type.visible = type == minigame_instance
	minigame_instance.setup(current_item)
	minigame_instance.user_interactions_allowed = true

func _finished_restoring() -> void:
	minigame_instance.user_interactions_allowed = false
	current_item.deterioration = Item.Deterioration.NONE
	minigame_instance.complete()

	sfx_player.play_sfx(finished_restoring_sfx)
	await _shine_animation()
	sfx_player.play_sfx(pocketing_sfx)
	await sfx_player.finished
	_reset()

func _shine_animation() -> void:
	await get_tree().create_timer(finished_restoring_pause).timeout
	var instance_material: ShaderMaterial = minigame_instance.material
	instance_material.set_shader_parameter("shine_color", shine_color)
	instance_material.set_shader_parameter("shine_width", shine_width)

	var tween: Tween = create_tween()
	tween.tween_property(
		instance_material,
		"shader_parameter/shine_animation_progress",
		1.0,
		shine_animation_duration
	)
	sfx_player.play_sfx(shiney_sfx)
	await tween.finished

	instance_material.set_shader_parameter("shine_animation_progress", 0.0) #reset

func _skip_restoring() -> void:
	if minigame_instance:
		minigame_instance.skip()
