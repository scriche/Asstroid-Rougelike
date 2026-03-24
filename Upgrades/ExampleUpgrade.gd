# l_cell_battery.gd
extends Upgrade

func _init():
	name = "Example Upgrade"
	id = 101
	price = 250
	trigger = "on_bullet_fired"
	modifiers = {"bullet_fire_rate": 20}
	icon = preload("res://Sprites/Ship.png")
	# Define the L-shape locally
	shape = [
		Vector2i(0, 0), 
	]

# This is where the unique logic lives for THIS specific script
func trigger_effect(_params: Dictionary = {}):
	print("Example Upgrade active! Boosting fire rate by 20.")
	# Access player stats via a Global or the params passed in
	# GameManager.player.energy += modifiers["max_energy"]