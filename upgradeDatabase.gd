extends Node

@export var all_upgrades: Array[Upgrade]

func _ready():
	load_upgrades_from_folder("res://Upgrades/")

func load_upgrades_from_folder(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if !dir.current_is_dir() and file_name.ends_with(".gd"):
				var full_path = path + file_name
				var script_resource = load(full_path) # Load the script file

				# 1. Check if the script exists and can be instanced
				if script_resource is GDScript:
					var upgrade_instance = script_resource.new() # Create the actual object
					
					# 2. Now 'is Upgrade' will work because it's an object, not a script!
					if upgrade_instance is Upgrade:
						upgrade_instance.id = all_upgrades.size() # Assign a unique ID based on current list size
						# Optional: Use the filename or a property as a unique key
						all_upgrades.append(upgrade_instance)
						print("Loaded upgrade: ", upgrade_instance.name)
			
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("An error occurred when trying to access the path: ", path)

## Helper to find an upgrade by name
func get_upgrade_by_name(upgrade_name: String) -> Upgrade:
	for upgrade in all_upgrades:
		if upgrade.name == upgrade_name:
			return upgrade
	return null

## Helper to get a random upgrade based on rarity
func get_random_by_rarity(target_rarity: int) -> Array[Upgrade]:
	return all_upgrades.filter(func(u): return u.rarity == target_rarity)

## Returns a random selection of unique upgrades
func get_random_selection(amount: int = 3) -> Array[Upgrade]:
	var selection : Array[Upgrade] = []
	var available = all_upgrades.duplicate()
	available.shuffle()
	
	for i in range(min(amount, available.size())):
		selection.append(available[i])
	return selection

## Define weights for your rarities (0: Common, 1: Rare, 2: Epic, etc.)
@export var rarity_weights: Dictionary = {0: 0.7, 1: 0.2, 2: 0.1}

func get_weighted_random() -> Upgrade:
	var roll = randf()
	var current_weight = 0.0
	
	for rarity in rarity_weights:
		current_weight += rarity_weights[rarity]
		if roll <= current_weight:
			var pool = get_random_by_rarity(rarity)
			if pool.size() > 0:
				return pool.pick_random()
	return all_upgrades.pick_random() # Fallback

## Returns all upgrades that modify a specific stat (e.g., "max_speed")
func get_upgrades_by_stat(stat_name: String) -> Array[Upgrade]:
	return all_upgrades.filter(func(u): return u.modifiers.has(stat_name))
