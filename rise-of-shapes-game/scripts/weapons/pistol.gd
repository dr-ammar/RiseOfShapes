extends WeaponBase
class_name Pistol

# --- الموارد (Resources) ---
var shoot_sfx = preload("res://audio/m1911-pistol-shoot.mp3")
var reload_sfx = preload("res://audio/m1911-reload.mp3")

func _ready():
	# إعدادات المسدس الخاصة
	weapon_name = "Pistol"
	damage = 10
	knockback_force = 100.0 # Reduced from 150
	max_range = 800.0 # مدى بعيد للمسدس
	fire_rate = 0.5 
	max_reserve_ammo = 64
	max_ammo = 8
	current_reserve_ammo = 32
	current_ammo = max_ammo
	
	bullet_scene = preload("res://scenes/bullet.tscn")
	
	# استدعاء _ready للأب لتجهيز المؤقت والمكونات
	super._ready()

# --- الإجراءات (Actions) ---

func shoot():
	# التحقق من شروط الإطلاق الموروثة
	if can_shoot and current_ammo > 0 and not is_reloading and not is_shooting:
		print("إطلاق نار من المسدس!")
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
	
	# تشغيل صوت التعشيق بسرعة محددة (1.2 لتناسب الأنيميشن)
	play_reload_sfx(reload_sfx, 1.2)
	super.reload()
