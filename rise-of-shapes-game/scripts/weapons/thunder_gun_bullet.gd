extends Area2D

# --- الإعدادات (Settings) ---
@export var speed: float = 300.0
@export var damage: int = 1000 # دمج عالي جداً
var knockback_force: float = 800.0 # ارتداد قوي جداً
var max_range: float = 400.0
var traveled_distance: float = 0.0

# --- المعالجة (Processing) ---

func _ready():
	add_to_group("bullet")
	# تكبير الرصاصة وتلاشيها تدريجياً منذ لحظة الإطلاق
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.5,0.5), 0.5)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	# حذف الرصاصة بعد انتهاء التأثير
	tween.set_parallel(false)
	tween.tween_callback(queue_free)

func _physics_process(delta):
	# التحرك للأمام بناءً على زاوية التدوير
	var step = speed * delta
	position += Vector2.RIGHT.rotated(rotation) * step
	
	# حساب المسافة المقطوعة (لحالات أخرى إذا لزم الأمر)
	traveled_distance += step
	if traveled_distance >= max_range:
		set_physics_process(false)

# --- معالجة التصادم (Collision Handling) ---

func _on_body_entered(body):
	# إذا اصطدمت الرصاصة بالعدو
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage, self, knockback_force)
		# الرصاصة تخترق كل شيء ولا تختفي عند لمس الجدران

func _on_timer_timeout():
	queue_free()
