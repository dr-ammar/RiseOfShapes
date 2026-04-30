extends Node

# --- أوضاع التحكم ---
var gamepad_mode = false
var mobile_mode = false

# --- نظام الجولات (COD Zombies Style) ---
var current_round: int = 1
var zombies_to_spawn: int = 0
var zombies_spawned_so_far: int = 0
var total_kills: int = 0
var is_round_active: bool = false

signal round_changed(new_round)

var round_sound = preload("res://audio/round-change-sound-effect.mp3")
@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var round_delay_timer: Timer = Timer.new()

func _ready():
	add_child(sfx_player)
	add_child(round_delay_timer)
	
	round_delay_timer.one_shot = true
	round_delay_timer.timeout.connect(start_new_round)

func start_game():
	print("بدأ اللعب!")
	reset_game()
	# بدء الجولة الأولى بعد 3 ثوانٍ
	round_delay_timer.start(3.0)

func _process(_delta):
	if is_round_active:
		# التحقق من انتهاء الجولة (تم إخراج كل الزومبي وموتهم جميعاً)
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
		
	round_changed.emit(current_round)
	
	# تشغيل صوت الجولة
	sfx_player.stream = round_sound
	sfx_player.play()
	
	# انتظار انتهاء الصوت قبل بدء التوليد (السباون)
	await sfx_player.finished
	
	if is_round_active:
		# تفعيل مولدات الزومبي (Spawners)
		print("تفعيل السباونرز...")
		get_tree().call_group("spawner", "start_spawning")
		print("بدأت الجولة: ", current_round, " | الأعداء: ", zombies_to_spawn)

func end_round():
	is_round_active = false
	current_round += 1
	
	# إيقاف مولدات الزومبي
	get_tree().call_group("spawner", "stop_spawning")
	
	# انتظار وقت قصير جداً لبدء الصوت فوراً (Immediate sound effect)
	round_delay_timer.start(0.1)
	print("انتهت الجولة! استعد للجولة التالية...")

func notify_zombie_spawned():
	zombies_spawned_so_far += 1
	if zombies_spawned_so_far >= zombies_to_spawn:
		get_tree().call_group("spawner", "stop_spawning")

func reset_game():
	current_round = 1
	zombies_to_spawn = 0
	zombies_spawned_so_far = 0
	total_kills = 0
	is_round_active = false
	round_delay_timer.stop()
	round_delay_timer.start(3.0)
