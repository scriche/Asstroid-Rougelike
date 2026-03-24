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
			tile.texture = preload("res://Sprites/GridTile.png")
			tile.add_to_group("inventoryslot") # Add to group for drop detection
			tile.set_meta("grid_pos", Vector2i(x, y))
			gridcontainer.add_child(tile)

func _on_grid_changed():
	print("Grid changed! Updating display...")