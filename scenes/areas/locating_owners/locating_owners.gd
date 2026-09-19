extends Node2D

#HACK: keyed by resource_path
static var character_base_dialog_order_mapping: Dictionary[String, int] = {}

@export var owners: Array[OwnerData]
@export var palette: ColorPalette
@export var start_icon: Texture2D
@export var door_sfx: AudioStream

var _dialog_about_to_play: Array[DialogData] = [] #queue

@onready var background: Sprite2D = $Interior/Background
@onready var character: Sprite2D = $Interior/Character
@onready var dialog_component: DialogComponent = $Interior/DialogComponent
@onready var overworld: Node2D = $Overworld
@onready var interior: Node2D = $Interior
@onready var player: CharacterBody2D = $Overworld/OverworldPlayer
@onready var camera: Camera2D = $Overworld/OverworldPlayer/Camera2D
@onready var sfx_player: SFXPlayer = $SFXPlayer

func _ready() -> void:
	player.entering_house.connect(_enter_door)

func _enter_door(door: Area2D) -> void:
	sfx_player.play_sfx(door_sfx)
	player.can_move = false
	await sfx_player.finished
	if not door.house_owner:
		AreaManager.switch_area(AreaManager.Area.HUB)
	else:
		player.set_physics_process(false)
		camera.enabled = false
		overworld.hide()
		interior.show()
		_display_owner(door.house_owner)

func _display_owner(input_owner: OwnerData) -> void:
	background.texture = input_owner.background
	character.texture = input_owner.character

	_dialog_about_to_play = _find_dialogs_for_owner(input_owner)
	_pop_dialog()

func _find_dialogs_for_owner(input_owner: OwnerData) -> Array[DialogData]:
	var dialogs: Array[DialogData] = []

	#returning item dialogs
	for item_type in input_owner.returning_item_dialogs: #keys
		for item in Inventory.items:
			if item.type == item_type and item.deterioration == Item.Deterioration.NONE:
				dialogs.append(input_owner.returning_item_dialogs[item_type])
				Inventory.use_item(item)
				break

	#base dialogs
	if dialogs.is_empty():
		var character_key: String = input_owner.resource_path
		#HACK: when unset, adds it with value 0
		var index: int = character_base_dialog_order_mapping.get(character_key, 0)
		dialogs.append(input_owner.base_dialogs[index])
		var new_index: int = (index + 1) % input_owner.base_dialogs.size() #move on to next
		character_base_dialog_order_mapping[character_key] = new_index
	return dialogs

func _pop_dialog() -> void:
	var first_dialog: DialogData = _dialog_about_to_play.pop_front()
	if _dialog_about_to_play.is_empty():
		dialog_component.dialog_finished.connect(
			HintMenu.play.bind(start_icon, palette),
			CONNECT_ONE_SHOT
		)
	else:
		dialog_component.dialog_finished.connect(_pop_dialog, CONNECT_ONE_SHOT)
	dialog_component.play_dialog(first_dialog, palette)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("start"):
		return
	get_viewport().set_input_as_handled()
	if interior.visible:
		_exit_house()

func _exit_house() -> void:
	interior.hide()
	overworld.show()
	camera.enabled = true
	player.set_physics_process(true)
	player.can_move = true
	player.facing_direction = "down"
