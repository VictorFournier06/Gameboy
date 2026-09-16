extends Node

@export var track_nb: int = 6
@export var scratch_sounds: Array[AudioStream]

var cooldown: float = -1.0  #start negative to ensure it's set in _process
var audio_player_index: int = 0
var audio_players: Array[AudioStreamPlayer] = []
var scrubbing: bool = false
var scratch_intensity: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(track_nb):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(player)
		player.bus = "SFX"
		audio_players.append(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not scrubbing:
		return
	cooldown -= delta
	if cooldown < 0.0:
		#new random cooldown based on scratch_intensity
		var min_cooldown: float = lerp(0.10, 0.02, scratch_intensity)
		var max_cooldown: float = lerp(0.16, 0.05, scratch_intensity)
		cooldown = randf_range(min_cooldown, max_cooldown)

		var player: AudioStreamPlayer = audio_players[audio_player_index]
		audio_player_index = (audio_player_index + 1) % track_nb

		var scratch_sound_index = randi_range(0, scratch_sounds.size() - 1)
		player.stream = scratch_sounds[scratch_sound_index]

		var scratch_log_mean_pitch: float = lerp(-0.1, 0.2, scratch_intensity) #faster = higher
		var scratch_pitch: float = pow(2.0, randfn(scratch_log_mean_pitch, 0.05))
		player.pitch_scale = scratch_pitch

		var scratch_mean_volume: float = lerp(-8.0, 0.0, scratch_intensity) #faster = louder
		var scratch_volume: float = randfn(scratch_mean_volume, 2.0)
		player.volume_db = scratch_volume

		player.play()
