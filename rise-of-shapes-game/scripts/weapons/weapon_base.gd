extends Node2D
class_name WeaponBase

# --- التصدير (Export Variables) ---
@export var bullet_scene: PackedScene

# --- خصائص السلاح الأساسية ---
var weapon_name: String = "Default Weapon"
var damage: int
var knockback_force: float = 300.0 # قوة الارتداد الافتراضية
var max_range: float = 1000.0 # مدى السلاح الافتراضي بالبيكسل
var fire_rate: float # الوقت بين كل طلقة والأخرى
var is_shotgun: bool = false
var is_automatic: bool = false
var reload_time: float = 1.5 # الوقت اللازم للتعشيق بالثواني

# --- نظام الذخيرة ---
var max_ammo: int
var max_reserve_ammo: int
var current_ammo: int:
	set(value):
		current_ammo = value
		ammo_changed.emit(current_ammo, current_reserve_ammo)

var current_reserve_ammo: int:
	set(value):
		current_reserve_ammo = value
		ammo_changed.emit(current_ammo, current_reserve_ammo)

# --- الإشارات (Signals) ---
signal ammo_changed(current, reserve)

# --- حالات السلاح ---
var is_reloading := false
var is_shooting := false
var can_shoot: bool = true

# --- المكونات (Nodes) ---
var fire_timer: Timer
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite
@onready var sfx_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

# --- الدوال الأساسية (Lifecycle) ---

func _ready():
	# إضافة مشغل الصوت كابن للسلاح
	add_child(sfx_player)
	# تعبئة الذخيرة عند البدء
	current_ammo = max_ammo
	# إعداد مؤقت الإطلاق
	setup_fire_timer()

func setup_fire_timer():
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_timer_timeout)
	add_child(fire_timer)

# --- منطق الإطلاق (Shooting Logic) ---

func shoot():
	# التحقق من شروط الإطلاق
	if can_shoot and current_ammo > 0 and not is_reloading and not is_shooting:
		current_ammo -= 1
		can_shoot = false
		is_shooting = true
		
		spawn_bullet(damage)
		play_shoot_anim()
		fire_timer.start()
		
	elif current_ammo <= 0:
		reload()

func spawn_bullet(damage):
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.damage = damage
		bullet.knockback_force = knockback_force
		bullet.max_range = max_range
		
		# تحديد مكان خروج الرصاصة
		if has_node("Muzzle"):
			bullet.global_position = get_node("Muzzle").global_position
		else:
			bullet.global_position = global_position
			
		bullet.rotation = global_rotation
		get_tree().root.add_child(bullet)

# --- منطق التعشيق (Reloading Logic) ---

func reload():
	# منع التعشيق إذا كان السلاح ممتلئاً أو جارٍ الإطلاق/التعشيق
	if is_reloading or is_shooting: return
	if weapon_sprite and weapon_sprite.is_playing() and weapon_sprite.animation == "shooting": return
	if current_ammo == max_ammo or current_reserve_ammo == 0: return
		
	print("بدء التعشيق...")
	is_reloading = true
	can_shoot = false
	
	play_reload_anim()
	
	# انتظار انتهاء وقت التعشيق
	await get_tree().create_timer(reload_time).timeout
	
	# حساب الذخيرة المطلوبة
	var ammo_needed = max_ammo - current_ammo
	var ammo_to_add = min(ammo_needed, current_reserve_ammo)
	
	current_ammo += ammo_to_add
	current_reserve_ammo -= ammo_to_add
	
	print("انتهى التعشيق!")
	is_reloading = false
	can_shoot = true

# --- الأنيميشن والصوت (Animations & SFX) ---

func _on_timer_timeout():
	can_shoot = true
	is_shooting = false

func play_shoot_anim():
	if weapon_sprite and weapon_sprite.sprite_frames.has_animation("shooting"):
		weapon_sprite.play("shooting")

func play_reload_anim():
	if weapon_sprite and weapon_sprite.sprite_frames.has_animation("reloading"):
		weapon_sprite.play("reloading")
		
		# تعديل مكان المسدس أثناء التعشيق (خاص بالبيستول)
		if weapon_sprite.get_parent().name == "Pistol":
			weapon_sprite.position = Vector2(-2.6, 2.8)
			# ننتظر قليلاً ثم نخفيه
			await get_tree().create_timer(reload_time * 0.8).timeout
			weapon_sprite.play("nothing") # إخفاء السلاح لحظياً
			weapon_sprite.position = Vector2(7, -2)

func play_shoot_sfx(stream: AudioStream, pitch: float = 1.0):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.pitch_scale = pitch
		sfx_player.play()

func play_reload_sfx(stream: AudioStream, pitch: float = 1.0):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.pitch_scale = pitch
		sfx_player.play()
