extends Sprite2D

@export var speed: int = 2
@export var scrub_effect: Array = [[0.1]]
@export var restorable_object: RestorableObject

@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var player_size: Vector2 = texture.get_size()

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

	position.x = clamp(position.x, player_size.x / 2, viewport_size.x - player_size.x / 2)
	position.y = clamp(position.y, player_size.y / 2, viewport_size.y - player_size.y / 2)

	restorable_object.scrub_at(position, scrub_effect)
