extends Control

@onready var gridcontainer: GridContainer = $HBoxContainer/GridContainer
# connect to the grid_changed signal of the UpgradeGrid to update the display when the grid changes

func _ready():
	Stats.upgrade_grid.connect("grid_changed", self._on_grid_changed)

	# Example usage: Place an upgrade at position (1,1) on the grid
	initialize_grid_display(Stats.upgrade_grid.grid_size)

func initialize_grid_display(n: int) -> void:
	# add a texture rect for each tile in the grid with texture GridTile.png
	for y in range(n):
		for x in range(n):
			print("Initializing tile at position: ", Vector2i(x, y))
			var tile = TextureRect.new()
			tile.z_index = 0 # Ensure tiles are behind upgrades
			tile.texture = preload("res://Sprites/GridTile.png")
			tile.add_to_group("inventoryslot") # Add to group for drop detection
			tile.set_meta("grid_pos", Vector2i(x, y))
			gridcontainer.add_child(tile)

func _on_grid_changed():
	# print the grid is ascii to the console for debugging
	var grid = Stats.upgrade_grid.grid
	var grid_size = Stats.upgrade_grid.grid_size
	print("Grid changed:")
	for y in range(grid_size):
		var row = ""
		for x in range(grid_size):
			var upgrade = grid[y][x]
			if upgrade:
				row += "X" # Represent occupied slots with X
			else:
				row += "." # Represent empty slots with .
		print(row)