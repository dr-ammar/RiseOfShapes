# السطر الأهم: هنا نخبر Godot أن هذا السكربت هو ابن لـ WeaponBase

extends WeaponBase
class_name Pistol

@onready var muzzle = $Muzzle # ربطنا نقطة خروج الطلقة بالسكربت

func _ready():
	# هنا نحدد أرقام الفرد الخاص بنا
	weapon_name = "Pistol"
	damage = 10
	fire_rate = 0.5 
	max_reserve_ammo = 64
	max_ammo = 8
	current_reserve_ammo = 32
	current_ammo = max_ammo
	
	bullet_scene = preload("res://scenes/bullet.tscn")
	
	# يجب استدعاء دالة الأب لتجهيز مؤقت إطلاق النار (Timer)
	super._ready()

# قمنا بإعادة كتابة دالة الإطلاق لنختبرها
func shoot():
	# الشروط الأساسية موروثة من الأب (هل مسموح الإطلاق؟ وهل يوجد ذخيرة؟)
	if can_shoot and current_ammo > 0 and is_reloading == false and is_shooting == false :
		print("طاخ! تم الإطلاق من: ", weapon_name, " | الذخيرة المتبقية: ", current_ammo - 1)
		current_ammo -= 1
		can_shoot = false
		is_shooting = true
		fire_timer.start()
		
		# مستقبلاً هنا سنقوم باستدعاء كود إخراج مشهد الطلقة (Bullet) من موقع الـ Muzzle
		spawn_bullet()
	elif current_ammo <= 0:
		reload()
