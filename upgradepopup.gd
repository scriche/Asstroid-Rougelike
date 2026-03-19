extends HBoxContainer

var upgradeslot : PackedScene
var upgradeContainer : VBoxContainer
var upgradeEffects: RichTextLabel
var upgrades : Array = [Upgrade]

func _ready() -> void:
	upgradeslot = preload("res://Scenes/upgrade_slot.tscn")
	upgradeContainer = $UpgradeContainer
	upgradeEffects = $UpgradeEffects

func popup():
	upgrades = UpgradeDatabase.get_random_selection(3)

	for upgrade in upgrades:
		var slot: VBoxContainer = upgradeslot.instantiate()
		slot.get_node("UpgradeName").text = upgrade.name
		slot.get_node("UpgradeIcon").texture = upgrade.icon
		upgradeContainer.add_child(slot)
		
		# BIND the 'upgrade' variable to the function call
		slot.gui_input.connect(_on_UpgradeContainer_gui_input.bind(upgrade))

# Now the function receives the 'upgrade' we bound earlier
func _on_UpgradeContainer_gui_input(event: InputEvent, selected_upgrade):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Stats.upgradepickup(selected_upgrade)
			print(Stats.upgrades)
			# remove the upgrade slots after selection
			for child in upgradeContainer.get_children():
				child.queue_free()
			visible = false
