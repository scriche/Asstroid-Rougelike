extends RefCounted
class_name UpgradeGrid

signal grid_changed
signal tile_unlocked(pos: Vector2i)
signal upgrade_placed(upgrade: Upgrade)
signal upgrade_removed(instance_id: int)

# Constants for tile states
const TILE_LOCKED = -1
const TILE_EMPTY = null

var grid_size: int
var grid: Array = [] # Stores TILE_LOCKED, TILE_EMPTY, or instance_id (int)
var placed_upgrades: Dictionary = {}

func _init(n: int = 6) -> void:
	initialize_grid(n)

## Wipes grid and locks everything except the center 1x2
func initialize_grid(n: int) -> void:
	grid_size = n
	grid.clear()
	placed_upgrades.clear()
	
	# 1. Initialize all as LOCKED
	for y in range(n):
		var row = []
		for x in range(n):
			row.append(TILE_LOCKED)
		grid.append(row)
	
	# unlocks all tiles
	for i in range(n):
		for j in range(n):
			unlock_tile(Vector2i(i, j))
	
	grid_changed.emit()

## Unlocks a specific tile so it can accept upgrades
func unlock_tile(pos: Vector2i) -> void:
	if _is_in_bounds(pos):
		if grid[pos.y][pos.x] == TILE_LOCKED:
			grid[pos.y][pos.x] = TILE_EMPTY
			tile_unlocked.emit(pos)
			grid_changed.emit()

## Checks if an upgrade fits and if the tiles are UNLOCKED
func can_place(upgrade: Upgrade, pos: Vector2i) -> bool:
	for offset in upgrade.shape:
		var target = pos + offset
		
		if not _is_in_bounds(target):
			return false
		
		var cell = grid[target.y][target.x]
		
		# CANNOT place if tile is LOCKED
		if cell == TILE_LOCKED:
			return false
			
		# CANNOT place if occupied by another item
		if cell != TILE_EMPTY and cell != upgrade.instance_id:
			return false
			
	return true

## Places the upgrade if possible
func place_upgrade(upgrade: Upgrade, pos: Vector2i) -> bool:
	print("Attempting to place upgrade: ", upgrade.name, " at position: ", pos)
	
	# 1. Check if it can be placed (fits and tiles are unlocked)
	if not can_place(upgrade, pos):
		return false
	
	# 2. Clear old position if this is a move/rotate
	if placed_upgrades.has(upgrade.instance_id):
		_clear_tiles(upgrade.instance_id)
		print("Upgrade was already placed, clearing old position.")
	print("Upgrade can be placed, proceeding with placement.")
	# 3. Place the upgrade by marking its occupied tiles with its unique instance_id
	for offset in upgrade.shape:
		var target = pos + offset
		grid[target.y][target.x] = upgrade.instance_id
	
	# 4. Store the upgrade's position and reference in placed_upgrades
	placed_upgrades[upgrade.instance_id] = {"data": upgrade, "pos": pos}
	upgrade.current_grid_pos = pos
	
	# 5. Emit signal to notify about the new placement
	upgrade_placed.emit(upgrade)
	grid_changed.emit()
	return true

## Clears an upgrade by its unique instance_id
func remove_upgrade(instance_id: int) -> void:
	if not placed_upgrades.has(instance_id):
		return
	_clear_tiles(instance_id)
	placed_upgrades.erase(instance_id)
	
	upgrade_removed.emit(instance_id)
	grid_changed.emit()

## Returns the Upgrade resource at a specific grid coordinate
func get_upgrade_at_tile(pos: Vector2i) -> Upgrade:
	if not _is_in_bounds(pos): return null
	var val = grid[pos.y][pos.x]
	if val != null and val != TILE_LOCKED:
		if placed_upgrades.has(val):
			return placed_upgrades[val]["data"]
	return null

func _clear_tiles(instance_id: int) -> void:
	var entry = placed_upgrades[instance_id]
	var pos = entry["pos"]
	var upgrade = entry["data"]
	for offset in upgrade.shape:
		var target = pos + offset
		grid[target.y][target.x] = TILE_EMPTY
	upgrade.current_grid_pos = Vector2i(-1, -1)

func _is_in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_size and pos.y >= 0 and pos.y < grid_size

func is_tile_locked(x: int, y: int) -> bool:
	return grid[y][x] == TILE_LOCKED