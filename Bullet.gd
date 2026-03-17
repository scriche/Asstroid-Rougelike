extends Area2D

@export var bullet_speed: float
@export var homing_strength: float
@export var bullet_damage: float
var pierce_count = 0
var target: Node2D = null
var search_timer: float = randf_range(0.0,0.2)

func _physics_process(delta: float) -> void:
	# 1. Target Refresh (Staggered for performance)
	if homing_strength > 0:
		search_timer -= delta
		if search_timer <= 0:
			target = find_closest_enemy()
			search_timer = 0.2
		
		# 2. Homing Turn Logic
		if homing_strength > 0 and is_instance_valid(target):
			# We add PI/2 here to compensate for your sprite's "Up" offset 
			# so the "logic" angle matches your "visual" angle
			var angle_to_target = global_position.angle_to_point(target.global_position) + PI/2
			
			# Smoothly rotate the bullet's rotation property
			rotation = rotate_toward(rotation, angle_to_target, homing_strength * delta)

	# 3. Movement (Your original math)
	var velocity = Vector2(cos(rotation - PI/2), sin(rotation - PI/2)) * bullet_speed
	position += velocity * delta

func find_closest_enemy() -> Node2D:
	# Assuming your enemies are in a group called "enemies"
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
		
	var nearest = null
	var min_dist = INF
	
	for enemy in enemies:
		# Use distance_squared_to for maximum performance
		var dist = global_position.distance_squared_to(enemy.global_position)
		if dist > pow(600,2):
			continue
		if dist < min_dist:
			min_dist = dist
			nearest = enemy
			
	return nearest

func _on_timer_timeout() -> void:
	queue_free()

func _on_area_entered(area:Area2D):
	if area.is_in_group("Astroids"):
		# Send onhit signal to the signal manager
		TriggerManager.on_bullet_hit(self, area)
		var crit_chance = Stats.getstat("bullet_crit_chance")
		var crit_mult = Stats.getstat("bullet_crit_mult")
		var guaranteed_crits = floor(crit_chance)
		var extra_chance = fmod(crit_chance, 1.0)
		var total_crits = int(guaranteed_crits)
		if randf() < extra_chance:
			total_crits += 1
		for i in range(total_crits):
			bullet_damage *= crit_mult
		area.call_deferred("damage", bullet_damage)
		if pierce_count >= Stats.getstat("bullet_pierce"):
			queue_free()
		pierce_count+=1
