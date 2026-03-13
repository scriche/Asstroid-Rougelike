extends Node

var _stats := {
	"current_health": _make_stat(100),
	"max_health": _make_stat(100),
	"health_regen_amount": _make_stat(0.0),
	"health_regen_speed": _make_stat(1.0),
	"current_speed": _make_stat(0.0),
	"max_speed": _make_stat(10),
	"turn_speed": _make_stat(180.0),
	"acceleration": _make_stat(30.0),
	"size": _make_stat(1.0),
	"armor": _make_stat(0.0),
	"armor_efficiency": _make_stat(0.75),
	"shield": _make_stat(0.0),
	"shield_regen_rate": _make_stat(1.0),
	"dodge_chance": _make_stat(0.0),
	"i_frames": _make_stat(1),
	"contact_damage": _make_stat(0.0),

	"ability_recharge": _make_stat(1.0),
	"ability_potency": _make_stat(1.0),
	"ability_strength": _make_stat(10.0),
	"upgrade_slots": _make_stat(3),
	"upgrade_order": _make_stat(0),
	"pickup_range": _make_stat(2.0),
	"exp_multi": _make_stat(1.0),
	"luck": _make_stat(1.0),
	"greed": _make_stat(1.0),

	"bullet_damage": _make_stat(10.0),
	"bullet_fire_rate": _make_stat(2.0),
	"bullet_speed": _make_stat(1000.0),
	"bullet_size": _make_stat(1.0),
	"bullet_duration": _make_stat(3.0),
	"bullet_count": _make_stat(1),
	"spread": _make_stat(5.0),
	"bullet_pierce": _make_stat(0),
	"bullet_reflect_count": _make_stat(0),
	"bullet_homing": _make_stat(0.0),
	"bullet_crit_percent": _make_stat(0.05),
	"bullet_crit_mult": _make_stat(2.0),
	"bullet_potency": _make_stat(0.0),
	"bullet_strength": _make_stat(1.0),
	"recoil": _make_stat(0.1),
}

func _process(_delta):
	# interate through all persistant abilities and call them
	for ability in persistant_abilities:
		ability.call()


# Initial an empty array to store upgrades
var upgrades: Array = []
var persistant_abilities: Array = []

func upgradepickup(upgrade: Upgrade):
	# Add the upgrade to the player's list of upgrades
	upgrades.append(upgrade)

	# Apply the upgrade's modifiers to the player's stats
	for stat_name in upgrade.modifiers.keys():
		var formula = upgrade.modifiers[stat_name]	
		if !_stats.has(stat_name):
			push_error("Stat not found: " + stat_name)
			return -1

		_stats[stat_name]["modifiers"][upgrade.id] = formula
		_stats[stat_name]["dirty"] = true

	# Check if the upgrade has an ability and set it up
	if upgrade.persistent_ability.is_valid():
		# Add the upgrades persistant ability to the to the respective array
		persistant_abilities.append(upgrade.persistent_ability)
		return

func removeupgrade(upgrade: Upgrade):
	# Remove the upgrade from the player's list of upgrades
	upgrades.erase(upgrade)

	# Remove the upgrade's modifiers from the player's stats
	for stat_name in upgrade.modifiers.keys():
		_stats[stat_name]["formulas"].erase(upgrade.modifiers[stat_name])

	# Remove the upgrade's ability if it has one
	if upgrade.persistant_ability != null:
		persistant_abilities.erase(upgrade.persistant_ability)


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
			# perform the code in the formula on the value eg formula is exp(sqrt(value*4)) then do that to the value
			var expr = Expression.new()
			expr.parse(formula.replace("value", str(value)))
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
