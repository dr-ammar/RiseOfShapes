extends CharacterBody2D

# --- إحصائيات الزومبي ---
var health: int = 30
var speed: float = 30.0
var damage: int = 10

# --- منطق الهجوم والتأثيرات ---
var attack_cooldown: float = 0.6
var attack_timer: float = 0.0
var knockback: Vector2 = Vector2.ZERO # لتأثير الارتداد

# --- مراجع العقد ---
var player: Node2D = null
@onready var sprite = $Sprite2D
@onready var hitbox = $Hitbox

func _ready():
	add_to_group("enemy")
	
	# البحث عن اللاعب
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player and is_instance_valid(player):
		# نظام الحركة الغبي الأساسي
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * speed
		
		# إضافة تأثير الارتداد للسرعة
		if knockback != Vector2.ZERO:
			velocity += knockback
			# تقليل قوة الارتداد تدريجياً ليعود لسرعته الطبيعية
			knockback = knockback.lerp(Vector2.ZERO, 10 * delta)
			if knockback.length() < 10:
				knockback = Vector2.ZERO
		
		# قلب الصورة لتنظر للاعب
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
			
		move_and_slide()
		
		# معالجة القتال (الضرب)
		handle_damage(delta)

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
	health -= amount
	
	# تفعيل الارتداد للوراء عكس اتجاه اللاعب بقوة متغيرة حسب السلاح
	if player and is_instance_valid(player):
		var push_dir = player.global_position.direction_to(global_position)
		knockback = push_dir * force
	
	# تأثير وميض أحمر عند تلقي الضرر
	sprite.modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(sprite):
		sprite.modulate = Color(1, 1, 1)
		
	if health <= 0:
		die()

func die():
	# إعطاء نقاط للاعب عند موت الزومبي
	if player and is_instance_valid(player):
		player.points += 100
	queue_free()

func _on_hitbox_body_entered(_body):
	# لتفادي الأخطاء بسبب الإشارة المربوطة مسبقاً
	pass
