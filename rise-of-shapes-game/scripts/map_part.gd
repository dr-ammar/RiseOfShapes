extends Node2D

# --- Map Part (جزء الخريطة) ---
# Use this to group elements of a specific area.

@export var area_name: String = "Starting Room"

func _ready():
	add_to_group("map_part")
	# Potential logic:
	# - Only spawn zombies in the current area
	pass
