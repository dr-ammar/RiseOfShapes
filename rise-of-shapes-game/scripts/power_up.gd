extends Area2D

enum PowerUpType { NUKE, DOUBLE_POINTS, MAX_AMMO, INSTA_KILL, ZOMBIE_CASH }

var type: PowerUpType
var despawn_time: float = 15.0

@onready var sprite = $Sprite

func _ready():
	# Randomly choose type
	type = PowerUpType.values().pick_random()
	setup_visuals()
	
	# Connect signal
	body_entered.connect(_on_body_entered)
	
	# Despawn timer
	get_tree().create_timer(despawn_time).timeout.connect(queue_free)
	
	# Optional: make it blink before despawning
	get_tree().create_timer(despawn_time - 5.0).timeout.connect(_start_blinking)

func setup_visuals():
	match type:
		PowerUpType.NUKE:
			sprite.play("Nuke")
		PowerUpType.DOUBLE_POINTS:
			sprite.play("Double_Points")
		PowerUpType.MAX_AMMO:
			sprite.play("Max_Ammo")
		PowerUpType.INSTA_KILL:
			sprite.play("Insta_Kill")
		PowerUpType.ZOMBIE_CASH:
			sprite.play("Zombie_Cash")

func _on_body_entered(body):
	if body.is_in_group("player"):
		apply_effect(body)
		queue_free()

func apply_effect(player):
	match type:
		PowerUpType.NUKE:
			player.show_hud_message("NUKE!", 2.0)
			# Kill all currently active zombies
			var enemies = get_tree().get_nodes_in_group("enemy")
			for enemy in enemies:
				if enemy.has_method("die"):
					enemy.die()
			# Award points
			player.points += 400
			
		PowerUpType.DOUBLE_POINTS:
			player.show_hud_message("DOUBLE POINTS!", 2.0)
			GameManager.activate_double_points(30.0)
			
		PowerUpType.MAX_AMMO:
			player.show_hud_message("MAX AMMO!", 2.0)
			# Refill all weapons in inventory
			for weapon in player.weapons_inventory:
				if is_instance_valid(weapon):
					weapon.current_ammo = weapon.max_ammo
					weapon.current_reserve_ammo = weapon.max_reserve_ammo
					
		PowerUpType.INSTA_KILL:
			player.show_hud_message("INSTA-KILL!", 2.0)
			GameManager.activate_insta_kill(30.0)
			
		PowerUpType.ZOMBIE_CASH:
			player.show_hud_message("ZOMBIE CASH!", 2.0)
			player.points += 500

func _start_blinking():
	var tween = create_tween().set_loops(10)
	tween.tween_property(self, "modulate:a", 0.3, 0.25)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
