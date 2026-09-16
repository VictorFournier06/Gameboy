extends AnimatedSprite2D

@export var speed: float = 1.0
@export var scrub_effect: Array = [
	[0.1, 0.1, 0.1],
	[0.1, 0.3, 0.1],
	[0.1, 0.1, 0.1]
	]

var scrubbing: bool = false

@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var player_size: Vector2 = Vector2(16.0, 16.0)
@onready var bounds: Rect2 = Rect2(player_size / 2.0, viewport_size - player_size)

@onready var particles: CPUParticles2D = $CPUParticles2D
@onready var scratch_sound: Node = $ScratchSound
@onready var cleaning: Cleaning = get_parent()

func _ready():
	animation_looped.connect(_stop_scrub_animation_if_necessary)

func _stop_scrub_animation_if_necessary():
	if not scrubbing and animation == "scrubbing":
		play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var direction: Vector2 = Player.move(self, speed, bounds)

	scrubbing = false
	if direction != Vector2.ZERO and cleaning.scrub_at(global_position, scrub_effect):
			scrubbing = true

	if scrubbing and animation != "scrubbing":
		play("scrubbing")

	particles.global_position = global_position
	particles.emitting = scrubbing

	scratch_sound.scratch_intensity = direction.length() / sqrt(2) #L2 norm
	scratch_sound.scrubbing = scrubbing
