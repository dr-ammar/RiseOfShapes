extends Node

# --- إعدادات نظام الجولات (COD Style) ---
var current_round: int = 1
var zombies_to_spawn: int = 0
var zombies_spawned_so_far: int = 0
var is_round_active: bool = false

# --- مراجع وموارد ---
var round_sound = preload("res://audio/round-change-sound-effect.mp3")
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var round_delay_timer: Timer = Timer.new()

# --- الدوال الأساسية ---

func _ready():
	add_child(sfx_player)
	add_child(round_delay_timer)
	
	round_delay_timer.one_shot = true
	round_delay_timer.timeout.connect(start_new_round)
	
	# بدء الجولة الأولى بعد 3 ثوانٍ
	round_delay_timer.start(3.0)

func _process(_delta):
	if is_round_active:
		# التحقق من انتهاء الجولة (تم سباون كل الزومبي وموتهم جميعاً)
		if zombies_spawned_so_far >= zombies_to_spawn:
			var alive_zombies = get_tree().get_nodes_in_group("enemy").size()
			if alive_zombies == 0:
				end_round()

func start_new_round():
	is_round_active = true
	zombies_spawned_so_far = 0
	
	# معادلة عدد الزومبي (تزداد مع كل جولة)
	zombies_to_spawn = 5 + (current_round * 2)
	if current_round > 5:
		zombies_to_spawn = 10 + (current_round * 3)
		
	# تحديث الحالة العالمية وإطلاق الإشارة
	Global.current_round = current_round
	Global.round_changed.emit(current_round)
	
	# تشغيل صوت بداية الجولة
	sfx_player.stream = round_sound
	sfx_player.play()
	
	# تفعيل السباونرز
	get_tree().call_group("spawner", "start_spawning")
	print("بدأت الجولة: ", current_round)

func end_round():
	is_round_active = false
	current_round += 1
	
	# إيقاف السباونرز
	get_tree().call_group("spawner", "stop_spawning")
	
	# انتظار 7 ثوانٍ قبل الجولة التالية (مثل COD)
	round_delay_timer.start(7.0)
	print("انتهت الجولة! الجولة التالية تبدأ قريباً...")

func notify_zombie_spawned():
	zombies_spawned_so_far += 1
	if zombies_spawned_so_far >= zombies_to_spawn:
		get_tree().call_group("spawner", "stop_spawning")
