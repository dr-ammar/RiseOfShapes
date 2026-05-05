extends WeaponBase
class_name AssaultRifle

var shoot_sfx = preload("res://audio/m1911-pistol-shoot.mp3") 
var reload_sfx = preload("res://audio/rifle-or-shotgun-reload-6787.mp3")

func _ready():
	weapon_name = "Assault Rifle"
	damage = 15
	knockback_force = 40.0 # Reduced from 100
	max_range = 1200.0
	fire_rate = 0.1 
	is_automatic = true
	reload_time = 2.5
	max_reserve_ammo = 120
	max_ammo = 30
	current_reserve_ammo = 120
	current_ammo = max_ammo
	
	bullet_scene = preload("res://scenes/bullet.tscn")
	super._ready()

func shoot():
	if can_shoot and current_ammo > 0 and not is_reloading and not is_shooting:
		self.current_ammo -= 1
		can_shoot = false
		is_shooting = true
		
		fire_timer.start()
		play_shoot_anim()
		play_shoot_sfx(shoot_sfx)
		spawn_bullet(damage)
		
	elif current_ammo <= 0:
		reload()

func reload():
	if current_ammo == max_ammo or current_reserve_ammo == 0 or is_reloading or not reload_block_timer.is_stopped():
		return
	
	play_reload_sfx(reload_sfx, 1.0)
	super.reload()
