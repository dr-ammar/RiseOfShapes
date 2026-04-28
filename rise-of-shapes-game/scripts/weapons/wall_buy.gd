extends Area2D
class_name WallBuy

# --- إعدادات الشراء (Inspector Settings) ---
@export var weapon_to_give: PackedScene # مشهد السلاح المطلوب
@export var weapon_cost: int = 500       # سعر السلاح
@export var weapon_name: String          # اسم السلاح للعرض

# --- إدارة اللاعبين في المدى ---
var players_in_range: Array = []

# --- المعالجة (Processing) ---

func _process(_delta):
	# التحقق من ضغط زر التفاعل (E عادةً) لجميع اللاعبين الموجودين في النطاق
	if Input.is_action_just_pressed("interact"):
		for player in players_in_range:
			interact(player)

func interact(player):
	# التحقق من توفر النقاط الكافية
	if player.points >= weapon_cost:
		player.points -= weapon_cost
		# إضافة السلاح لحقيبة اللاعب
		player.pickup_weapon(weapon_to_give)
		print(weapon_name + " تم شراؤه من الجدار!")
	else:
		print("لا تملك نقاطاً كافية لـ " + weapon_name)

# --- إشارات المنطقة (Area Signals) ---

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		players_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		players_in_range.erase(body)
