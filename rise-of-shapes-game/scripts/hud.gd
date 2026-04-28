extends Control

@onready var ammo_label = $MarginContainer/BottomRight/VBoxContainer/AmmoLabel
@onready var weapon_label = $MarginContainer/BottomRight/VBoxContainer/WeaponLabel
@onready var points_label = $MarginContainer/BottomLeft/PointsLabel
@onready var health_bar = $MarginContainer/TopLeft/HealthBar

var current_weapon: WeaponBase

func _ready():
	# Wait for the player to be ready
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		setup_player(player)

func setup_player(player):
	if not player.points_changed.is_connected(_on_points_changed):
		player.points_changed.connect(_on_points_changed)
	if not player.health_changed.is_connected(_on_health_changed):
		player.health_changed.connect(_on_health_changed)
	if not player.weapon_switched.is_connected(_on_weapon_switched):
		player.weapon_switched.connect(_on_weapon_switched)
	
	# Initial values
	health_bar.max_value = player.health
	_on_points_changed(player.points)
	_on_health_changed(player.health)
	if player.weapons_inventory.size() > 0:
		_on_weapon_switched(player.weapons_inventory[player.current_weapon_index])

func _on_points_changed(new_points):
	points_label.text = "$ " + str(new_points)

func _on_health_changed(new_health):
	health_bar.value = new_health

func _on_weapon_switched(weapon):
	if current_weapon:
		if current_weapon.ammo_changed.is_connected(_on_ammo_changed):
			current_weapon.ammo_changed.disconnect(_on_ammo_changed)
	
	current_weapon = weapon
	weapon_label.text = weapon.weapon_name
	current_weapon.ammo_changed.connect(_on_ammo_changed)
	_on_ammo_changed(current_weapon.current_ammo, current_weapon.current_reserve_ammo)

func _on_ammo_changed(current, reserve):
	ammo_label.text = str(current) + " / " + str(reserve)
