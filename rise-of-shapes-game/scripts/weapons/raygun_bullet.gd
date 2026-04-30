extends Area2D

# --- Settings ---
@export var speed: float = 400.0
@export var damage: int = 250
var knockback_force: float = 300.0
var max_range: float = 1500.0
var traveled_distance: float = 0.0

var is_dying: bool = false

func _physics_process(delta):
	if is_dying:
		return
		
	# Move forward based on rotation
	var step = speed * delta
	position += Vector2.RIGHT.rotated(rotation) * step
	
	# Track distance and free if it goes beyond max range
	traveled_distance += step
	if traveled_distance >= max_range:
		explode()

# --- Collision Handling ---

func _on_body_entered(body):
	if is_dying:
		return
		
	# If bullet hits an enemy
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage, knockback_force)
		explode()
	
	# If bullet hits a wall (anything not player or enemy)
	elif not body.is_in_group("player"):
		explode()

func _on_area_entered(_area):
	# Handle collisions with other areas if necessary
	pass

func _on_timer_timeout():
	explode()

func explode():
	if is_dying:
		return
	is_dying = true
	
	# Hide visible parts
	if has_node("sprite2d"):
		get_node("sprite2d").hide()
	if has_node("PointLight2D"):
		get_node("PointLight2D").hide()
	if has_node("Sprite2D"): # Check both casing just in case
		get_node("Sprite2D").hide()
		
	# Stop emitting new particles but let existing ones finish
	if has_node("particles"):
		get_node("particles").emitting = false
	if has_node("rings"):
		get_node("rings").emitting = false
	if has_node("CPUParticles2D"):
		get_node("CPUParticles2D").emitting = false
		
	# Disable collisions
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	# Wait for particles to fade out
	await get_tree().create_timer(1.0).timeout
	queue_free()
