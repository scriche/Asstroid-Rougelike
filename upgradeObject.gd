extends Resource
class_name Upgrade

@export var name: String
@export var id: int
@export var rarity: int
@export var price: int
@export_multiline var description: String
@export var icon: Texture2D
@export var modifiers: Dictionary 
@export var trigger_ability: Callable
@export var persistent_ability: Callable