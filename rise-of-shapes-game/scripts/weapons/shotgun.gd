extends WeaponBase
class_name Shotgun

# --- الموارد (Resources) ---
var shoot_sfx = preload("res://audio/shotgun-firing-3-14483.mp3")
var reload_sfx = preload("res://audio/rifle-or-shotgun-reload-6787.mp3")

func _ready():
	# إعدادات الشوزن الخاصة
	weapon_name = "Shotgun"
	damage = 50
	knockback_force = 150.0 # Reduced from 450
	max_range = 150.0 # مدى قصير للشوزن
	fire_rate = 1.0
	reload_time = 2.0
	max_reserve_ammo = 32
	max_ammo = 4
	current_reserve_ammo = max_reserve_ammo
	current_ammo = max_ammo
	
	bullet_scene = preload("res://scenes/bullet.tscn")
	
	# استدعاء _ready للأب لتجهيز المؤقت والمكونات
	super._ready()

# --- الإجراءات (Actions) ---

func shoot():
	if can_shoot and current_ammo > 0 and not is_reloading and not is_shooting:
		print("إطلاق نار من الشوزن!")
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
		
	# تشغيل صوت التعشيق بسرعة مضاعفة لتناسب الأنيميشن السريع
	play_reload_sfx(reload_sfx, 2.0)
	super.reload()
