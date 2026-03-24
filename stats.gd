extends Node

var _stats := {
	"current_health": _make_stat(100),
	"max_health": _make_stat(100),
	"health_regen_speed": _make_stat(5.0),
	"current_speed": _make_stat(0.0),
	"max_speed": _make_stat(10),
	"turn_speed": _make_stat(100.0),
	"acceleration": _make_stat(30.0),
	"armor": _make_stat(0.0),
	"armor_efficiency": _make_stat(0.75),
	"shield": _make_stat(0.0),
	"shield_regen_rate": _make_stat(1.0),
	"max_shield": _make_stat(0.0),
	"i_frames": _make_stat(1),
	"contact_damage": _make_stat(20.0),

	"ability_recharge": _make_stat(1.0),
	"ability_potency": _make_stat(1.0),
	"ability_strength": _make_stat(1.0),
	"pickup_range": _make_stat(1.0),
	"luck": _make_stat(1.0),
	"greed": _make_stat(0.0),

	"bullet_damage": _make_stat(10.0),
	"bullet_fire_rate": _make_stat(0.5),
	"bullet_speed": _make_stat(1500.0),
	"bullet_size": _make_stat(1.0),
	"bullet_count": _make_stat(1),
	"bullet_pierce": _make_stat(0),
	"bullet_homing": _make_stat(0.0),
	"bullet_crit_chance": _make_stat(0.0),
	"bullet_crit_mult": _make_stat(1.5),
	"bullet_potency": _make_stat(0.0),
	"bullet_strength": _make_stat(1.0),
}

# Initialize the upgrade grid of the ship with 0 means locked, 1 means available
# 9x9 grid with all 0s except for a cross shape in the middle where the first 5 rows and columns are available for upgrades, and the rest are locked. This is just an example layout and can be changed as needed.
var upgrade_grid : UpgradeGrid = UpgradeGrid.new()

# Initial an empty array to store upgrades
var upgrades: Array[Upgrade] = []

func upgradepickup(upgrade: Upgrade):
	# Add the upgrade to the player's list of upgrades
	upgrade = upgrade.duplicate()
	upgrade.instance_id = upgrade.get_instance_id()
	upgrades.append(upgrade)

	# Apply the upgrade's modifiers to the player's stats
	for stat_name in upgrade.modifiers.keys():
		var formula = upgrade.modifiers[stat_name]	
		if !_stats.has(stat_name):
			push_error("Stat not found: " + stat_name)
			return -1

		_stats[stat_name]["modifiers"][upgrade.instance_id] = formula
		_stats[stat_name]["dirty"] = true

func removeupgrade(upgrade: Upgrade):
	# Remove the upgrade from the player's list of upgrades
	upgrades.erase(upgrade)

	# Remove the upgrade's modifiers from the player's stats
	for stat_name in upgrade.modifiers.keys():
		_stats[stat_name]["modifiers"].erase(upgrade.instance_id)

func _make_stat(base: float) -> Dictionary:
	return {
		"base": base,
		"modifiers": {},
		"dirty": false,
		"total": base
	}

# Get the final calculated value of a stat
func getstat(statname: String) -> float:
	var stat = _stats.get(statname)
	if stat == null:
		push_error("Stat not found: " + statname)
		return 0.0
	if stat["dirty"]:
		var value = stat["base"]
		for modifier in stat["modifiers"]:
			if modifier == null:
				continue
			var formula = stat["modifiers"][modifier]
			# replace value with the current value and replace base with the original base for any formulas that need it
			formula = formula.replace("value", str(value))
			formula = formula.replace("base", str(stat["base"]))
			var expr = Expression.new()
			expr.parse(formula)
			value = expr.execute()
		stat["total"] = value
		stat["dirty"] = false
	return stat["total"]

# Set the base value of a stat
func setstat(statname: String, base_value: float) -> void:
	if _stats.has(statname):
		_stats[statname]["base"] = base_value
		_stats[statname]["dirty"] = true
	else:
		push_error("Stat not found: " + statname)
