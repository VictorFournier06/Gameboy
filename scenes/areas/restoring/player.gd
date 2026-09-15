extends AnimatedSprite2D

@export var speed: float = 1
@export var scrub_effect: Array = [
	[0.1, 0.1, 0.1],
	[0.1, 0.3, 0.1],
	[0.1, 0.1, 0.1]
	]
@export var restorable_object: RestorableObject

var scrubbing: bool = false

@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var player_size: Vector2i = Vector2i(16, 16)
@onready var particles: CPUParticles2D = $"../CPUParticles2D"
@onready var scratch_sound: Node = $"../ScratchSound"

func _ready():
	animation_looped.connect(_stop_scrub_animation_if_necessary)

func _stop_scrub_animation_if_necessary():
	if not scrubbing and animation == "scrubbing":
		play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("right"): dir.x += 1
	if Input.is_action_pressed("left"):  dir.x -= 1
	if Input.is_action_pressed("down"):  dir.y += 1
	if Input.is_action_pressed("up"):    dir.y -= 1
	# note: diagonal movement is sqrt(2) faster
	# it's a fun tech I want to leave in

	position += dir * speed

	position.x = clamp(position.x, player_size.x / 2.0, viewport_size.x - player_size.x / 2.0)
	position.y = clamp(position.y, player_size.y / 2.0, viewport_size.y - player_size.y / 2.0)

	scrubbing = false
	if dir != Vector2.ZERO and restorable_object.scrub_at(global_position, scrub_effect):
			scrubbing = true

	if scrubbing and animation != "scrubbing":
		play("scrubbing")

	particles.global_position = global_position
	particles.emitting = scrubbing

	scratch_sound.scratch_intensity = dir.length() / sqrt(2) #L2 norm
	scratch_sound.scrubbing = scrubbing
