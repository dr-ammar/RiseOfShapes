extends Node2D
class_name WeaponBase # هذا السطر مهم جداً! هو ما يسمح للأسلحة الأخرى بوراثة هذا الكلاس

@export var bullet_scene: PackedScene

# المتغيرات المشتركة لكل الأسلحة
var weapon_name: String = "Default Weapon"
var damage: int
var fire_rate: float # الوقت بين كل طلقة والأخرى
# Ammo Specs
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

signal ammo_changed(current, reserve)

#Reloading Settings
var is_reloading := false

# Shoting Settings
var is_shotgun: bool = false
var can_shoot: bool = true
var is_shooting := false
var fire_timer: Timer
@onready var weapon_sprite: AnimatedSprite2D = $WeaponSprite
@onready var sfx_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

func _ready():
	add_child(sfx_player)
	current_ammo = max_ammo
	setup_fire_timer()

# تجهيز مؤقت إطلاق النار للتحكم بسرعة الطلقات
func setup_fire_timer():
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_timer_timeout)
	add_child(fire_timer)

# الدالة الأساسية للإطلاق (ستقوم الكلاسات الأبناء بتغييرها إذا لزم الأمر)
func shoot():
	if can_shoot and current_ammo > 0:
		print("إطلاق نار من: ", weapon_name)
		current_ammo -= 1
		can_shoot = false
		
		# هنا تضع كود إخراج الـ Sprite أو الطلقة الخاصة بلعبة المنظور العلوي
		
		spawn_bullet()
		fire_timer.start()
		
	elif current_ammo <= 0:
		reload()

func spawn_bullet():
	if bullet_scene:
		var bullet = bullet_scene.instantiate()
		bullet.damage = damage
		
		# Get muzzle position if available, otherwise use weapon position
		if has_node("Muzzle"):
			bullet.global_position = get_node("Muzzle").global_position
		else:
			bullet.global_position = global_position
			
		# Set rotation based on global rotation
		bullet.rotation = global_rotation
		
		# Add bullet to the main scene tree (not as a child of the weapon)
		get_tree().root.add_child(bullet)

func reload():
	# Prevent reload if already reloading, firing, or if the shooting animation is still playing
	if is_reloading or is_shooting:
		return
	if weapon_sprite and weapon_sprite.is_playing() and weapon_sprite.animation == "shooting":
		return
		
	if current_ammo == max_ammo or current_reserve_ammo == 0:
		return
		
	print("reloading !!!")
	is_reloading = true
	can_shoot = false
	
	play_reload_anim()
	
	# Wait for animation if available
	if weapon_sprite and weapon_sprite.sprite_frames.has_animation("reloading"):
		await weapon_sprite.animation_finished
	
	var ammo_needed = max_ammo - current_ammo
	var ammo_to_add = min(ammo_needed, current_reserve_ammo)
	
	current_ammo += ammo_to_add
	current_reserve_ammo -= ammo_to_add
	
	print("i finished reloading !")
	is_reloading = false
	can_shoot = true
		
func _on_timer_timeout():
	can_shoot = true
	is_shooting = false

func play_shoot_anim():
	if weapon_sprite and weapon_sprite.sprite_frames.has_animation("shooting"):
		weapon_sprite.play("shooting")

func play_reload_anim():
	if weapon_sprite and weapon_sprite.sprite_frames.has_animation("reloading"):
		weapon_sprite.play("reloading")
		if weapon_sprite.get_parent().name == "Pistol":
			weapon_sprite.position = Vector2(-2.6,2.8)
			await weapon_sprite.animation_finished
			weapon_sprite.play("nothing")
			weapon_sprite.position = Vector2(7,-2)

func play_shoot_sfx(stream: AudioStream):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.play()

func play_reload_sfx(stream: AudioStream):
	if sfx_player and stream:
		sfx_player.stream = stream
		sfx_player.play()
			
