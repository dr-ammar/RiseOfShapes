extends CharacterBody2D

const SPEED = 100.0


func _ready() -> void:
	$gamepad_crosshair.visible = false
	

func _physics_process(delta):
	get_input()
	camera_movement()
	move_and_slide()


func get_input():
	# Keyboard inputs
	if Global.gamepad_mode == false and Global.mobile_mode == false :
		var input_dir = Input.get_vector("move_left","move_right","move_up","move_down")
		velocity = input_dir.normalized() * SPEED
	# Gamepad inputs	
	#elif GamePadMode == true :
	#	var input_dir = Input.get_vector("move_left_gamepad","move_right_gamepad","move_up_gamepad","move_down_gamepad")
	#	velocity = input_dir.normalized() * SPEED
	# mobile joystick
	#elif GamePadMode == false and MobileMode == true:
	#	var input_dir = Input.get_vector("move_left","move_right","move_up","move_down")
	#	velocity = input_dir.normalized() * SPEED
	
	# Mouse and gamepad triggers Clicks
	#if Input.get_action_strength("shoot") and map.player_deads == false and MobileMod == false:
	#	get_node("gun_" + str(gun_handled)).shoot.emit()

# Camera smooth movement with mouse
func camera_movement():
	if Global.gamepad_mode == false and Global.mobile_mode == false:
		var mouse_pos = get_global_mouse_position()
		$Camera2D.offset.x = (mouse_pos.x - global_position.x) / (160.0 / 2.0)
		$Camera2D.offset.y = (mouse_pos.y - global_position.y) / (90.0 / 2.0)
	elif Global.gamepad_mode == true and Global.mobile_mode == false:
		var gamepad_mouse_pos = $gamepad_crosshair.crosshair.global_position
		$Camera2D.offset.x = (gamepad_mouse_pos.x - global_position.x) / (160.0 / 2.0)
		$Camera2D.offset.y = (gamepad_mouse_pos.y - global_position.y) / (90.0 / 2.0)
