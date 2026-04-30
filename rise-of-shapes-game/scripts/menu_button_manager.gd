extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scarlet_map.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_gamepad_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		GameManager.gamepad_mode = true
	else:
		GameManager.gamepad_mode = false
	print("Gamepad Mode: ", GameManager.gamepad_mode)


func _on_mobile_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		GameManager.mobile_mode = true
	else:
		GameManager.mobile_mode = false
	print("Mobile Mode: ", GameManager.mobile_mode)
