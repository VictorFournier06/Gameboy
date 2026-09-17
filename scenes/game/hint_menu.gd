extends CanvasLayer

const SIZE: float = 22.0

var tween: Tween

func _slide_in():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "offset:x", SIZE, 0.2)

func _slide_out():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "offset:x", 0.0, 0.2)

func 
