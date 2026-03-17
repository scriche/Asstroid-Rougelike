extends Area2D

var offset : Vector2 = Vector2(80*scale.x, 80*scale.x)
var health = 10
var is_dead = false
@export var Coin : PackedScene

func _ready() -> void:
	health = 5 * Global.diff * scale.x
	var middlevec =  (Global.viewend+Global.viewpos)/2 - position
	var randscale = randf_range(0.5*Global.diff*scale.x,0.7*Global.diff*scale.x)
	if rotation == 0:
		rotation += atan2(middlevec.y,middlevec.x)
		rotation += randf_range(-PI/3,PI/3)
	scale = Vector2(randscale, randscale) * scale

func _physics_process(delta: float) -> void:
	position += Vector2(cos(rotation), sin(rotation))*delta*60/scale*Global.diff
	if position - offset > Global.viewend or position + offset < Global.viewpos:
		queue_free()

func damage(amount: int) -> void:
	if is_dead: 
		return
	TriggerManager.on_damage_dealt(self, damage)
	health -= amount
	if health <= 0:
		is_dead = true
		break_apart()

func apply_stun(time):
	for x in range(time):
		print("stunned")

func break_apart() -> void:
	var c = Coin.instantiate()
	c.position = position
	get_parent().add_child(c)
	if scale > Vector2(0.8, 0.8):
		var a = self.duplicate()
		var b = self.duplicate()
		a.scale = scale * 0.7
		b.scale = scale * 0.7
		a.rotation = rotation + PI/4
		b.rotation = rotation - PI/4
		get_parent().add_child(a)
		get_parent().add_child(b)
	queue_free()
