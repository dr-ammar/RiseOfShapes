extends CharacterBody2D

# --- إعدادات الحركة (Movement Settings) ---
const SPEED = 100.0
var is_running := false

# --- مراجع العقد (Node References) ---
@onready var weapon_holder = $WeaponHolder
@onready var character_sprite = $characterSprite
@onready var animation_player = $characterSprite/AnimationPlayer

# --- نظام الأسلحة (Weapon System) ---
var pistol_scene = preload("res://scenes/weapons/pistol.tscn")
var weapons_inventory : Array = [] 
var current_weapon_index : int = 0
var max_weapons : int = 2

# --- إحصائيات اللاعب (Player Stats) ---
var points: int = 500:
	set(value):
		points = value
		points_changed.emit(points)

var health: int = 50:
	set(value):
		health = value
		health_changed.emit(health)

# --- الإشارات (Signals) ---
signal points_changed(new_points)
signal health_changed(new_health)
signal weapon_switched(weapon)

# --- الدوال الأساسية (Lifecycle) ---

func _ready() -> void:
	add_to_group("player")
	# إعطاء اللاعب مسدس عند البداية
	pickup_weapon(pistol_scene)

func _physics_process(_delta):
	camera_movement()
	aim_weapon()
	move_and_slide()

# --- التصويب والحركة (Aiming & Movement) ---

func aim_weapon():
	var target_pos
	# تحديد موقع الهدف بناءً على وضع اللعب (ماوس أو يد تحكم)
	if Global.gamepad_mode == false and Global.mobile_mode == false:
		target_pos = get_global_mouse_position()
	elif Global.gamepad_mode == true and Global.mobile_mode == false:
		target_pos = $gamepad_crosshair.crosshair.global_position
	else:
		return
		
	# تحديد اتجاه النظر
	var looking_left = target_pos.x < global_position.x
	
	# تحديث مكان حامل السلاح قبل التدوير لتجنب الاهتزاز
	weapon_holder.position.x = -5 if looking_left else 5
	weapon_holder.look_at(target_pos)
	
	# قلب صور الشخصية بناءً على اتجاه الماوس
	$characterSprite/Head.flip_h = looking_left
	$characterSprite/left_foot.flip_h = looking_left
	$characterSprite/right_foot.flip_h = looking_left
	
	# قلب السلاح عمودياً عند النظر لليسار ليبقى وضعه طبيعياً
	var rot = wrapf(weapon_holder.rotation_degrees, 0, 360)
	if rot > 90 and rot < 270:
		weapon_holder.scale.y = -1
	else:
		weapon_holder.scale.y = 1

func camera_movement():
	# تحريك الكاميرا بشكل طفيف مع الماوس لزيادة مدى الرؤية
	var target = get_global_mouse_position()
	if Global.gamepad_mode:
		target = $gamepad_crosshair.crosshair.global_position
		
	$Camera2D.offset.x = (target.x - global_position.x) / (160.0 / 2.0)
	$Camera2D.offset.y = (target.y - global_position.y) / (90.0 / 2.0)

# --- المدخلات (Input Handling) ---

func _input(event):
	# معالجة اتجاه الحركة
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir.normalized() * SPEED
		
	# اختيار الأنيميشن المناسب
	if input_dir == Vector2.ZERO:
		animation_player.play("idle")
	else:
		animation_player.play("run")
	
	# تبديل السلاح
	if event.is_action_pressed("switch_weapon") and weapons_inventory.size() > 1:
		toggle_weapon()
		
	# إطلاق النار
	if event.is_action_pressed("shoot") and weapons_inventory.size() > 0:
		weapons_inventory[current_weapon_index].shoot()
		
	# التعشيق
	if event.is_action_pressed("reload") and weapons_inventory.size() > 0:
		weapons_inventory[current_weapon_index].reload()

# --- إدارة الأسلحة (Inventory Management) ---

func toggle_weapon():
	current_weapon_index = (current_weapon_index + 1) % weapons_inventory.size()
	equip_weapon(weapons_inventory[current_weapon_index])

func pickup_weapon(weapon_packed_scene: PackedScene):
	var new_weapon_instance = weapon_packed_scene.instantiate()
	
	if weapons_inventory.size() < max_weapons:
		weapons_inventory.append(new_weapon_instance)
		weapon_holder.add_child(new_weapon_instance)
		current_weapon_index = weapons_inventory.size() - 1
	else:
		# استبدال السلاح الحالي إذا كانت الحقيبة ممتلئة
		var old_weapon = weapons_inventory[current_weapon_index]
		old_weapon.queue_free()
		weapons_inventory[current_weapon_index] = new_weapon_instance
		weapon_holder.add_child(new_weapon_instance)

	equip_weapon(new_weapon_instance)

func equip_weapon(weapon):
	# إخفاء جميع الأسلحة أولاً
	for w in weapons_inventory:
		if is_instance_valid(w):
			w.hide()
			
	# إظهار السلاح المطلوب
	if is_instance_valid(weapon):
		weapon.show()
		weapon_switched.emit(weapon)

# --- الصحة والموت (Health & Death) ---

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	print("مات اللاعب!")
	Global.reset_game()
	get_tree().reload_current_scene()
