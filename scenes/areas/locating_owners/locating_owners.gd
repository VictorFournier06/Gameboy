extends Node2D

@export var owners: Array[OwnerData]
@export var palette: ColorPalette
@export var start_icon: Texture2D
@export var door_sfx: AudioStream

@onready var background: Sprite2D = $Interior/Background
@onready var character: Sprite2D = $Interior/Character
@onready var dialog_component: DialogComponent = $Interior/DialogComponent
@onready var overworld: Node2D = $Overworld
@onready var interior: Node2D = $Interior
@onready var player: CharacterBody2D = $Overworld/OverworldPlayer
@onready var camera: Camera2D = $Overworld/OverworldPlayer/Camera2D
@onready var sfx_player: SFXPlayer = $SFXPlayer

func _ready() -> void:
	for door in $Overworld/Doors.get_children():
		door.body_entered.connect(_enter_door.bind(door))

func _enter_door(element: Node2D, door: Area2D) -> void:
	if element != player:
		return
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
		_display_owner(door.house_owner, 0)

func _display_owner(input_owner: OwnerData, dialog_nb: int) -> void:
	background.texture = input_owner.background
	character.texture = input_owner.character
	dialog_component.dialog_finished.connect(HintMenu.play.bind(start_icon, palette), CONNECT_ONE_SHOT)
	dialog_component.play_dialog(input_owner.dialogs[dialog_nb], palette)
