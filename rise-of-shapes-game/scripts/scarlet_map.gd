extends Node2D

func _ready():
	# إبلاغ الـ GameManager ببدء اللعب عند تحميل الخريطة
	if GameManager.has_method("start_game"):
		GameManager.start_game()
