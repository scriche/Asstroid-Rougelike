extends Node2D

@onready var roundtimer : Timer = $RoundTime
@onready var spawntimer: Timer = $SpawnTimer
@onready var astroidspawner: Node2D = $AstroidSpawner
var round_multi: int = 3
var round_credits: int = 3

func startRound():
	# Start the round timer
	roundtimer.start()
	spawntimer.start(randi_range(30, 60)) # Randomize spawn timer for more dynamic gameplay
	round_credits = Global.diff * round_multi

func spawn_enemy(type: Global.Enemy, spawn_pos: Vector2, bypass_cost: bool = false) -> Area2D:
	var data = Global.enemies.get(type)
	if data and (bypass_cost or _purchase(data.cost)):
		var enemy = data.scene.instantiate()
		enemy.global_position = spawn_pos
		add_child(enemy)
		return enemy
	return

func spawn_event(type: Global.Event, spawn_pos: Vector2, bypass_cost: bool = false) -> Node2D:
	var data = Global.events.get(type)
	if data and (bypass_cost or _purchase(data.cost)):
			var event = data.scene.instantiate()
			event.global_position = spawn_pos
			add_child(event)
			return event
	return

# Private helper to handle the money logic
func _purchase(amount: int) -> bool:
	if round_credits >= amount:
		round_credits -= amount
		print("Purchase successful. Remaining: ", round_credits)
		return true
	print("Insufficient funds! Need: ", amount)
	return false

func _on_tick_timer_timeout():
	update_spawn_speed()
	if randf() < 0.7: # 70% chance to spawn an enemy, 30% chance to trigger an event
		spawn_enemy(Global.Enemy.CIRCLE_PASSIVE, _get_random_spawn_position())
	else:
		spawn_event(Global.Event.GOLDEN_ASTEROID, _get_random_spawn_position())

func _on_round_time_timeout():
	# Round ended, stop spawning and maybe trigger an event or reward
	spawntimer.stop()
	astroidspawner.toggle_spawning() # Example: toggle asteroid spawning on round end
	Global.boss = spawn_enemy(Global.Enemy.HENNIGMACHINE, Vector2(Global.viewend.x/2,Global.viewend.y/2), true) # Spawn a final enemy as a "boss" or challenge

func _get_random_spawn_position() -> Vector2:
	var side = randi() % 4
	var x: float
	var y: float
	match side:
		0: # Top
			x = randf_range(Global.viewpos.x, Global.viewend.x)
			y = Global.viewpos.y - 50
		1: # Right
			x = Global.viewend.x + 50
			y = randf_range(Global.viewpos.y, Global.viewend.y)
		2: # Bottom
			x = randf_range(Global.viewpos.x, Global.viewend.x)
			y = Global.viewend.y + 50
		3: # Left
			x = Global.viewpos.x - 50
			y = randf_range(Global.viewpos.y, Global.viewend.y)
	return Vector2(x, y)

func instance_node(path: String):
	var scene = load(path).instantiate()
	# Random position logic here (e.g., outside screen bounds)
	get_parent().add_child(scene)

func update_spawn_speed():
	# This makes the "Tick" happen faster and faster
	spawntimer.wait_time = randf_range(25.0,70.0)
