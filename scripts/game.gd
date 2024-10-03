extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var asteroid_respawn_timer = $AsteroidRespawnTimer

var velocity := Vector2.ZERO

var asteroid_scene = preload("res://scenes/asteroid.tscn")

func _ready():
	player.connect("laser_shot", _on_player_laser_shot)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _process(delta):
	#for debugging
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size):
	$AsteroidHitSound.play()
	for i in range(2):
		match size:
			Asteroid.AsteroidSize.LARGE:
				spawn_asteroid(pos, Asteroid.AsteroidSize.MEDIUM)
			Asteroid.AsteroidSize.MEDIUM:
				spawn_asteroid(pos, Asteroid.AsteroidSize.SMALL)
			Asteroid.AsteroidSize.SMALL:
				pass 

func spawn_asteroid(pos, size):
	var a = asteroid_scene.instantiate()
	a.global_position = pos
	a.size = size
	a.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", a)


func _on_asteroid_respawn_timer_timeout() -> void:
	# Instantiate a new asteroid from the preloaded asteroid scene
	var new_asteroid = asteroid_scene.instantiate()
	
	# Get the size of the screen (viewport), used to determine where to spawn the asteroid
	var screen_size = get_viewport_rect().size
	
	# Choose a random side of the screen for the asteroid to spawn from (0=top, 1=right, 2=bottom, 3=left)
	var side = randi() % 4
	
	# Initialize the spawn position as a Vector2 (we will set the specific position based on the side)
	var spawn_position = Vector2()

	# Match the side and assign the spawn position based on which side was chosen
	match side:
		0: # Spawn from the top of the screen
			spawn_position = Vector2(randi() % int(screen_size.x), -screen_size.y)
		1: # Spawn from the right side of the screen
			spawn_position = Vector2(screen_size.x, randi() % int(screen_size.y))
		2: # Spawn from the bottom of the screen
			spawn_position = Vector2(randi() % int(screen_size.x), screen_size.y)
		3: # Spawn from the left side of the screen
			spawn_position = Vector2(-screen_size.x, randi() % int(screen_size.y))
	
	# Randomly select the asteroid size from the available enum values in the Asteroid class
	var asteroid_size = Asteroid.AsteroidSize.values()[randi() % Asteroid.AsteroidSize.size()]

	# Set the asteroid's spawn position to the calculated position outside the screen
	new_asteroid.global_position = spawn_position

	# Assign the random size to the asteroid
	new_asteroid.size = asteroid_size

	# Connect the "exploded" signal from the asteroid to the handler function for explosions
	new_asteroid.connect("exploded", _on_asteroid_exploded)

	# Defer the addition of the asteroid to the scene (so that it gets added after the current frame ends)
	asteroids.call_deferred("add_child", new_asteroid)
