extends Control

# --- مراجع العقد (UI References) ---
@onready var ammo_label = $MarginContainer/BottomRight/VBoxContainer/AmmoLabel
@onready var weapon_label = $MarginContainer/BottomRight/VBoxContainer/WeaponLabel
@onready var points_label = $MarginContainer/BottomLeft/PointsLabel
@onready var round_label = $MarginContainer/BottomLeft/RoundLabel
@onready var health_bar = $MarginContainer/TopLeft/HealthBar

# --- متغيرات الحالة ---
var current_weapon: WeaponBase

# --- الدوال الأساسية (Lifecycle) ---

func _ready():
	# انتظار جاهزية اللاعب في المشهد
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		setup_player(player)

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
