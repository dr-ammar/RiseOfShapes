extends Area2D

@export var speed: float = 800.0
@export var damage: int = 10

func _physics_process(delta):
	# Move forward in the direction of the rotation
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body):
	# Check if the body is an enemy
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
	# Optional: Destroy bullet if it hits a wall
	elif body.name != "player1" and body.name != "Player1": # avoid hitting player
		pass # Currently we might not have walls configured with groups, so we'll just let it pass or add logic later.

func _on_timer_timeout():
	queue_free()
