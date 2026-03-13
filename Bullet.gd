extends Area2D

@export var bullet_speed : float

func _physics_process(delta: float) -> void:
	var velocity = Vector2(cos(rotation-PI/2), sin(rotation-PI/2)) * bullet_speed
	position += velocity * delta

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_entered(area:Area2D):
	if area.is_in_group("Astroids"):
		# Send onhit signal to the signal manager
		TriggerManager.on_bullet_hit(self, area)
		area.call_deferred("damage", Stats.getstat("bullet_damage"))
		queue_free()
