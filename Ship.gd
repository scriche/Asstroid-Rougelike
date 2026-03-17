extends RigidBody2D

# Exported variables
@export var Bullet : PackedScene

# Internal state
var viewportInfo : Rect2
var velocity : Vector2 = Vector2.ZERO
var invincible : bool = false

@onready var shoot_timer : Timer = $ShootTimer
@onready var invincibility_timer : Timer = $InvincibilityTimer
@onready var health_regen_timer : Timer = $HealthRegenTimer
@onready var shield_regen_timer: Timer = $ShieldRegenTimer
@onready var sprite : Sprite2D = $Sprite2D
@onready var healthbar : TextureProgressBar = $HealthBar
@onready var shieldbar : TextureProgressBar = $ShieldBar
@onready var barrel_marker : Marker2D = $Marker2D


func _physics_process(delta: float) -> void:
	# Update viewport info and player position
	viewportInfo = get_viewport().get_visible_rect()
	Global.set("playerpos", position)
	for upgrade in Stats.upgrades:
		if upgrade.passive == true:
			upgrade.passive_effect(self)

	# Update player scale based on stat
	scale = Vector2(Stats.getstat("size"), Stats.getstat("size"))

	# --- Player Controls ---

	# testing rotate towards cursor

	# Rotate left
	if Input.is_action_pressed("a"):
		rotate(-PI / 50 * delta * Stats.getstat("turn_speed"))
	
	# Rotate right
	if Input.is_action_pressed("d"):
		rotate(PI / 50 * delta * Stats.getstat("turn_speed"))
		
	# Apply thrust forward
	if Input.is_action_pressed("w"):
		var dir = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
		velocity += dir * Stats.getstat("acceleration") * delta

	if Input.is_action_pressed("space") or Input.is_action_pressed("click"):
		if shoot_timer.is_stopped():
			var bullet_count = Stats.getstat("bullet_count")
			var spread_angle = deg_to_rad(180) # The total arc (180 degrees)
			
			for i in range(bullet_count):
				var b = Bullet.instantiate()
				owner.add_child(b)
				
				# Trigger unique upgrade logic for EACH bullet
				TriggerManager.on_bullet_fired(b)
				
				# Start with the player's current facing direction
				var base_transform = barrel_marker.global_transform
				
				# Calculate the offset for this specific bullet
				var angle_offset = 0
				if bullet_count > 1:
					# This formula centers the spread perfectly
					# (i / (total - 1)) gives a 0.0 to 1.0 range
					# Subtracting 0.5 centers it to -0.5 to 0.5
					angle_offset = (float(i) / (bullet_count - 1) - 0.5) * spread_angle
				
				# Apply the transform and the rotation offset
				b.global_transform = base_transform
				b.rotation += angle_offset
				
				# Apply stats
				b.bullet_speed = Stats.getstat("bullet_speed")
				var b_size = Stats.getstat("bullet_size")
				b.scale = Vector2(b_size, b_size)
				b.bullet_damage = Stats.getstat("bullet_damage")
				b.homing_strength = Stats.getstat("bullet_homing")
				
			# Timer logic (outside the loop so it only resets once per volley)
			shoot_timer.wait_time = Stats.getstat("bullet_fire_rate")
			shoot_timer.start()

	# Apply braking
	if Input.is_action_pressed("shift"):
		velocity *= 0.95
		Stats.upgradepickup(UpgradeDatabase.get_upgrade_by_id(0)) # Temporary brake upgrade for testing

	# --- Screen Wrapping ---

	if position.x > Global.viewend.x:
		position.x -= viewportInfo.size.x
	elif position.x < Global.viewpos.x:
		position.x += viewportInfo.size.x

	if position.y > Global.viewend.y:
		position.y -= viewportInfo.size.y
	elif position.y < Global.viewpos.y:
		position.y += viewportInfo.size.y

	# --- Movement Update ---

	# Clamp speed and apply velocity
	var max_speed = Stats.getstat("max_speed")
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	Stats.setstat("current_speed", velocity.length())
	position += velocity

# Damage handler
func damage(amount: int, area: Area2D):
	# Reduce health based on incoming damage and armor stat
	TriggerManager.on_damage_recv(self, amount, area) 
	update_heathbar()
	amount *= (Stats.getstat("armor_efficiency")/Stats.getstat("armor_efficiency")+Stats.getstat("armor"))
	
	if Stats.getstat("shield") != 0:
		amount += Stats.getstat("shield")
		if amount >= 0:
			Stats.setstat("shield", amount)
		else:
			Stats.setstat("shield", 0)
		shieldbar.max_value = Stats.getstat("max_shield")
		shieldbar.value = Stats.getstat("shield")
			
	if amount < 0:
		Stats.setstat("current_health", Stats.getstat("current_health") + amount)
		update_heathbar()

		if Stats.getstat("current_health") <= 0:
			Global.set("lives", Global.lives - 1)
			queue_free()

	invincible = true
	sprite.modulate = Color(1, 1, 1, 0.5)  # Make the ship semi-transparent
	invincibility_timer.start()  # Start invincibility timer

# Collision detection
func _on_area_2d_area_entered(area: Area2D):

	if area.is_in_group("Coin"):
		Global.set("scrap", Global.scrap + 1 * Stats.getstat("greed"))
		area.get_parent().queue_free()

	if invincible:
		return

	if area.is_in_group("Astroids"):
		damage(-10, area)
		area.call_deferred("damage", Stats.getstat("size") * Stats.getstat("contact_damage"))


func _on_timer_2_timeout():
	invincible = false
	sprite.modulate = Color(1, 1, 1, 1)  # Reset ship transparency
	invincibility_timer.wait_time = Stats.getstat("i_frames")

func update_heathbar():
	if healthbar.max_value != Stats.getstat("max_health"):
		var increase =  Stats.getstat("max_health") - healthbar.max_value
		Stats.setstat("current_health", Stats.getstat("current_health")+increase)
	healthbar.max_value = Stats.getstat("max_health")
	healthbar.value = Stats.getstat("current_health")

	if Stats.getstat("current_health") > Stats.getstat("max_health"):
		Stats.setstat("current_health", Stats.getstat("max_health"))

func _on_health_regen_timer_timeout() -> void:
	# Regenerate health based on health regen stats
	health_regen_timer.wait_time = Stats.getstat("health_regen_speed")
	if Stats.getstat("current_health") < Stats.getstat("max_health"):
		Stats.setstat("current_health", Stats.getstat("current_health") + Stats.getstat("health_regen_amount"))
		update_heathbar()
		


func _on_shield_regen_timer_timeout() -> void:
	if Stats.getstat("shield") > 0:
		shieldbar.visible = true
	shield_regen_timer.wait_time = Stats.getstat("shield_regen_rate")
	if Stats.getstat("shield") < Stats.getstat("max_shield"):
		Stats.setstat("shield", Stats.getstat("shield") + Stats.getstat("shield_regen_amount"))
		shieldbar.value = Stats.getstat("shield")
