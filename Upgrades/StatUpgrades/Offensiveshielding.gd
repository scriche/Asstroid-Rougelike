extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Offensive Shielding"
	rarity = 0
	price = 25
	description = "Increases contact damage by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Offensiveshielding.png")
	modifiers = {
		"contact_damage": "value + (base * 0.10)"
	}

