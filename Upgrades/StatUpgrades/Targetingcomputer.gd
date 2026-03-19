extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Targeting Computer"
	rarity = 0
	price = 25
	description = "Increases critical hit chance by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Targetingcomputer.png")
	modifiers = {
		"bullet_crit_chance": "value + (base * 0.10)"
	}

