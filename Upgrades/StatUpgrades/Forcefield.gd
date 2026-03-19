extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Force Field"
	rarity = 1
	price = 50
	description = "Increases max shields by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Forcefield.png")
	modifiers = {
		"max_shield": "value + 10"
	}

