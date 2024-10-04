class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

@export var acceleration := 10.0
@export var max_speed := 350.0
@export var rotation_speed := 350.0
@export var recoil_strength = 35.0

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

var laser_scene = preload("res://scenes/laser.tscn")

var shoot_cd = false
var rate_of_fire = 0.25

var alive := true

func _process(delta):
	if !alive: return
	
	if Input.is_action_pressed("shoot"):
		if !shoot_cd:
			shoot_cd = true
			shoot_laser()
			await get_tree().create_timer(rate_of_fire).timeout
			shoot_cd = false

func _physics_process(delta):
	if !alive: return
	
	# No forward/backward movement, just rotation
	var input_vector := Vector2.ZERO
	
	velocity = velocity.limit_length(max_speed)
	
	# Handle rotation
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
	
	# Gradually slow down when there's no input
	if velocity.length() > 0:
		velocity = velocity.move_toward(Vector2.ZERO, 10 * delta)
	
	# Move player
	move_and_slide()

	# Screen wrapping logic
	var screen_size = get_viewport_rect().size
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

# Laser shooting with recoil mechanic
func shoot_laser():
	var l = laser_scene.instantiate()
	l.global_position = muzzle.global_position
	l.rotation = rotation
	emit_signal("laser_shot", l)
	
	# Recoil force opposite to the shooting direction
	var recoil_force = Vector2(0, -1).rotated(rotation) * recoil_strength
	velocity -= recoil_force
	
func _on_body_entered(body):
	if body is Asteroid:
		# Calculate the normal vector based on the collision point
		var normal_vector = (body.global_position - global_position).normalized()
		
		# Reflect the player's velocity using the normal
		velocity = velocity.bounce(normal_vector)
		
		# Apply a force to the asteroid to reflect its movement vector
		var reflection_force = normal_vector * 200  
		body.movement_vector += reflection_force
