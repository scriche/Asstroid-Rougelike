extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Accelerated Recharge"
	rarity = 0
	price = 25
	description = "Increases shield regeneration speed by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Acceleratedrecharge.png")
	modifiers = {
		"shield_regen_rate": "value + (base * 0.10)"
	}
