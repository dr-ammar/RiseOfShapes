extends CharacterBody2D

var health: int = 30
var speed: float = 80.0
var damage: int = 10
var player: Node2D = null
var attack_cooldown: float = 0.6
var attack_timer: float = 0.0

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
		
		# Damage logic: deals damage every 'attack_cooldown' seconds while player is in range
		if attack_timer > 0:
			attack_timer -= delta
		else:
			for body in $Hitbox.get_overlapping_bodies():
				if body.is_in_group("player"):
					if body.has_method("take_damage"):
						body.take_damage(damage)
						attack_timer = attack_cooldown
						break

func take_damage(amount: int):
	health -= amount
	# Can play hurt animation or sound here
	
	if health <= 0:
		die()

func die():
	if player and is_instance_valid(player):
		player.points += 100
	queue_free()

# The continuous damage is now handled in _physics_process
func _on_hitbox_body_entered(_body):
	pass
