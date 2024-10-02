extends CharacterBody2D

signal laser_shot(laser)

@export var acceleration := 10
@export var max_speed := 450
@export var rotation_speed := 250
@export var recoil_force := 300

@onready var muzzle = $Muzzle
@onready var audio_player = $AudioStreamPlayer2D  # Reference to the AudioStreamPlayer node

var laser_scene = preload("res://Scenes/laser.tscn")

#input event for shooting laser
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("shoot"):
		shoot_laser()

func _physics_process(delta: float) -> void:
	# Limit the speed of the player to prevent infinite acceleration
	velocity = velocity.limit_length(max_speed)
	
	# Rotate player if action left or right occurs
	if Input.is_action_pressed("rotate_right"):
		rotate(deg_to_rad(rotation_speed * delta))
	if Input.is_action_pressed("rotate_left"):
		rotate(deg_to_rad(-rotation_speed * delta))
		
	# Gradually slow down the player if no input is detected 
	velocity = velocity.move_toward(Vector2.ZERO, 3)
	
	# Move and handle collisions
	move_and_slide()

	var screen_size = get_viewport_rect().size

	# Recenter sprite if it exceeds y-axis coordinates
	if global_position.y < 0:
		global_position.y = screen_size.y
	elif global_position.y > screen_size.y:
		global_position.y = 0
		
	# Recenter sprite if it exceeds x-axis coordinates 
	if global_position.x < 0:
		global_position.x = screen_size.x
	elif global_position.x > screen_size.x:
		global_position.x = 0

func shoot_laser():
	var l = laser_scene.instantiate()           #create new laser object
	l.global_position = muzzle.global_position  #set position of laser to posiiton of muzzle
	l.rotation = rotation 
	
	#notify other parts of code that event (laser fire) has occured
	emit_signal("laser_shot", l)               
	
	audio_player.play()

	# Apply backward force (recoil) when shooting
	var recoil_vector = Vector2(0, recoil_force).rotated(rotation)
	velocity = recoil_vector
