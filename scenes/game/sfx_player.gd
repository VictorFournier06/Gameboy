class_name SFXPlayer
extends AudioStreamPlayer

func play_sfx(input_stream: AudioStream, volume: float = 0.0) -> void:
	stream = input_stream
	volume_db = volume
	play()
