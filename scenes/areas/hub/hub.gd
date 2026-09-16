extends Control

@export var navigate_sfx: AudioStream
@export var enter_sfx: AudioStream

@onready var sfx_player: SFXPlayer = $SFXPlayer
@onready var fish_pole: TextureButton = $FishPole
@onready var door: TextureButton = $Door
@onready var workshop: TextureButton = $Workshop
@onready var button_area_binding: Dictionary = {
	fish_pole: AreaManager.Area.FISHING,
	door: AreaManager.Area.LOCATING_OWNERS,
	workshop: AreaManager.Area.RESTORING
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_focus_button_you_originate_from()

	for button in [fish_pole, door, workshop]:
		button.focus_entered.connect(sfx_player.play_sfx.bind(navigate_sfx))
		button.pressed.connect(sfx_player.play_sfx.bind(enter_sfx, -8.0))
		button.pressed.connect(_on_area_selected.bind(button_area_binding[button]))

func _on_area_selected(area: AreaManager.Area) -> void:
	await sfx_player.finished
	AreaManager.switch_area(area)

func _focus_button_you_originate_from():
	for button in button_area_binding:
		if button_area_binding[button] == AreaManager.origin_area:
			button.grab_focus()
			return
	fish_pole.grab_focus() #default
