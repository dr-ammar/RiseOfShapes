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


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and Input.is_action_pressed("interact"):
		interact(body)
