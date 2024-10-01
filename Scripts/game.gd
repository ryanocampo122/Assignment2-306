extends Node2D

@onready var lasers = $Laser
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("laser_shot", on_player_laser_shot)

func on_player_laser_shot(laser):
	lasers.add_child(laser)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
