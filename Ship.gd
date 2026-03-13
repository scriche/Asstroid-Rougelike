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
@onready var healthbar : TextureProgressBar = $TextureProgressBar


func _physics_process(delta: float) -> void:
	# Update viewport info and player position
	viewportInfo = get_viewport().get_visible_rect()
	Global.set("playerpos", position)

	# Update player scale based on stat
	scale = Vector2(Stats.getstat("size"), Stats.getstat("size"))

	# --- Player Controls ---

	# Rotate left
	if Input.is_action_pressed("a"):
		rotate(-PI / 50 * delta * Stats.getstat("rotation_speed"))
	
	# Rotate right
	if Input.is_action_pressed("d"):
		rotate(PI / 50 * delta * Stats.getstat("rotation_speed"))
		
	# Apply thrust forward
	if Input.is_action_pressed("w"):
		var dir = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
		velocity += dir * Stats.getstat("acceleration") * delta

	# Fire bullet if timer allows
	if Input.is_action_pressed("space"):
		if shoot_timer.is_stopped():
			var b = Bullet.instantiate()
			owner.add_child(b)
			b.transform = $Marker2D.global_transform
			b.bullet_speed = Stats.getstat("bullet_speed")
			TriggerManager.on_bullet_fired(b)
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
func damage(amount: int):
	# Reduce health based on incoming damage and armor stat
	amount *= (Stats.getstat("armor_efficiency")/Stats.getstat("armor_efficiency")+Stats.getstat("armor"))
	
	if Stats.getstat("shield") != 0:
		amount += Stats.getstat("shield")
		if amount >= 0:
			Stats.setstat("shield", amount)
		else:
			Stats.setstat("shield", 0)
			
	if amount < 0:
		Stats.setstat("current_health", Stats.getstat("current_health") + amount)
		# Update UI (health bar)
		healthbar.max_value = Stats.getstat("max_health")
		healthbar.value = Stats.getstat("current_health")

		if Stats.getstat("current_health") <= 0:
			Global.set("lives", Global.lives - 1)
			queue_free()

	invincible = true
	sprite.modulate = Color(1, 1, 1, 0.5)  # Make the ship semi-transparent
	invincibility_timer.start()  # Start invincibility timer

# Collision detection
func _on_area_2d_area_entered(area: Area2D):

	if area.is_in_group("Coin"):
		Global.set("scrap", Global.scrap + 1)
		area.get_parent().queue_free()

	if invincible:
		return

	if area.is_in_group("Astroids"):
		damage(-25)
		area.call_deferred("damage", Stats.getstat("size") * 20)


func _on_timer_2_timeout():
	invincible = false
	sprite.modulate = Color(1, 1, 1, 1)  # Reset ship transparency


func _on_health_regen_timer_timeout() -> void:
	# Regenerate health based on health regen stats
	health_regen_timer.wait_time = Stats.getstat("health_regen_speed")
	if Stats.getstat("current_health") < Stats.getstat("max_health"):
		Stats.setstat("current_health", Stats.getstat("current_health") + Stats.getstat("health_regen_amount"))
		# Update UI (health bar)
		healthbar.value = Stats.getstat("current_health")


func _on_shield_regen_timer_timeout() -> void:
	shield_regen_timer.wait_time = Stats.getstat("shield_regen_rate")
	todo

