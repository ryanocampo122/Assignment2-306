extends Node2D

@export var asteroid_scene: PackedScene
@export var spawn_interval: float = 2.0 # Time between spawns
@export var screen_margin: float = 50.0 # Margin to spawn outside screen
var time_since_last_spawn: float = 0.0

func _ready():
	# Start spawning asteroids when the game starts
	time_since_last_spawn = spawn_interval

func _physics_process(delta):
	time_since_last_spawn += delta
	if time_since_last_spawn >= spawn_interval:
		spawn_asteroid()
		time_since_last_spawn = 0.0

func spawn_asteroid():
	# Instantiate an asteroid
	var asteroid = asteroid_scene.instantiate()
	
	# Random position outside of the screen bounds
	var screen_size = get_viewport_rect().size
	var x_position = randf_range(-screen_margin, screen_size.x + screen_margin)
	var y_position = randf_range(-screen_margin, screen_size.y + screen_margin)
	
	# Randomize spawn at one of the screen's four edges
	if randf() < 0.5:
		x_position = randf() < 0.5 ? -screen_margin : screen_size.x + screen_margin
	else:
		y_position = randf() < 0.5 ? -screen_margin : screen_size.y + screen_margin
	
	asteroid.global_position = Vector2(x_position, y_position)
	
	# Add asteroid to the scene
	add_child(asteroid)
