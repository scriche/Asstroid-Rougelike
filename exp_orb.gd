extends Area2D

var velocity: Vector2 = Vector2.ZERO

func _ready():
    # apply a small initial velocity in a random direction
    velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * 400

func _physics_process(delta):
    # lerp velocity every frame towards Global.playerpos
    var to_player = Global.playerpos - global_position
    velocity = velocity.lerp(to_player.normalized() * 1000, 0.1)
    position += velocity * delta