extends Area2D

# --- الإعدادات (Settings) ---
@export var speed: float = 300.0
@export var damage: int
var knockback_force: float = 0.0
var max_range: float = 1000.0
var traveled_distance: float = 0.0

# --- المعالجة (Processing) ---

func _physics_process(delta):
	# التحرك للأمام بناءً على زاوية التدوير
	var step = speed * delta
	position += Vector2.RIGHT.rotated(rotation) * step
	
	# حساب المسافة المقطوعة وحذف الرصاصة إذا تجاوزت المدى
	traveled_distance += step
	if traveled_distance >= max_range:
		queue_free()

# --- معالجة التصادم (Collision Handling) ---

func _on_body_entered(body):
	# إذا اصطدمت الرصاصة بالعدو
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage, knockback_force)
		queue_free() # حذف الرصاصة
	
	# إذا اصطدمت الرصاصة بالجدار (أي شيء ليس اللاعب أو العدو)
	elif not body.is_in_group("player"):
		queue_free() # حذف الرصاصة عند لمس الجدار

# --- التخلص من الرصاصة تلقائياً ---

func _on_timer_timeout():
	# حذف الرصاصة بعد فترة زمنية لتجنب تراكمها في الذاكرة
	queue_free()
