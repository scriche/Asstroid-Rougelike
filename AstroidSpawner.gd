extends Node2D

@export var Astroid : PackedScene
var spawnspeed = 1
var scalemulti = 1.0

func _on_timer_timeout() -> void:
	var a = Astroid.instantiate()
	var offset = 80 * a.scale.x
	match randi_range(0,3): 
		0:
			a.position = Vector2(randf_range(Global.viewpos.x,Global.viewend.x),Global.viewpos.y-offset)
		1:
			a.position = Vector2(randf_range(Global.viewpos.x,Global.viewend.x),Global.viewend.y+offset)
		2:
			a.position = Vector2(Global.viewpos.x-offset,randf_range(Global.viewpos.y,Global.viewend.y))
		3:
			a.position = Vector2(Global.viewend.x+offset,randf_range(Global.viewpos.y,Global.viewend.y))
	a.scale = Vector2(scalemulti,scalemulti)
	add_child(a)

func _process(_delta: float) -> void:
	$Timer.wait_time = 2/Global.diff * spawnspeed
