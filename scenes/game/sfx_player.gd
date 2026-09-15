class_name SFXPlayer
extends AudioStreamPlayer

func play_sfx(input_stream: AudioStream) -> void:
	stream = input_stream
	play()
