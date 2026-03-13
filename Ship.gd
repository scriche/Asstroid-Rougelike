extends RigidBody2D

# Constants
const ROTATION_SPEED = 100

# Exported variables
@export var Bullet : PackedScene

# Internal state
var viewportInfo : Rect2
var velocity : Vector2 = Vector2.ZERO
var invincible : bool = false

func _physics_process(delta: float) -> void:
	# Update viewport info and player position
	viewportInfo = get_viewport().get_visible_rect()
	Global.set("playerpos", position)

	# Update UI (health bar)
	$TextureProgressBar.max_value = Stats.getstat("max_health")
	$TextureProgressBar.value = Stats.getstat("current_health")

	# Update player scale based on stat
	scale = Vector2(Stats.getstat("size"), Stats.getstat("size"))

	# --- Player Controls ---

	# Rotate left
	if Input.is_action_pressed("a"):
		rotate(-PI / 50 * delta * ROTATION_SPEED)
	
	# Rotate right
	if Input.is_action_pressed("d"):
		rotate(PI / 50 * delta * ROTATION_SPEED)
		
	# Apply thrust forward
	if Input.is_action_pressed("w"):
		var dir = Vector2(cos(rotation - PI/2), sin(rotation - PI/2))
		velocity += dir * Stats.getstat("acceleration") * delta

	# Fire bullet if timer allows
	if Input.is_action_pressed("space"):
		if $Timer.is_stopped():
			var b = Bullet.instantiate()
			owner.add_child(b)
			b.transform = $Marker2D.global_transform
			b.bullet_speed = Stats.getstat("bullet_speed")
			$Timer.start()

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
	Stats.setstat("current_health", Stats.getstat("current_health") + amount - int(Stats.getstat("armor") / 2))
	invincible = true
	$Sprite2D.modulate = Color(1, 1, 1, 0.5)  # Make the ship semi-transparent
	$Timer2.start()  # Start invincibility timer

	if Stats.getstat("current_health") <= 0:
		Global.set("lives", Global.lives - 1)
		queue_free()

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
	$Sprite2D.modulate = Color(1, 1, 1, 1)  # Reset ship transparency
