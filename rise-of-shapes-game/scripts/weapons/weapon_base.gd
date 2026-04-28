extends Node2D
class_name WeaponBase # هذا السطر مهم جداً! هو ما يسمح للأسلحة الأخرى بوراثة هذا الكلاس

# المتغيرات المشتركة لكل الأسلحة
var weapon_name: String = "Default Weapon"
var damage: int
var fire_rate: float # الوقت بين كل طلقة والأخرى
# Ammo Specs
var max_ammo: int
var max_reserve_ammo: int
var current_ammo: int
var current_reserve_ammo: int

#Reloading Settings
var is_reloading := false

# Shoting Settings
var is_shotgun: bool = false
var can_shoot: bool = true
var is_shooting := false
var fire_timer: Timer

func _ready():
	current_ammo = max_ammo
	setup_fire_timer()

# تجهيز مؤقت إطلاق النار للتحكم بسرعة الطلقات
func setup_fire_timer():
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_timer_timeout)
	add_child(fire_timer)

# الدالة الأساسية للإطلاق (ستقوم الكلاسات الأبناء بتغييرها إذا لزم الأمر)
func shoot():
	if can_shoot and current_ammo > 0:
		print("إطلاق نار من: ", weapon_name)
		current_ammo -= 1
		can_shoot = false
		
		# هنا تضع كود إخراج الـ Sprite أو الطلقة الخاصة بلعبة المنظور العلوي
		
		spawn_bullet()
		fire_timer.start()
		
	elif current_ammo <= 0:
		reload()

func spawn_bullet():
	# كود إنشاء الطلقة (Instantiate) الأساسي
	pass

func reload():
	print("current ammo : "+str(current_ammo))
	print("reserve ammo : "+ str(current_reserve_ammo))
	
	if current_ammo == max_ammo or current_reserve_ammo == 0 or is_reloading or is_shooting:
		if current_ammo == max_ammo or is_reloading or is_shooting:
			print("cant reload cuz its full or im shooting")
		elif current_reserve_ammo == 0:
			print("i dont have reserve ammo")
	# يسوي تشييك اذا كل اسباب التعشيق موجوده
	elif current_ammo < max_ammo and current_reserve_ammo > 0 and is_reloading == false:
		# يشوف اذا المخزون الاحتياطي للفشق اكبر من الذخيره يفلل الذخيره
		if current_reserve_ammo > max_ammo:
			current_reserve_ammo -= max_ammo
			current_ammo = max_ammo
			
		#واذا المخزون الاحتياطي ما ياكل عيش وباقي شوي بس يحط الباقي بالسلاح
		elif current_reserve_ammo < max_ammo:
			#                 8       -        4           =  4
			current_ammo += max_ammo - current_reserve_ammo
		elif current_reserve_ammo == max_ammo:
			current_ammo = max_ammo
			current_reserve_ammo = 0
			
		print("reloading !!!")
		can_shoot = false
		print("i finished reloading !")
		can_shoot = true
		
func _on_timer_timeout():
	
	can_shoot = true
	is_shooting = false
