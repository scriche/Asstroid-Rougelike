extends Node2D

@onready var roundtimer : Timer = $"Round Time"
@onready var spawntimer: Timer = $TickTimer


func _on_round_time_timeout():
	pass

func startRound():
	# Start the round timer
	roundtimer.start()
	spawntimer.start()


func _on_tick_timer_timeout():
	spawn_weighted_random()
	update_spawn_speed()

func spawn_weighted_random():
	var table = get_dynamic_spawn_table()
	var total_weight = 0.0
	for weight in table.values():
		total_weight += weight
	
	var roll = randf_range(0, total_weight)
	var cursor = 0.0
	
	for path in table:
		cursor += table[path]
		if roll <= cursor:
			instance_node(path)
			return # Exit after spawning one thing

func get_dynamic_spawn_table() -> Dictionary:
	return {
		#"res://scenes/asteroid.tscn": 80.0, # Constant "noise"
		#"res://scenes/enemy.tscn": 5.0 * difficulty, # Becomes common fast
		#"res://scenes/mini_event.tscn": max(0, (difficulty - 2) * 3), # Mid-game
		#"res://scenes/mega_event.tscn": max(0, (difficulty - 4) * 5)  # Late-game chaos
	}

func instance_node(path: String):
	var scene = load(path).instantiate()
	# Random position logic here (e.g., outside screen bounds)
	get_parent().add_child(scene)

func update_spawn_speed():
	# This makes the "Tick" happen faster and faster
	spawntimer.wait_time = clamp(2.0 / (Global.diff * 0.5), 0.15, 2.0)