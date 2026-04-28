extends Area2D
class_name WallBuy

# Drag and drop the weapon scene (e.g., Shotgun.tscn) here in the Inspector!
@export var weapon_to_give: PackedScene
@export var weapon_cost: int = 500
@export var weapon_name: String


# Assuming you have a way to detect the player pressing an interact button
func interact(player):
	# Check if the player has enough points (assuming you add a points system)
	if player.points >= weapon_cost:
		player.points -= weapon_cost
		
		# We pass the PackedScene directly to the player's function
		player.pickup_weapon(weapon_to_give)
		print(weapon_name + " bought from the wall!")


var players_in_range: Array = []

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		for player in players_in_range:
			interact(player)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		players_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		players_in_range.erase(body)
