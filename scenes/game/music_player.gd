extends AudioStreamPlayer

@export var fade_duration = 0.5

func music_transition(new_song: AudioStream) -> void:
	var tween = create_tween()
	tween.tween_property(self, "volume_db", -20.0, fade_duration)
	tween.tween_callback(func(): 
		stream = new_song
		play()
	)
	tween.tween_property(self, "volume_db", 0, fade_duration)
