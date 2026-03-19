extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Plating"
	rarity = 0
	price = 25
	description = "Increases armor by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Plating.png")
	modifiers = {
		"armor": "value +  0.10"
	}

