extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
	name = "Phasetech"
	rarity = 0
	price = 25
	description = "Increases invulnerability time by 10%."
	icon = preload("res://Upgrades/StatUpgrades/Phasetech.png")
	modifiers = {
		"i_frames": "value + (base * 0.10)"
	}

