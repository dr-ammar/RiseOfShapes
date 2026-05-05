extends CharacterBody2D

# --- إعدادات الحركة (Movement Settings) ---
const SPEED = 100.0
var is_running := false
var is_dead := false

# --- مراجع العقد (Node References) ---
@onready var weapon_holder = $WeaponHolder
@onready var character_sprite = $characterSprite
@onready var animation_player = $characterSprite/AnimationPlayer

# --- نظام الأسلحة (Weapon System) ---
var pistol_scene = preload("res://scenes/weapons/pistol.tscn")
var weapons_inventory : Array = [] 
var current_weapon_index : int = 0
var max_weapons : int = 4

# --- إحصائيات اللاعب (Player Stats) ---
var points: int = 500:
	set(value):
		points = value
		points_changed.emit(points)

var health: int = 150:
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
	# إعطاء اللاعب المسدس فقط عند البدء
	pickup_weapon(pistol_scene)

func _physics_process(delta):
	if is_dead:
		return
	
	# معالجة اتجاه الحركة
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir.normalized() * SPEED
	
	# اختيار الأنيميشن المناسب
	if input_dir == Vector2.ZERO:
		animation_player.play("idle")
	else:
		animation_player.play("run")
	
	handle_crosshair_movement(delta)
	camera_movement()
	aim_weapon()
	handle_shooting()
	move_and_slide()

func handle_crosshair_movement(_delta):
	if GameManager.gamepad_mode or GameManager.mobile_mode:
		$gamepad_crosshair.visible = true
		var aim_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		
		# إذا كان اللاعب يحرك عصا التصويب، نقوم بتحديث مكان الكروس هير في دائرة حول اللاعب
		if aim_dir.length() > 0.1:
			$gamepad_crosshair.position = aim_dir.normalized() * 60.0 # مسافة ثابتة حول اللاعب
	else:
		$gamepad_crosshair.visible = false

# --- التصويب والحركة (Aiming & Movement) ---

func aim_weapon():
	var target_pos
	# تحديد موقع الهدف بناءً على وضع اللعب (ماوس أو يد تحكم)
	if GameManager.gamepad_mode == false and GameManager.mobile_mode == false:
		target_pos = get_global_mouse_position()
	else:
		target_pos = $gamepad_crosshair.global_position
		
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
	if GameManager.gamepad_mode or GameManager.mobile_mode:
		target = $gamepad_crosshair.global_position
		
	$Camera2D.offset.x = (target.x - global_position.x) / (160.0 / 2.0)
	$Camera2D.offset.y = (target.y - global_position.y) / (90.0 / 2.0)

# --- المدخلات (Input Handling) ---

func _input(event):
	if is_dead:
		return
	
	# تبديل السلاح
	if event.is_action_pressed("switch_weapon") and weapons_inventory.size() > 1:
		toggle_weapon()
		
	# التعشيق
	if event.is_action_pressed("reload") and weapons_inventory.size() > 0:
		weapons_inventory[current_weapon_index].reload()

# --- إدارة الأسلحة (Inventory Management) ---

func handle_shooting():
	if weapons_inventory.size() > 0:
		var current_weapon = weapons_inventory[current_weapon_index]
		
		# تحديد الأكشن المناسب بناءً على وضع اللعب
		var shoot_action = "shoot"
		if GameManager.mobile_mode:
			shoot_action = "trigger_shoot"
			
		var shooting_pressed = Input.is_action_pressed(shoot_action)
		
		if current_weapon.is_automatic:
			if shooting_pressed:
				current_weapon.shoot()
		else:
			var shooting_just_pressed = Input.is_action_just_pressed(shoot_action)
			if shooting_just_pressed:
				current_weapon.shoot()

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
	if is_dead:
		return
	is_dead = true
	print("مات اللاعب!")
	
	# إخفاء السلاح عند الموت
	weapon_holder.hide()
	
	# استدعاء شاشة النهاية من الـ HUD
	get_tree().call_group("hud", "show_game_over", GameManager.current_round, GameManager.total_kills, points)

func show_hud_message(message: String, duration: float = 2.0):
	get_tree().call_group("hud", "show_hud_message", message, duration)
