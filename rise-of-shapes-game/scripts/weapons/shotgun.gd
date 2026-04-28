extends WeaponBase
class_name Shotgun

@onready var muzzle = $Muzzle # ربطنا نقطة خروج الطلقة بالسكربت

func _ready():
	
	weapon_name = "Shotgun"
	damage = 30
	fire_rate = 1.0 #1.0s
	max_reserve_ammo = 32
	max_ammo = 4
	current_reserve_ammo = max_reserve_ammo
	current_ammo = max_ammo
	
	bullet_scene = preload("res://scenes/bullet.tscn")
	
	# يجب استدعاء دالة الأب لتجهيز مؤقت إطلاق النار (Timer)
	super._ready()

var shoot_sfx = preload("res://audio/shotgun-firing-3-14483.mp3")
var reload_sfx = preload("res://audio/rifle-or-shotgun-reload-6787.mp3")

# قمنا بإعادة كتابة دالة الإطلاق لنختبرها
func shoot():
	# الشروط الأساسية موروثة من الأب (هل مسموح الإطلاق؟ وهل يوجد ذخيرة؟)
	if can_shoot and current_ammo > 0 and is_reloading == false and is_shooting == false :
		print("طاخ! تم الإطلاق من: ", weapon_name, " | الذخيرة المتبقية: ", current_ammo - 1)
		current_ammo -= 1
		can_shoot = false
		is_shooting = true
		fire_timer.start()
		play_shoot_anim()
		play_shoot_sfx(shoot_sfx)
		
		# For shotgun, maybe spawn multiple pellets? For now just one like pistol
		spawn_bullet()
		
	elif current_ammo <= 0:
		reload()

func reload():
	if current_ammo == max_ammo or current_reserve_ammo == 0 or is_reloading or is_shooting:
		return
		
	play_reload_sfx(reload_sfx)
	super.reload()
