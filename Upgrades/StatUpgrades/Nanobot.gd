extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Nanobot Repair"
	rarity = 0
	price = 25
	description = "Increases health regeneration speed by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Nanobot.png")
	modifiers = {
		"health_regen_speed": "value - (base * 0.10)"
	}

