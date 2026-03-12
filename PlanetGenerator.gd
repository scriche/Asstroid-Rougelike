extends Node2D

var total_impact : float = 0.0
var tries : int = 50 # Number of attempts to find a suitable negative modifier
var images : Array = []
var names : Array = []
var modifier_data : Dictionary = {
	"positive": [],
	"negative": []
}

func _ready():
	# Initialize the the size of the planet image folder and create an index
	var dir = "res://Planets/Images/"
	var dir_access = DirAccess.open(dir)
	if dir_access:
		dir_access.list_dir_begin()
		var file_name = dir_access.get_next()
		while file_name:
			if not dir_access.current_is_dir() and file_name.ends_with(".png"):
				# Add the file to the list if it's a .png file and not a directory
				images.append(file_name)
			file_name = dir_access.get_next()
		dir_access.list_dir_end()
	else:
		push_error("Could not open directory: " + dir)
		
	# Initialize the names array with planet names from a JSON file
	var names_path = "res://Planets/Names.json"
	# read the JSON file containing planet names
	var names_file := FileAccess.open(names_path, FileAccess.READ)
	if names_file == null:
		push_error("Failed to open names file: " + names_path)
		return
	var names_content := names_file.get_as_text()
	var names_result: Variant = JSON.parse_string(names_content)
	if names_result == null:
		push_error("Failed to parse JSON: " + names_path)
		return
	names = names_result["planets"]

	var path = "res://Planets/Modifiers.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Failed to open modifier file: " + path)
		return

	var content := file.get_as_text()
	var result: Variant = JSON.parse_string(content)
	if result == null:
		push_error("Failed to parse JSON: " + path)
		return

	modifier_data = result

func genPlanet(positive_count: int, negative_count: int) -> Dictionary:
	# Generates a planet with a random image, name, and modifiers
	var planet = {
		"image": getImage(),
		"name": getName(),
		"modifiers": getModifiers(positive_count, negative_count),
		"Balance": total_impact
	}
	return planet

func getImage() -> String:
	# Returns a random image from the images array
	if images.size() == 0:
		push_error("No images available")
		return ""
	var index = randi() % images.size()
	return "res://Planets/Images/" + images[index]

func getName() -> String:
	# Returns a random name from the names array
	if names.size() == 0:
		push_error("No names available")
		return ""
	var index = randi() % names.size()
	return names[index]

func getModifiers(positive_count: int, negative_count: int) -> Array:
	var positives = modifier_data["positive"]
	var negatives = modifier_data["negative"]
	negative_count = randi_range(1, negative_count)

	var weighted_positives = []
	for mod in positives:
		if not mod.has("rarity"):
			mod["rarity"] = 1
		for i in mod["rarity"]:
			weighted_positives.append(mod)

	var weighted_negatives = []
	for mod in negatives:
		if not mod.has("rarity"):
			mod["rarity"] = 1
		for i in mod["rarity"]:
			weighted_negatives.append(mod)

	var selected = []
	var used_names = []
	total_impact = 0.0
	var tolerance = 0.2

	# Sort by absolute value, descending
	weighted_positives.sort_custom(func(a, b): return abs(b["value"]) < abs(a["value"]))
	weighted_negatives.sort_custom(func(a, b): return abs(b["value"]) < abs(a["value"]))

	# Select positives first
	for i in positive_count:
		var best_mod = null
		var best_diff = INF
		for mod in weighted_positives:
			if mod["name"] in used_names:
				continue
			var multiplier = randf_range(1, Global.diff) # Always use minimum for positives
			var impact = mod["value"] * multiplier
			var diff = abs((total_impact + impact))
			if diff < best_diff:
				best_diff = diff
				best_mod = {
					"mod": mod,
					"multiplier": multiplier,
					"impact": impact
				}
			if best_diff <= tolerance:
				break
		if best_mod:
			used_names.append(best_mod["mod"]["name"])
			selected.append({
				"name": best_mod["mod"]["name"],
				"multiplier": best_mod["multiplier"],
				"value": best_mod["mod"]["value"],
				"impact": best_mod["impact"],
				"rarity": best_mod["mod"]["rarity"],
				"type": "positive",
				"effect": best_mod["mod"]["type"]
			})
			total_impact += best_mod["impact"]
		else:
			break
	# Now select negatives to balance towards 0
	# Try to bring total_impact back toward zero by adding negative modifiers

	for i in range(tries):
		# Pick a random unused negative modifier
		var mod = weighted_negatives.pick_random()
		if mod["name"] in used_names:
			continue
		if mod["value"] == 0:
			continue

		# Pick a random multiplier between 0.5 and 3.0 * Global.diff
		var multiplier = randf_range(0.5, 3.0 * Global.diff)
		var impact = mod["value"] * multiplier
		var projected_impact = total_impact + impact

		# If it's within tolerance, accept it
		if abs(projected_impact) <= tolerance:
			used_names.append(mod["name"])
			selected.append({
				"name": mod["name"],
				"multiplier": multiplier,
				"value": mod["value"],
				"impact": impact,
				"rarity": mod["rarity"],
				"type": "negative",
				"effect": mod["type"]
			})
			total_impact += impact
			print("Selected negative modifier:", mod["name"], "with impact:", impact)

		# If it's over, scale the multiplier down to stay within tolerance
		var max_allowed_impact = tolerance - abs(total_impact)
		if abs(mod["value"]) > 0:
			var max_multiplier = max_allowed_impact / abs(mod["value"])
			if max_multiplier >= 1.0:
				multiplier = clamp(max_multiplier, 1.0, 3.0 * Global.diff)
				impact = mod["value"] * multiplier
				used_names.append(mod["name"])
				selected.append({
					"name": mod["name"],
					"multiplier": multiplier,
					"value": mod["value"],
					"impact": impact,
					"rarity": mod["rarity"],
					"type": "negative",
					"effect": mod["type"]
				})
				total_impact += impact
				break
		# Otherwise, try another modifier

	return selected
