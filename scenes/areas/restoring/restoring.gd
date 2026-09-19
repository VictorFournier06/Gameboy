extends Node2D

@export var no_object_dialog: DialogData
@export var should_return_object_dialog: DialogData

@export var shine_animation_duration = 2.0
@export var shine_width = 0.1
@export var finished_restoring_pause = 1.0

@export var finished_restoring_sfx: AudioStream
@export var shiney_sfx: AudioStream
@export var pocketing_sfx: AudioStream

@export var palette: ColorPalette
@export var start_icon: Texture2D

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
	repairing.palette = palette
	cleaning.finished_restoring.connect(_finished_restoring)
	repairing.finished_restoring.connect(_finished_restoring)
	_reset.call_deferred()

	Debug.skip_minigame.connect(_skip_restoring)

func _reset() -> void:
	# prioritize broken when it is there
	current_item = Inventory.get_first_restorable_item(Item.Deterioration.BROKEN)
	if current_item == null:
		current_item = Inventory.get_first_restorable_item(Item.Deterioration.DIRTY)
	if current_item == null:
		if minigame_instance:
			minigame_instance.hide()

		var in_possesion_of_restored_item: bool = false
		for item in Inventory.items:
			if item.deterioration == Item.Deterioration.NONE:
				in_possesion_of_restored_item = true
				break

		var dialog: DialogData
		if in_possesion_of_restored_item:
			dialog = should_return_object_dialog
		else:
			dialog = no_object_dialog

		dialog_component.dialog_finished.connect(
			HintMenu.play.bind(start_icon, palette),
			CONNECT_ONE_SHOT
		)
		dialog_component.play_dialog(dialog, palette)
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
	var instance_material: ShaderMaterial = minigame_instance.image_to_make_shine().material
	instance_material.set_shader_parameter("shine_color", palette.colors[0])
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
