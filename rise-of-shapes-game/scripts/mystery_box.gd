extends StaticBody2D

# --- إعدادات الصندوق (Box Settings) ---
@export var cost: int = 950
@export var weapons_pool: Array[PackedScene] = []
@export var cycling_time: float = 4.0
@export var weapon_display_offset: Vector2 = Vector2(0, -20)

# --- مراجع العقد (Node References) ---
@onready var area_2d = $Area2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var weapon_display = $WeaponDisplay
@onready var cycle_timer = $CycleTimer

# --- حالة الصندوق (Box State) ---
var is_open: bool = false
var is_cycling: bool = false
var can_interact: bool = true
var selected_weapon_scene: PackedScene = null
var players_in_range: Array = []

func _ready():
	weapon_display.visible = false
	animated_sprite.play("closed")
	
	# إذا لم يتم تحديد أسلحة في المحرر، نضع بعض الأسلحة الافتراضية
	if weapons_pool.is_empty():
		weapons_pool.append(preload("res://scenes/weapons/pistol.tscn"))
		weapons_pool.append(preload("res://scenes/weapons/assault_rifle.tscn"))
		weapons_pool.append(preload("res://scenes/weapons/shotgun.tscn"))
		weapons_pool.append(preload("res://scenes/weapons/sniper_rifle.tscn"))
		weapons_pool.append(preload("res://scenes/weapons/raygun.tscn"))
		weapons_pool.append(preload("res://scenes/weapons/thunder_gun.tscn"))

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		for player in players_in_range:
			handle_interaction(player)

func handle_interaction(player):
	if not can_interact:
		return

	if not is_open:
		# محاولة فتح الصندوق
		if player.points >= cost:
			player.points -= cost
			open_box()
		else:
			# تحديث الـ HUD برسالة "نقاط غير كافية"
			if player.has_method("show_hud_message"):
				player.show_hud_message("Not enough points! (950 needed)")
	else:
		# محاولة أخذ السلاح
		if selected_weapon_scene and not is_cycling:
			player.pickup_weapon(selected_weapon_scene)
			close_box()

func open_box():
	is_open = true
	is_cycling = true
	can_interact = false # لا يمكن التفاعل أثناء الدوران
	animated_sprite.play("opening")
	
	# بدء دوران الأسلحة
	start_weapon_cycling()
	
	# تحديث الـ HUD لجميع اللاعبين في المدى
	for p in players_in_range:
		update_player_hud(p, true)

func start_weapon_cycling():
	weapon_display.visible = true
	var cycle_count = 20
	var interval = cycling_time / cycle_count
	
	for i in range(cycle_count):
		var random_weapon = weapons_pool.pick_random()
		# نحتاج إلى طريقة لعرض شكل السلاح بدون عمل Instantiate كامل له إذا أمكن
		# لكن للتبسيط حالياً، سنقوم بعمل Instantiate مؤقت أو نستخدم مرجع للصورة
		update_weapon_display(random_weapon)
		await get_tree().create_timer(interval).timeout
	
	# اختيار السلاح النهائي
	selected_weapon_scene = weapons_pool.pick_random()
	update_weapon_display(selected_weapon_scene)
	
	is_cycling = false
	can_interact = true # الآن يمكن للاعب أخذ السلاح
	
	# تحديث الـ HUD لجميع اللاعبين في المدى
	for p in players_in_range:
		update_player_hud(p, true)
	
	# إذا لم يأخذه اللاعب بعد 10 ثوانٍ، يختفي
	await get_tree().create_timer(10.0).timeout
	if is_open and not is_cycling:
		close_box()

func update_weapon_display(weapon_scene: PackedScene):
	# هذه الدالة تقوم بتحديث شكل السلاح المعروض فوق الصندوق
	# للتبسيط، سنقوم بعمل instantiate مؤقت ونأخذ منه الصورة
	var temp_weapon = weapon_scene.instantiate()
	if temp_weapon.has_node("WeaponSprite"):
		var sprite = temp_weapon.get_node("WeaponSprite")
		if sprite is AnimatedSprite2D:
			var frames = sprite.sprite_frames
			var anim_name = "default"
			if not frames.has_animation(anim_name):
				# fallback to first available animation
				anim_name = frames.get_animation_names()[0]
			
			var texture = frames.get_frame_texture(anim_name, 0)
			weapon_display.texture = texture
	temp_weapon.queue_free()

func close_box():
	is_open = false
	can_interact = true
	selected_weapon_scene = null
	weapon_display.visible = false
	animated_sprite.play("closed")
	
	# تحديث الـ HUD لجميع اللاعبين في المدى ليظهر "Press E for Mystery Box" مرة أخرى
	for p in players_in_range:
		update_player_hud(p, true)

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		players_in_range.append(body)
		# إظهار رسالة التفاعل في الـ HUD
		update_player_hud(body, true)

func _on_area_2d_body_exited(body):
	if body.is_in_group("player"):
		players_in_range.erase(body)
		# إخفاء رسالة التفاعل في الـ HUD
		update_player_hud(body, false)

func update_player_hud(_player, show_message: bool):
	# سنفترض وجود دالة في اللاعب أو الـ HUD للتعامل مع هذا
	var message = ""
	if show_message:
		if not is_open:
			message = "Press E for Mystery Box [950]"
		elif is_cycling:
			message = "Cycling..."
		elif selected_weapon_scene:
			message = "Press E to take weapon"
	
	# الوصول للـ HUD (غالباً يكون Global أو ابن للاعب)
	get_tree().call_group("hud", "set_interaction_message", message)
