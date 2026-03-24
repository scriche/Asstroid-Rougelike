extends Control

@onready var gridcontainer: GridContainer = $HBoxContainer/GridContainer

func _ready():
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
			gridcontainer.add_child(tile)
