extends Astroid
	
func _ready() -> void:
	speedmult = 9
	if not is_fragment:
		coincount = 15
		health = 40 * Global.diff * scale.x
		var middlevec =  (Global.viewend+Global.viewpos)/2 - position
		if rotation == 0:
			rotation += atan2(middlevec.y,middlevec.x)
			rotation += randf_range(-PI/6,PI/6)
		scale = Vector2(2*Global.diff*scale.x, 2*Global.diff*scale.x) * scale