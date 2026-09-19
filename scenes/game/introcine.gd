extends AnimatedSprite2D

@export var animation_1_duration: float = 6.0

func _ready():
	
	play("default")

	# Wait X seconds
	await get_tree().create_timer(animation_1_duration).timeout

	
	play("water")

	
	await animation_finished

	
	play("titleloop")
