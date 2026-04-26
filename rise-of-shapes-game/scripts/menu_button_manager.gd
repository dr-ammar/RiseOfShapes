extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/scarlet_map.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_gamepad_switch_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.gamepad_mode = true
	else:
		Global.gamepad_mode = false
	print(Global.gamepad_mode)
