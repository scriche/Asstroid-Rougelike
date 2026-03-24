extends Control

@export var upgrade: Upgrade
@export var is_infinite: bool = true # Toggle: True for the "Menu/Palette", False for the "Placed" item
@onready var icon: TextureRect = $Icon
@onready var tooltip_node: Label = $Tooptip

var dragging: bool = false
var target_rotation: float = 0.0
var start_position: Vector2 = Vector2.ZERO
var mouse_pos: Vector2 = Vector2.ZERO
var tooltip: bool = false


func _ready():
	await get_tree().process_frame # Ensure all nodes are ready before accessing properties
	start_position = global_position

	# --- Fallback Texture Logic ---
	if upgrade and upgrade.icon:
		icon.texture = upgrade.icon
	else:
		print("Warning: No upgrade or icon assigned to ", name, ". Using fallback.")
		icon.texture = preload("res://Sprites/NoIcon.png") 

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.is_action_pressed("click"):
			if is_infinite:
				print("Pool: Spawning new instance of ", upgrade.name if upgrade else "Unknown")
				spawn_clone()
			else:
				print("Inventory: Started dragging ", upgrade.name if upgrade else "Unknown")
				dragging = true
				z_index = 100 

		elif event.is_action_released("click"):
			if dragging:
				print("Stopped dragging. Checking for drop zone...")
				dragging = false
				z_index = 0
				check_drop_zone()

	if event is InputEventMouseMotion and !dragging:
		# show hover tooltip when mouse is over the item and not dragging
		if get_global_rect().has_point(event.global_position):
			tooltip = true
			showtooltip(true)
			tooltip_node.global_position = event.global_position + Vector2(10, -tooltip_node.get_size().y - 2) # Position above the mouse

	# Rotation logic (Right Click)
	if dragging and event.is_action_pressed("rclick"):
		target_rotation += PI / 2
		# if rotation exceeds 360 degrees, wrap it around
		if icon.rotation >= TAU:
			icon.rotation -= TAU
		print(icon.rotation)

func spawn_clone():
	# We use duplicate() to get an exact copy of this node's properties
	var clone = self.duplicate()
	clone.upgrade.instance_id = int(Time.get_unix_time_from_system()) * 1000 # Assign a new unique instance_id based on timestamp
	
	# Configure the clone to be a "real" draggable item
	clone.is_infinite = false
	clone.dragging = true
	
	# Add to the SceneTree root so it isn't restricted by parent containers
	get_tree().root.add_child(clone)
	
	# Sync visual state
	clone.global_position = global_position
	clone.target_rotation = target_rotation
	clone.icon.rotation = icon.rotation # Match current rotation immediately

func check_drop_zone():
	var slots = get_tree().get_nodes_in_group("inventoryslot")

	if slots.size() > 0:
		for slot in slots:
			if slot.get_global_rect().has_point(mouse_pos):
				print("SUCCESS: Dropped on slot: ", slot.name)
				# Snap to slot position and rotation
				Stats.upgrade_grid.place_upgrade(upgrade, slot.get_meta("grid_pos")) # Place the upgrade on the grid using its position metadata
				global_position = slot.global_position
				# Add the upgrade to the slot
				slot.get_parent().add_child(self) # Reparent to the slot's parent (e.g., the grid)
				return

	print("FAILURE: Dropped in void. Action: ", "Delete" if !is_infinite else "Return")
	if !is_infinite:
		# If it's a spawned item and missed the target, remove it
		queue_free()

func _process(_delta):
	if dragging:
		mouse_pos = get_global_mouse_position()
		# Smooth follow
		global_position = lerp(global_position, mouse_pos - icon.pivot_offset, 0.2)
		icon.rotation = lerp_angle(icon.rotation, target_rotation, 0.2)
	else:
		# If it's the 'Source' in the infinite pool, ensure it stays at its origin
		if is_infinite and global_position != start_position:
			global_position = lerp(global_position, start_position, 0.1)

	if tooltip:
		if !get_global_rect().has_point(get_global_mouse_position()) || dragging:
			tooltip = false
			showtooltip(false)

func showtooltip(show: bool):
	if show and upgrade:
		tooltip_node.text = "%s\nPrice: %d\n%s" % [upgrade.name, upgrade.price, upgrade.description]
		tooltip_node.visible = true
	else:
		tooltip_node.visible = false
