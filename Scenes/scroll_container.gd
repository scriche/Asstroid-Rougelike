extends ScrollContainer

@onready var upgrade_grid : GridContainer = $GridContainer

func _ready():
    # Example usage: Place an upgrade at position (1,1) on the grid
    for upgrade in UpgradeDatabase.all_upgrades:
        # create a new UpgradeDraggable instance for each upgrade and add it to the grid
        var draggable = preload("res://Scenes/upgrade_draggable.tscn").instantiate()
        draggable.upgrade = upgrade
        upgrade_grid.add_child(draggable)