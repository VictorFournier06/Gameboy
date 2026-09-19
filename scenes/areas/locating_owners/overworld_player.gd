extends CharacterBody2D

const TILE_SIZE: float = 16.0

@export var step_duration: float

var moving: bool = false
var can_move: bool = true
var tween: Tween
var facing_direction: String = "down"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast: RayCast2D = $RayCast2D

func _physics_process(_delta: float) -> void:
	if not can_move:
		tween.kill()
		return
	if moving:
		return

	var direction: Vector2 = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if direction.x != 0.0:
		direction.y = 0.0

	if direction == Vector2.ZERO:
		animated_sprite.play("idle_" + facing_direction)
		return

	if direction.x > 0.0: facing_direction = "right"
	elif direction.x < 0.0: facing_direction = "left"
	elif direction.y > 0.0: facing_direction = "down"
	elif direction.y < 0.0: facing_direction = "up"
	animated_sprite.play(("walk_") + facing_direction)

	ray_cast.target_position = direction * TILE_SIZE
	ray_cast.force_raycast_update()
	if not ray_cast.is_colliding():
		moving = true
		tween = create_tween()
		tween.tween_property(self, "position", position + direction * TILE_SIZE, step_duration)
		await tween.finished
		moving = false
