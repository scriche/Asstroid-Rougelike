# l_cell_battery.gd
extends Upgrade

func _init():
	name = "3x1 Example Upgrade"
	price = 25
	trigger = "on_health_regen"
	icon = preload("res://Sprites/3x1 battery.png")
	shape = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
	]

# This is where the unique logic lives for THIS specific script
func trigger_effect(_params: Dictionary = {}):
	print("3x1 Example Upgrade active! buffing next shot.")
	# Access player stats via a Global or the params passed in
	# GameManager.player.energy += modifiers["max_energy"]