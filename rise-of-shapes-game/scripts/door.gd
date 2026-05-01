extends Area2D

# --- Door System (نظام الأبواب) ---
# Allows player to move between map parts with a black screen transition.

@export_group("Teleport Settings")
@export var target_marker: Marker2D # Where the player will appear
@export var destination_name: String = "Unknown Area"
@export var area_id: String = "Area 1" # ID used for spawners
@export var cost: int = 0

var player_in_area = null
var is_transitioning = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta):
	if player_in_area and not is_transitioning:
		if Input.is_action_just_pressed("interact"):
			try_open_door()

func try_open_door():
	if player_in_area.points >= cost:
		player_in_area.points -= cost
		start_transition()
	else:
		player_in_area.show_hud_message("Not enough points! Need " + str(cost))

func start_transition():
	if not target_marker or not player_in_area:
		print("Warning: Missing target marker or player for door!")
		return
		
	var player = player_in_area # Store reference in case player exits area during fade
	is_transitioning = true
	
	# Get HUD
	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		# 1. Fade out
		await hud.transition_to_black()
		
		# 2. Teleport & Change Area Logic
		player.global_position = target_marker.global_position
		GameManager.change_area(area_id)
		
		# Small wait for safety
		await get_tree().create_timer(0.2).timeout
		
		# 3. Fade in
		await hud.transition_from_black()
	else:
		# Fallback if no HUD found
		player.global_position = target_marker.global_position
		
	is_transitioning = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body
		var msg = "Press [F] to enter " + destination_name
		if cost > 0:
			msg += " (Cost: %d)" % cost
		body.show_hud_message(msg, 0) # 0 means persistent

func _on_body_exited(body):
	if body.is_in_group("player") and player_in_area == body:
		body.show_hud_message("") # Clear message
		player_in_area = null
