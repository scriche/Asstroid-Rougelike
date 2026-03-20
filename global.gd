extends Node

var scrap : int = 0
var experience : float = 0
var lives : int = 1
var diff : float = 1.0
var viewpos : Vector2 = Vector2.ZERO
var viewend : Vector2 = Vector2.ZERO
var playerpos : Vector2 = Vector2.ZERO
var boss : Area2D

var Coin : PackedScene = preload("res://Scenes/Coin.tscn")
var ExpOrb : PackedScene = preload("res://Scenes/exp_orb.tscn")


func _process(_delta):
	diff = 1 + Time.get_ticks_msec()/1000.0/600.0
	viewpos = get_viewport().get_visible_rect().position
	viewend = get_viewport().get_visible_rect().end

enum Enemy {
	CIRCLE_PASSIVE,
	HENNIGMACHINE,
}

enum Event {
	GOLDEN_ASTEROID,
}

@onready var enemies = {
	Enemy.CIRCLE_PASSIVE: {
		"scene": preload("res://Enemies/simple_circle.tscn"),
		"cost": 1
	},
	Enemy.HENNIGMACHINE: {
		"scene": preload("res://Enemies/hennig_machine.tscn"),
		"cost": 20
	}
}

@onready var events = {
	Event.GOLDEN_ASTEROID: {
		"scene": preload("res://Events/GoldenAstroid.tscn"),
		"cost": 2
	}
}
