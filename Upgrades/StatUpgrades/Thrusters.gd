extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Thrusters"
	rarity = 0
	price = 25
	description = "Increases ship speed by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Thrusters.png")
	modifiers = {
		"max_speed": "value + (base * 0.10)"
	}

