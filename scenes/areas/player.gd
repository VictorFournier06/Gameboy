extends Sprite2D

@export var speed: int = 2
@export var scrub_size: int = 1
@export var scrub_strength: int = 1

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
