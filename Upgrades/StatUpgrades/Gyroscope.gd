extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "GyroScope"
	rarity = 0
	price = 25
	description = "Increases turn speed by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Gyroscope.png")
	modifiers = {
		"turn_speed": "value + (base * 0.10)"
	}

