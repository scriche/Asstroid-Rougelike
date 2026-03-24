extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Heavy Caliber"
	rarity = 0
	price = 25
	description = "Increases bullet damage by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Heavycaliber.png")
	modifiers = {
		"bullet_damage": "value + (base * 0.10)"
	}

