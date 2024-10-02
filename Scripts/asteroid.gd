extends RigidBody2D

var movement_vector := Vector2(0, -1)
var speed = 50

func _ready() -> void:
	randomize()  # Ensures randomness in position
	global_position = Vector2(randf_range(0, get_viewport_rect().size.x), randf_range(0, get_viewport_rect().size.y))

func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta
