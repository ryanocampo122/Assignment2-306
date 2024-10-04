class_name Asteroid extends Area2D

signal exploded(pos, size)

var movement_vector := Vector2(0, -1)

enum AsteroidSize{LARGE, MEDIUM, SMALL}
@export var size := AsteroidSize.LARGE

var speed := 200

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

# Linear velocity (movement speed) vector
@export var velocity: Vector2 = Vector2(100, 0)
# Rotation speed in radians per second
@export var rotation_speed: float = 2.0

func _ready():
	rotation = randf_range(0, 2*PI)

	match size:
		AsteroidSize.LARGE:
			speed = randf_range(50, 100)
			sprite.texture = preload("res://assets/textures/a10000.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_large.tres"))
		AsteroidSize.MEDIUM:
			speed = randf_range(100, 150)
			sprite.texture = preload("res://assets/textures/a10001.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_medium.tres"))
		AsteroidSize.SMALL:
			speed = randf_range(100, 200)
			sprite.texture = preload("res://assets/textures/a10003.png")
			cshape.set_deferred("shape", preload("res://resources/asteroid_cshape_small.tres"))

func _process(delta: float) -> void:
	# Update position using linear velocity
	position += velocity * delta * 5
	# Rotate without affecting velocity
	rotation += rotation_speed * delta

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta
	
	var radius = cshape.shape.radius
	var screen_size = get_viewport_rect().size
	if (global_position.y+radius) < 0:
		global_position.y = (screen_size.y+radius)
	elif (global_position.y-radius) > screen_size.y:
		global_position.y = -radius
	if (global_position.x+radius) < 0:
		global_position.x = (screen_size.x+radius)
	elif (global_position.x-radius) > screen_size.x:
		global_position.x = -radius

func explode():
	emit_signal("exploded", global_position, size)
	queue_free()
	
func _on_body_entered(body):
	if body is CharacterBody2D:
		# Calculate the normal vector based on the collision point
		var normal_vector = (body.global_position - global_position).normalized()

		# Reflect the asteroid's movement vector using the normal
		movement_vector = movement_vector.bounce(normal_vector)

		# Apply a force to the player to reflect their velocity
		var reflection_force = normal_vector * 300
		body.velocity += reflection_force
