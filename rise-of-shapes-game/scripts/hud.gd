extends Control

# --- مراجع العقد (UI References) ---
@onready var ammo_label = $MarginContainer/BottomRight/VBoxContainer/AmmoLabel
@onready var weapon_label = $MarginContainer/BottomRight/VBoxContainer/WeaponLabel
@onready var points_label = $MarginContainer/BottomLeft/PointsLabel
@onready var round_label = $MarginContainer/BottomLeft/RoundLabel
@onready var health_bar = $MarginContainer/TopLeft/HealthBar
@onready var interaction_label = $CenterContainer/InteractionLabel
@onready var game_over_overlay = $GameOverOverlay
@onready var final_round_label = $GameOverOverlay/CenterContainer/VBoxContainer/StatsContainer/FinalRoundLabel
@onready var final_kills_label = $GameOverOverlay/CenterContainer/VBoxContainer/StatsContainer/FinalKillsLabel
@onready var final_points_label = $GameOverOverlay/CenterContainer/VBoxContainer/StatsContainer/FinalPointsLabel
@onready var restart_button = $GameOverOverlay/CenterContainer/VBoxContainer/RestartButton

# --- متغيرات الحالة ---
var current_weapon: WeaponBase

# --- الدوال الأساسية (Lifecycle) ---

func _ready():
	add_to_group("hud")
	# انتظار جاهزية اللاعب في المشهد
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		setup_player(player)
	
	restart_button.pressed.connect(_on_restart_button_pressed)

func setup_player(player):
	# ربط إشارات اللاعب بالواجهة
	if not player.points_changed.is_connected(_on_points_changed):
		player.points_changed.connect(_on_points_changed)
	if not player.health_changed.is_connected(_on_health_changed):
		player.health_changed.connect(_on_health_changed)
	if not player.weapon_switched.is_connected(_on_weapon_switched):
		player.weapon_switched.connect(_on_weapon_switched)
	
	# ربط إشارة الجولة من النظام العالمي
	if not GameManager.round_changed.is_connected(_on_round_changed):
		GameManager.round_changed.connect(_on_round_changed)
	
	# تعيين القيم الأولية
	health_bar.max_value = player.health
	_on_points_changed(player.points)
	_on_health_changed(player.health)
	_on_round_changed(GameManager.current_round)
	
	if player.weapons_inventory.size() > 0:
		_on_weapon_switched(player.weapons_inventory[player.current_weapon_index])

# --- معالجة الإشارات (Signal Handlers) ---

func _on_points_changed(new_points):
	points_label.text = "$ " + str(new_points)

func _on_health_changed(new_health):
	health_bar.value = new_health

func _on_round_changed(new_round):
	round_label.text = str(new_round)

func _on_weapon_switched(weapon):
	# فصل إشارة الذخيرة عن السلاح القديم بأمان
	if is_instance_valid(current_weapon):
		if current_weapon.ammo_changed.is_connected(_on_ammo_changed):
			current_weapon.ammo_changed.disconnect(_on_ammo_changed)
	
	current_weapon = weapon
	if is_instance_valid(current_weapon):
		weapon_label.text = current_weapon.weapon_name
		
		# ربط إشارة الذخيرة بالسلاح الجديد
		if not current_weapon.ammo_changed.is_connected(_on_ammo_changed):
			current_weapon.ammo_changed.connect(_on_ammo_changed)
		
		# تحديث يدوي للقيم عند التبديل
		_on_ammo_changed(current_weapon.current_ammo, current_weapon.current_reserve_ammo)

func _on_ammo_changed(current, reserve):
	ammo_label.text = str(current) + " / " + str(reserve)

func set_interaction_message(message: String):
	interaction_label.text = message

func show_hud_message(message: String, duration: float = 2.0):
	# رسالة مؤقتة (مثل "نقاط غير كافية")
	interaction_label.text = message
	await get_tree().create_timer(duration).timeout
	# إذا لم تكن هناك رسالة تفاعل حالية، نمسح النص
	# (هذا بسيط جداً، قد يحتاج تحسين إذا تداخلت الرسائل)
	if interaction_label.text == message:
		interaction_label.text = ""

func show_game_over(round_reached: int, kills: int, points: int):
	final_round_label.text = "Round Reached: " + str(round_reached)
	final_kills_label.text = "Total Kills: " + str(kills)
	final_points_label.text = "Final Points: $ " + str(points)
	game_over_overlay.show()
	# السماح للماوس بالظهور إذا كان مخفياً
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_button_pressed():
	GameManager.reset_game()
	get_tree().reload_current_scene()

func _input(event):
	if game_over_overlay.visible:
		if event.is_action_pressed("reload"): # استخدام حرف R لإعادة التشغيل أيضاً
			_on_restart_button_pressed()
