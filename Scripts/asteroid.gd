extends Area2D

var movement_vector := Vector2(0, -1)
var speed = 50

func _ready():
	rotation = randf_range(0, 2 * PI)
	print(rotation_degrees)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	global_position += movement_vector.rotated(rotation) * speed * delta
