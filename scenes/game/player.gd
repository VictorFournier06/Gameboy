class_name Player

static func move(node: Node2D, speed: float, bounds: Rect2) -> Vector2:
	var direction := Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down"))
	node.position += direction * speed
	# note: diagonal movement is sqrt(2) faster
	# it's a fun tech I want to leave in
	node.position = node.position.clamp(bounds.position, bounds.end)
	return direction
