extends CharacterBody2D

# movement Settings
const SPEED = 100.0
var is_running := false

# جلبنا يد اللاعب من المشهد
@onready var weapon_holder = $WeaponHolder

# هنا نقوم بتحميل مشهد الفرد مسبقاً في الذاكرة (تأكد من مسار الملف لديك)
var pistol_scene = preload("res://scenes/weapons/pistol.tscn")

# المتغيرات الأساسية لنظام الأسلحة
var weapons_inventory : Array = [] 
var current_weapon_index : int = 0
var max_weapons : int = 2

#player cash money
var points: int = 500:
	set(value):
		points = value
		points_changed.emit(points)

var health: int = 100:
	set(value):
		health = value
		health_changed.emit(health)

signal points_changed(new_points)
signal health_changed(new_health)
signal weapon_switched(weapon)

func _ready() -> void:
	add_to_group("player")
	# الشرط 3: اللاعب يمتلك سلاح الفرد (Pistol) في البداية فقط
	pickup_weapon(pistol_scene)

func _physics_process(delta):
	camera_movement()
	move_and_slide()
	

# Camera smooth movement with mouse
func camera_movement():
	if Global.gamepad_mode == false and Global.mobile_mode == false:
		var mouse_pos = get_global_mouse_position()
		$Camera2D.offset.x = (mouse_pos.x - global_position.x) / (160.0 / 2.0)
		$Camera2D.offset.y = (mouse_pos.y - global_position.y) / (90.0 / 2.0)
	elif Global.gamepad_mode == true and Global.mobile_mode == false:
		var gamepad_mouse_pos = $gamepad_crosshair.crosshair.global_position
		$Camera2D.offset.x = (gamepad_mouse_pos.x - global_position.x) / (160.0 / 2.0)
		$Camera2D.offset.y = (gamepad_mouse_pos.y - global_position.y) / (90.0 / 2.0)

# نظام الاسلحه هون


func _input(event):
	# movement actions
	# Keyboard inputs
	var input_dir = Input.get_vector("move_left","move_right","move_up","move_down")
	velocity = input_dir.normalized() * SPEED
		
	if event.is_action_pressed("move_left"):
		$characterSprite/Head.flip_h = true
		$characterSprite/left_foot.flip_h = true
		$characterSprite/right_foot.flip_h = true
	elif event.is_action_pressed("move_right"):
		$characterSprite/Head.flip_h = false
		$characterSprite/left_foot.flip_h = false
		$characterSprite/right_foot.flip_h = false
		
	if input_dir == Vector2.ZERO:
		$characterSprite/AnimationPlayer.play("idle")
	else:
		$characterSprite/AnimationPlayer.play("run")
	
	
	
	# الشرط 1: التبديل بين السلاحين باستخدام زر التبديل
	# تأكد من إضافة "switch_weapon" في الـ Input Map وربطه بالزر 1
	
	if event.is_action_pressed("switch_weapon") and weapons_inventory.size() > 1:
		toggle_weapon()
		
	# زر إطلاق النار للتجربة (تأكد من إضافة "shoot" في الـ Input Map)
	if event.is_action_pressed("shoot") and weapons_inventory.size() > 0:
		var current_weapon = weapons_inventory[current_weapon_index]
		current_weapon.shoot() # نستدعي دالة الإطلاق للسلاح الممسوك حالياً
		
	# زر التعشيق (R)
	if event.is_action_pressed("reload") and weapons_inventory.size() > 0:
		var current_weapon = weapons_inventory[current_weapon_index]
		current_weapon.reload()
		
func toggle_weapon():
	# إخفاء السلاح الحالي
	weapons_inventory[current_weapon_index].hide()
	
	# تغيير المؤشر للسلاح الآخر
	current_weapon_index = (current_weapon_index + 1) % weapons_inventory.size()
	
	# إظهار السلاح الجديد
	equip_weapon(weapons_inventory[current_weapon_index])
	
# الدالة المحدثة للالتقاط والتبديل
func pickup_weapon(weapon_packed_scene: PackedScene):
	# 1. نصنع نسخة حقيقية من مشهد السلاح
	var new_weapon_instance = weapon_packed_scene.instantiate()
	
	if weapons_inventory.size() < max_weapons:
		# إذا كان معه سلاح واحد (أو لا شيء)، نضيفه للمصفوفة
		weapons_inventory.append(new_weapon_instance)
		
		# نضيف السلاح كابن لـ WeaponHolder في مشهد اللاعب
		weapon_holder.add_child(new_weapon_instance)
		
		# إذا كان لديه سلاح سابق، نخفيه
		if weapons_inventory.size() > 1:
			weapons_inventory[0].hide()
			current_weapon_index = weapons_inventory.size() - 1 
	else:
		# إذا كان معه سلاحين، نستبدل الحالي
		var old_weapon = weapons_inventory[current_weapon_index]
		
		# نحذف السلاح القديم من المشهد تماماً (نرميه)
		old_weapon.queue_free()
		
		# نضع السلاح الجديد في المصفوفة مكانه
		weapons_inventory[current_weapon_index] = new_weapon_instance
		weapon_holder.add_child(new_weapon_instance)

	# أخيراً، نظهر السلاح الجديد ونجعله جاهزاً
	equip_weapon(weapons_inventory[current_weapon_index])

func equip_weapon(weapon):
	# هنا تضع منطق إظهار السلاح (مثلاً تفعيل الـ Sprite الخاص به)
	# وتحديث خصائص الإطلاق (الضرر، سرعة الطلقة، إلخ)
	print("السلاح الحالي في يد اللاعب: ", weapon)
	weapon_switched.emit(weapon)

func drop_or_remove_weapon(weapon):
	# هنا تقوم بحذف السلاح القديم أو رميه على الأرض
	print("تم التخلص من: ", weapon)
