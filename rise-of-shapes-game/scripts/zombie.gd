extends CharacterBody2D

var health: int = 30
var speed: float = 80.0
var damage: int = 10
var player: Node2D = null

func _ready():
	add_to_group("enemy")
	
	# Wait a frame so player is ready
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player and is_instance_valid(player):
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		
		# Optional: Flip sprite based on movement direction
		if velocity.x < 0:
			$Sprite2D.flip_h = true
		elif velocity.x > 0:
			$Sprite2D.flip_h = false
			
		move_and_slide()

func take_damage(amount: int):
	health -= amount
	# Can play hurt animation or sound here
	
	if health <= 0:
		die()

func die():
	if player and is_instance_valid(player):
		player.points += 100
	queue_free()

func _on_hitbox_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
