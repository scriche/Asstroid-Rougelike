extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Fuel Injection"
	rarity = 0
	price = 25
	description = "Increases acceleration by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Fuelinjection.png")
	modifiers = {
		"acceleration": "value + (base * 0.10)"
	}

