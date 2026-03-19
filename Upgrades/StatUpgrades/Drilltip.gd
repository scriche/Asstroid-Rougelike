extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Drilltip Bullets"
	rarity = 0
	price = 25
	description = "Increases bullet pierce by 1."
	icon = preload("res://Upgrades/StatUpgrades/Drilltip.png")
	modifiers = {
		"bullet_pierce": "value + 1"
	}

