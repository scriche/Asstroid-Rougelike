extends Resource
class_name Upgrade

@export_group("Identity")
@export var name: String
@export var id: int          # The type ID (e.g., 101 for Pulse Laser)
@export var instance_id: int # The unique ID for THIS specific item on the grid
@export var rarity: int

@export_group("Visuals")
@export var icon: Texture2D
@export_multiline var description: String

@export_group("Economy & Logic")
@export var price: int
@export var modifiers: Dictionary 
@export var trigger: String
@export var passive: bool = false

@export_group("Grid Settings")
## Define the tiles this upgrade occupies. 
## Vector2i(0,0) is the 'handle' or origin of the item.
## A 1x2 vertical item would be: [Vector2i(0,0), Vector2i(0,1)]
@export var shape: Array[Vector2i] = [Vector2i(0,0)]

## This stores where the upgrade is currently placed (top-left origin)
var current_grid_pos: Vector2i = Vector2i(-1, -1)

# --- Functions ---

func passive_effect(_player):
    if passive:
        pass

func trigger_effect(_params: Dictionary = {}):
    # You can call this from the Grid Manager when the 'trigger' string matches
    pass

## Helper to get all absolute coordinates of this item based on a position
func get_occupied_coords(origin: Vector2i) -> Array[Vector2i]:
    var points: Array[Vector2i] = []
    for offset in shape:
        points.append(origin + offset)
    return points

func rotate():
    # Rotate the shape 90 degrees clockwise around the origin (0,0)
    for i in range(shape.size()):
        var offset = shape[i]
        shape[i] = Vector2i(-offset.y, offset.x) # (x,y) -> (-y,x)