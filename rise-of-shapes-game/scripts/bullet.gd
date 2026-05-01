extends Area2D

# --- الإعدادات (Settings) ---
@export var speed: float = 300.0
@export var damage: int
var knockback_force: float = 0.0
var max_range: float = 1000.0
var traveled_distance: float = 0.0

# --- المعالجة (Processing) ---

func _ready():
	add_to_group("bullet")
	# ربط إشارة دخول منطقة (Area) للكشف عن الـ Hitbox
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

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
	# الرصاصة الآن تتجاهل جسم الزومبي (العدو) في body_entered 
	# لأننا نستخدم area_entered للكشف عن الـ Hitbox
	if body.is_in_group("enemy"):
		return
		
	# إذا اصطدمت الرصاصة بالجدار (أي شيء ليس اللاعب)
	if not body.is_in_group("player"):
		queue_free() # حذف الرصاصة عند لمس الجدار

func _on_area_entered(area):
	# الكشف عن إصابة الزومبي من خلال الـ Hitbox الخاص به
	if area.is_in_group("enemy_hitbox"):
		var zombie = area.get_parent()
		if zombie.has_method("take_damage"):
			zombie.take_damage(damage, knockback_force)
		queue_free()

# --- التخلص من الرصاصة تلقائياً ---

func _on_timer_timeout():
	# حذف الرصاصة بعد فترة زمنية لتجنب تراكمها في الذاكرة
	queue_free()
