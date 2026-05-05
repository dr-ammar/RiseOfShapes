extends WeaponBase
class_name Raygun

var shoot_sfx = preload("res://assets/wonder_weapons/ray-gun-sound.mp3")
var reload_sfx = preload("res://assets/wonder_weapons/ray-gun-reloading-sound.mp3")

func _ready():
	weapon_name = "Raygun Mark 2"
	damage = 250
	knockback_force = 80.0 # Reduced from 300
	max_range = 1000.0
	fire_rate = 0.4
	is_automatic = true
	reload_time = 2.8
	max_reserve_ammo = 162
	max_ammo = 21
	current_reserve_ammo = 162
	current_ammo = max_ammo
	
	bullet_scene = preload("res://scenes/weapons/ray_guns_bullet.tscn")
	super._ready()

func shoot():
	if can_shoot and current_ammo > 0 and not is_reloading and not is_shooting:
		self.current_ammo -= 1
		can_shoot = false
		is_shooting = true
		
		fire_timer.start()
		play_shoot_anim()
		play_shoot_sfx(shoot_sfx)
		
		# Animate recoil
		if is_instance_valid(weapon_sprite):
			var original_pos = weapon_sprite.position
			weapon_sprite.position = original_pos + Vector2(-3, 0)
			await get_tree().create_timer(0.1).timeout
			weapon_sprite.position = original_pos
		
		spawn_bullet(damage)
		
	elif current_ammo <= 0:
		reload()

func reload():
	if current_ammo == max_ammo or current_reserve_ammo == 0 or is_reloading or not reload_block_timer.is_stopped():
		return
	
	play_reload_sfx(reload_sfx, 1.0)
	
	# Animate dip
	if is_instance_valid(weapon_sprite):
		var original_pos = weapon_sprite.position
		weapon_sprite.position = original_pos + Vector2(0, 5)
		weapon_sprite.rotation_degrees = -30
	
	await super.reload()
	
	if is_instance_valid(weapon_sprite):
		weapon_sprite.position = Vector2(7, -2) # Reset position
		weapon_sprite.rotation_degrees = 0
