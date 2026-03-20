extends Area2D
class_name Astroid

var offset : Vector2 = Vector2(80*scale.x, 80*scale.x)
var health = 10
var is_dead = false
var coincount: int = 1
var expcount: int = 2
var speedmult: float = 1.0
var is_fragment: bool = false
var damage_amount: int = 25

func _ready() -> void:
	if not is_fragment:
		health = 5 * Global.diff * scale.x
		var middlevec = (Global.viewend + Global.viewpos) / 2 - position
		var randscale = randf_range(0.5 * Global.diff * scale.x, 0.7 * Global.diff * scale.x)
		
		if rotation == 0:
			rotation += atan2(middlevec.y, middlevec.x)
			rotation += randf_range(-PI / 3, PI / 3)
			
		scale = Vector2(randscale, randscale) * scale
	else:
		health = 5 * Global.diff * scale.x

func _physics_process(delta: float) -> void:
	position += Vector2(cos(rotation), sin(rotation))*delta*60/scale*Global.diff*speedmult
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
	for x in range(coincount+Stats.getstat("greed")):
		var c = Global.Coin.instantiate()
		c.position = position+Vector2(randi_range(-20,20),randi_range(-20,20))
		get_parent().add_child(c)
	for x in range(expcount):
		var e = Global.ExpOrb.instantiate()
		e.position = position+Vector2(randi_range(-20,20),randi_range(-20,20))
		get_parent().add_child(e)
	if scale > Vector2(0.8, 0.8):
		var a = self.duplicate()
		var b = self.duplicate()
		a.is_fragment = true
		b.is_fragment = true
		a.scale = scale * 0.7
		b.scale = scale * 0.7
		a.rotation = rotation + PI/4
		b.rotation = rotation - PI/4
		get_parent().add_child(a)
		get_parent().add_child(b)
	queue_free()
