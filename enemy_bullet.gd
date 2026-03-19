extends Area2D

@export var speed: float = 300.0
@export var damage_amount: int = 10
@export var rotation_force: float = 0.0

func _physics_process(delta: float) -> void:
	rotation += rotation_force * delta
	position += Vector2.from_angle(rotation) * speed * delta
	
	# Cleanup is crucial! 
	# Use a VisibleOnScreenNotifier2D or check Global.view bounds
	if position < Global.viewpos - Vector2(100, 100) or position > Global.viewend + Vector2(100, 100):
		queue_free()

func damage(amount: int) -> void:
	# Bullets don't take damage, but they can deal damage on hit
	pass
