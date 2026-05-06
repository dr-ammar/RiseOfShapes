extends CharacterBody2D
class_name Zombie


# --- إحصائيات الزومبي ---
var health: int = 30
var speed: float = 30.0
var damage: int = 10

# --- منطق الهجوم والتأثيرات ---
var attack_cooldown: float = 0.6
var attack_timer: float = 0.0
var knockback: Vector2 = Vector2.ZERO # لتأثير الارتداد

# -- Power Up Settings
const MAX_POWER_UPS_PER_ROUND := 5
static var powers_showed := 0

# --- مراجع العقد ---
var player: Node2D = null
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@onready var sprite = $Sprite2D
@onready var hitbox = $Hitbox
@onready var power_up_scene_packed = preload("res://scenes/power_up.tscn")

func _ready():
	add_to_group("enemy")
	if has_node("Hitbox"):
		$Hitbox.add_to_group("enemy_hitbox")
	
	# إعدادات الملاحة لتجنب الالتصاق بالزوايا
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	nav_agent.path_max_distance = 100.0
	
	# البحث عن اللاعب
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta : float) -> void:
	if player and is_instance_valid(player):
		var next_path_pos = nav_agent.get_next_path_position()
		var direction = global_position.direction_to(next_path_pos)
		
		# Steering with Soft Separation (تجنب الالتصاق بالزومبي الآخرين)
		var target_velocity = direction * speed
		
		# إضافة قوة تباعد بسيطة لمنع التداخل والاهتزاز (Separation Force)
		var separation = Vector2.ZERO
		for neighbor in get_tree().get_nodes_in_group("enemy"):
			if neighbor != self:
				var dist = global_position.distance_to(neighbor.global_position)
				if dist < 15.0: # مسافة التباعد
					separation += neighbor.global_position.direction_to(global_position) * (15.0 - dist) * 2.0
		
		target_velocity += separation
		
		# تحريك سلس مع منع الاهتزاز عند الاصطدام
		velocity = velocity.lerp(target_velocity, 10.0 * _delta)
		
		# إضافة تأثير الارتداد للسرعة
		if knockback != Vector2.ZERO:
			velocity += knockback
			# تقليل قوة الارتداد تدريجياً ليعود لسرعته الطبيعية
			knockback = knockback.lerp(Vector2.ZERO, 30.0 * _delta) # Improved friction
			if knockback.length() < 5: # Lower threshold to stop
				knockback = Vector2.ZERO
		
		# قلب الصورة لتنظر للاعب (بناءً على الحركة الفعلية)
		if velocity.x < -1:
			sprite.flip_h = true
		elif velocity.x > 1:
			sprite.flip_h = false
			
		move_and_slide()
		
		# معالجة القتال (الضرب)
		handle_damage(_delta)

func make_path() -> void:
	nav_agent.target_position = player.global_position






# --- نظام القتال والموت (المرحلة 3) ---

func handle_damage(delta):
	if attack_timer > 0:
		attack_timer -= delta
	else:
		# التحقق من وجود اللاعب داخل منطقة التصادم (Hitbox)
		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("player"):
				if body.has_method("take_damage"):
					body.take_damage(damage)
					attack_timer = attack_cooldown
					break

func take_damage(amount: int, force: float = 300.0):
	if amount <= 0: return # Ignore non-damaging collisions
	
	health -= amount
	
	# تفعيل الارتداد للوراء عكس اتجاه اللاعب بقوة متغيرة حسب السلاح
	if player and is_instance_valid(player):
		var push_dir = player.global_position.direction_to(global_position)
		knockback = push_dir * force
	
	# تأثير وميض أحمر عند تلقي الضرر
	if is_instance_valid(sprite):
		sprite.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.1).timeout
		if is_instance_valid(sprite):
			sprite.modulate = Color(1, 1, 1)
		
	if health <= 0 or GameManager.is_insta_kill:
		die()

func die():
	# إعطاء نقاط للاعب عند موت الزومبي
	if player and is_instance_valid(player):
		var points_to_give = 100
		if GameManager.is_double_points:
			points_to_give *= 2
		player.points += points_to_give
		
	# احتمالية إسقاط Power-Up
	check_for_power_up_drop()
	
	GameManager.total_kills += 1
	queue_free()

func check_for_power_up_drop():
	# Only drop if we haven't reached the per-round limit
	if powers_showed >= MAX_POWER_UPS_PER_ROUND:
		return
		
	# 5% chance to drop
	if randf() <= 0.2:
		var power_up = power_up_scene_packed.instantiate()
		power_up.global_position = global_position
		get_tree().root.add_child(power_up)
		powers_showed += 1

func _on_hitbox_body_entered(_body):
	# لتفادي الأخطاء بسبب الإشارة المربوطة مسبقاً
	pass


func _on_timer_timeout() -> void:
	# timer path
	make_path()
	
# PowerUp logic is now handled in die() and power_up.gd
