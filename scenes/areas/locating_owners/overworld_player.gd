extends CharacterBody2D

const TILE_SIZE: float = 16.0

@export var step_duration: float

var moving: bool = false
var can_move: bool = true
var tween: Tween

@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $RayCast2D

func _physics_process(_delta: float) -> void:
	if not can_move:
		tween.kill()
		return
	var direction: Vector2 = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	if moving or direction == Vector2.ZERO:
		return
	if direction.x != 0.0:
		direction.y = 0.0
	ray_cast.target_position = direction * TILE_SIZE
	ray_cast.force_raycast_update()
	if not ray_cast.is_colliding():
		moving = true
		tween = create_tween()
		tween.tween_property(self, "position", position + direction * TILE_SIZE, step_duration)
		await tween.finished
		moving = false
