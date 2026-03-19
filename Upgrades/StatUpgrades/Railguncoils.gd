extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Railgun Coils"
	rarity = 0
	price = 25
	description = "Increases bullet speed by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Railguncoils.png")
	modifiers = {
		"bullet_speed": "value + (base * 0.10)"
	}

