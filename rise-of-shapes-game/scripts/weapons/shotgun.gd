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
		
	elif current_ammo <= 0:
		reload()
