extends Node

class Upgrade:
	var name : String
	var modifiers : Dictionary
	var description : String
	var icon : Texture2D
	var rarity : int
	var id : int
	var price : int
	var unique_ability : Callable

var _stats := {
	"max_health": _make_stat(100),
    "acceleration": _make_stat(30),
    "max_speed": _make_stat(8),
	"fire_rate": _make_stat(1),
    "bullet_speed": _make_stat(1000),
	"size": _make_stat(1),
	"armor": _make_stat(0),

	"shield": _make_stat(0),
	"shield_recharge": _make_stat(0.5),
	"dodge_chance": _make_stat(0),
	"ability_cooldown": _make_stat(0),
	"bullet_piercing": _make_stat(0),
	"bullet_size": _make_stat(1),
	"bullet_damage": _make_stat(10),
	"bullet_crit_percent": _make_stat(0),
	"bullet_crit_multi": _make_stat(1.5),
	"bullet_potency": _make_stat(1),
	"bullet_power": _make_stat(1),
	"bullet_count": _make_stat(1),
	"riccochet_count": _make_stat(0),
}

# Initial an empty array to store upgrades
var upgrades: Array = []

func upgradepickup(upgrade: Upgrade):
	# Apply the upgrade's modifiers to the player's stats
	# Add the Upgrade object to the next array index
	for stat in upgrade.modifiers.keys():
		var mod = upgrade.modifiers[stat]
		if mod["type"] == "flat":
			add(stat, "flat", mod["value"])
		elif mod["type"] == "mult":
			add(stat, "mult", mod["value"])


func _make_stat(base: float) -> Dictionary:
	return {
		"base": base,
		"formulas": []
	}

# Get the final calculated value of a stat
func getstat(statname: String) -> float:
	var stat = _stats.get(statname)
	if stat == null:
		push_error("Stat not found: " + statname)
		return 0.0

	var value = stat["base"]
	for formula in stat["formulas"]:
		if formula == null:
			continue
		# perform the code in the formula on the value eg formula is exp(sqrt(value*4)) then do that to the value
		var expr = Expression.new()
		expr.parse(formula.replace("value", str(value)))
		value = expr.execute()
	return value

# Set the base value of a stat
func setstat(statname: String, base_value: float) -> void:
	if _stats.has(statname):
		_stats[statname]["base"] = base_value
	else:
		push_error("Stat not found: " + statname)

# Add a formula string to a stat and return its index (flat or mult)
func add(statname: String, formula: String) -> int:
	if !_stats.has(statname):
		push_error("Stat not found: " + statname)
		return -1

	var list = _stats[statname][formula]
	for i in range(list.size()):
		if list[i] == null:
			list[i] = formula
			return i
	list.append(formula)
	return list.size() - 1

# Remove a modifier from a stat by nulling its index
func remove(statname: String, formula: String) -> void:
	if !_stats.has(statname):
		push_error("Stat not found: " + statname)
		return

	var list = _stats[statname][formula]
	for i in range(list.size()):
		if list[i] == formula:
			list[i] = null
			return
