extends WeaponBase
class_name ThunderGun

var shoot_sfx = preload("res://audio/Weapons Sound Effects/ThunderGun_Shoot_Sound.MP3")
var reload_sfx = preload("res://audio/Weapons Sound Effects/ThunderGun_Reload_Sound.MP3")

func _ready():
	weapon_name = "Thunder Gun"
	damage = 1000 # دمج هائل
	knockback_force = 500.0 # Reduced from 1000
	max_range = 500.0
	fire_rate = 1.5 # بطيء الإطلاق
	is_automatic = false
	reload_time = 3.5
	max_reserve_ammo = 12
	max_ammo = 2
	current_reserve_ammo = 12
	current_ammo = max_ammo
	
	bullet_scene = preload("res://scenes/weapons/thunder_gun_bullet.tscn")
	super._ready()

func shoot():
	if can_shoot and current_ammo > 0 and not is_reloading and not is_shooting:
		self.current_ammo -= 1
		can_shoot = false
		is_shooting = true
		
		fire_timer.start()
		play_shoot_anim()
		play_shoot_sfx(shoot_sfx)
		
		# تأثير الارتداد على السلاح
		if is_instance_valid(weapon_sprite):
			var original_pos = weapon_sprite.position
			var tween = create_tween()
			tween.tween_property(weapon_sprite, "position", original_pos + Vector2(-10, 0), 0.1)
			tween.tween_property(weapon_sprite, "position", original_pos, 0.2)
		
		spawn_bullet(damage)
		
	elif current_ammo <= 0:
		reload()

func reload():
	if current_ammo == max_ammo or current_reserve_ammo == 0 or is_reloading or not reload_block_timer.is_stopped():
		return
	
	play_reload_sfx(reload_sfx, 0.8) # صوت أبطأ قليلاً ليعطي شعوراً بالثقل
	
	if is_instance_valid(weapon_sprite):
		var original_pos = weapon_sprite.position
		var tween = create_tween()
		tween.tween_property(weapon_sprite, "rotation_degrees", -45, 0.5)
		tween.tween_property(weapon_sprite, "position", original_pos + Vector2(0, 10), 0.5)
	
	await super.reload()
	
	if is_instance_valid(weapon_sprite):
		weapon_sprite.position = Vector2(7, -2)
		weapon_sprite.rotation_degrees = 0
