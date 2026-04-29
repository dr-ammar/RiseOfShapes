extends Node2D

# --- الإعدادات ---
@export var zombie_scene: PackedScene
@export var spawn_interval: float = 5.0
var is_active: bool = false

# --- المكونات ---
@onready var timer: Timer = Timer.new()
var game_manager: Node = null

# --- الدوال الأساسية ---

func _ready():
	add_to_group("spawner")
	
	if not zombie_scene:
		zombie_scene = preload("res://scenes/zombie.tscn")
		
	add_child(timer)
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_timer_timeout)

# --- التحكم في السباونر (تستدعى من GameManager) ---

func start_spawning():
	is_active = true
	timer.start()

func stop_spawning():
	is_active = false
	timer.stop()

# --- منطق الإنشاء ---

func _on_timer_timeout():
	if not is_active: return
	spawn_zombie()

func spawn_zombie():
	if zombie_scene:
		var zombie = zombie_scene.instantiate()
		zombie.global_position = global_position
		
		# تعديل قوة الزومبي بناءً على الجولة الحالية
		var round = GameManager.current_round
		zombie.health = 20 + (round * 10)
		zombie.speed = min(30 + (round * 5), 65.0)
		
		get_tree().current_scene.add_child(zombie)
		
		# إبلاغ النظام بظهور زومبي جديد
		GameManager.notify_zombie_spawned()
