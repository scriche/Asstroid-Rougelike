extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Expansion Rounds"
	rarity = 0
	price = 25
	description = "Increases bullet size by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Expansionrounds.png")
	modifiers = {
		"bullet_size": "value + (base * 0.10)"
	}

