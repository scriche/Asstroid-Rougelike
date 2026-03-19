extends Resource
class_name Upgrade

@export var name: String
@export var id: int
@export var instance_id: int
@export var rarity: int
@export var price: int
@export_multiline var description: String
@export var icon: Texture2D
@export var modifiers: Dictionary 
@export var trigger: String
@export var passive: bool = false

func passive_effect(_player):
    pass

func trigger_effect(_params: Dictionary = {}):
    pass
