extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Autoloader"
	rarity = 0
	price = 25
	description = "Increases fire rate by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Autoloader.png")
	modifiers = {
		"bullet_fire_rate": "value - (base * 0.10)"
	}

