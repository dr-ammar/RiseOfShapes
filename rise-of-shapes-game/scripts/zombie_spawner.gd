extends Node2D

@export var zombie_scene: PackedScene
@export var spawn_interval: float = 3.0
@export var max_zombies: int = 20
@export var is_active: bool = true

var timer: Timer

func _ready():
	# Default zombie scene if none provided
	if not zombie_scene:
		zombie_scene = preload("res://scenes/zombie.tscn")
		
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = is_active
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout():
	if not is_active:
		return
		
	# Check current number of zombies
	var current_zombies = get_tree().get_nodes_in_group("enemy").size()
	if current_zombies < max_zombies:
		spawn_zombie()

func spawn_zombie():
	if zombie_scene:
		var zombie = zombie_scene.instantiate()
		zombie.global_position = global_position
		# Add to the main scene tree, usually root or a specific container
		get_tree().current_scene.add_child(zombie)
