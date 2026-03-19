extends Area2D

@export var bullet_scene: PackedScene
@export var bullet_count: int = 5
@export var rotation_speed: float = 0.3 # How fast the "firing point" spins
@export var health: int = 100
@export var speedmult: float = 300.0
@export var target_threshold: float = 100.0


var fire_timer: float = 0.0
var current_offset: float = 0.0
var current_target_pos: Vector2 = Vector2.ZERO
var is_dead: bool = false
var coincount: int = 5
var expcount: int = 10

func _ready():
	_pick_random_target()

func _physics_process(delta: float) -> void:
	if current_target_pos == Vector2.ZERO: 
		_pick_random_target()

	# 1. CALCULATE DIRECTION
	var to_target = current_target_pos - global_position
	var distance = to_target.length()
	
	# 2. CHECK ARRIVAL
	if distance < target_threshold:
		_pick_random_target()
		return

	
	rotation += PI/2 * rotation_speed * delta
	# Firing Logic:

	fire_timer += delta
	current_offset += rotation_speed * delta # Makes the pattern spin
	if fire_timer > 0.1:
		fire_bloom()
		fire_timer = 0.0

	#position += Vector2(cos(rotation), sin(rotation))*delta*speedmult

func fire_bloom(arms: int = 4):
	for arm in range(arms):
		# Calculate the base angle for this specific "arm"
		var arm_angle = (arm * (PI * 2.0) / arms) + current_offset
		
		# Fire a small cluster at that arm's position
		for i in range(3):
			var final_angle = arm_angle + (i - 1) * deg_to_rad(5)
			_spawn_bullet(final_angle, speedmult)

func fire_circle_pattern():
	for i in range(bullet_count):
		# Calculate angle for each bullet in the circle
		var angle = (i * (PI * 2.0) / bullet_count) + current_offset
		_spawn_bullet(angle, speedmult, 10, 4.0, 0.0)

func fire_towards_player():
	var player_pos = Global.playerpos
	var to_player = player_pos - global_position
	var base_angle = to_player.angle()
	for i in range(bullet_count):
		# Calculate angle for each bullet in the spread
		var spread_angle = deg_to_rad(30) # Total spread of 30 degrees
		var angle = base_angle + (float(i) / (bullet_count - 1) - 0.5) * spread_angle
		_spawn_bullet(angle, speedmult, 10, 4.0, 0.0)

func _spawn_bullet(angle: float, speed: float = 300.0, damage_amount: int = 10, bullet_scale: float = 4.0, rotation_force: float = 0.0):
	var b = bullet_scene.instantiate()
	b.scale = Vector2(bullet_scale, bullet_scale) # Adjust bullet size if needed
	b.position = global_position
	b.rotation = angle
	b.rotation_force = rotation_force
	b.speed = speed
	b.damage_amount = damage_amount
	get_parent().add_child(b)

func damage(amount: int) -> void:
	if is_dead: 
		return
	TriggerManager.on_damage_dealt(self, damage)
	health -= amount
	if health <= 0:
		is_dead = true
		queue_free()
		for x in range(coincount+Stats.getstat("greed")):
			var c = Global.Coin.instantiate()
			c.position = position+Vector2(randi_range(-20,20),randi_range(-20,20))
			get_parent().add_child(c)
		for x in range(expcount):
			var e = Global.ExpOrb.instantiate()
			e.position = position+Vector2(randi_range(-20,20),randi_range(-20,20))
			get_parent().add_child(e)
		

func _pick_random_target():
	# Use your Global view bounds to stay on screen
	var x = randf_range(Global.viewpos.x + 50, Global.viewend.x - 50)
	var y = randf_range(Global.viewpos.y + 50, Global.viewend.y - 50)
	current_target_pos = Vector2(x, y)
