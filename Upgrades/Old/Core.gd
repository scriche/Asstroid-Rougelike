extends Upgrade

# This runs when the upgrade is first loaded/created
func _init():
    name = "Core Reinforcement"
    rarity = 0
    price = 20
    description = "Increases max health by 15%."
    icon = preload("res://Upgrades/StatUpgrades/Core.png")
    modifiers = {"max_health": "value + (base * 0.15)"}