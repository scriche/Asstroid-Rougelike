extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Precision Strike"
	rarity = 0
	price = 25
	description = "Increases critical hit damage by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Precisionstrike.png")
	modifiers = {
		"bullet_crit_mult": "value + (base * 0.10)"
	}

